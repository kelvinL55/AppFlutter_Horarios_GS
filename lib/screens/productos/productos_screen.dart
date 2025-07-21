import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';
import 'package:flutter_application_1/widgets/product_card.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:flutter_application_1/screens/productos/add_edit_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Pantalla de Visualización de Productos ---
// Muestra una lista de productos obtenidos de Firestore con paginación
// y scroll infinito.
class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  // --- Dependencias y Controladores ---
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();

  // --- Estado de Paginación y Datos ---
  final int _pageSize = 10; // Número de productos a cargar por página.
  List<ProductModel> _productos = []; // La lista de productos cargados.
  DocumentSnapshot? _lastDoc; // El último documento obtenido, para paginación.
  bool _isLoading = false; // Indica si hay una carga de datos en curso.
  bool _hasMore = true; // Indica si hay más productos por cargar.
  int? imagenExpandida; // Índice de la imagen que se muestra en pantalla completa.

  // --- Ciclo de Vida del Widget ---

  @override
  void initState() {
    super.initState();
    // Carga los productos iniciales al crear la pantalla.
    _fetchInitialProducts();
    // Añade un listener al scroll para detectar cuándo cargar más productos.
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Libera los recursos del controlador de scroll.
    _scrollController.dispose();
    super.dispose();
  }

  // --- Lógica de Carga de Datos ---

  // Carga la primera página de productos.
  Future<void> _fetchInitialProducts() async {
    setState(() => _isLoading = true);
    final products = await _productService.getProductsPaginated(limit: _pageSize);
    setState(() {
      _productos = products;
      _isLoading = false;
      _hasMore = products.length == _pageSize;
      _lastDoc = null; // Resetea el último documento.
    });

    // Obtiene la referencia al último documento de la primera carga.
    if (products.isNotEmpty) {
      final query = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize)
          .get();
      if (query.docs.isNotEmpty) {
        setState(() => _lastDoc = query.docs.last);
      }
    }
  }

  // Carga la siguiente página de productos.
  Future<void> _fetchMoreProducts() async {
    // Evita cargas múltiples o innecesarias.
    if (_isLoading || !_hasMore || _lastDoc == null) return;

    setState(() => _isLoading = true);
    final moreProducts = await _productService.getNextProductsPaginated(
      lastDoc: _lastDoc!,
      limit: _pageSize,
    );
    setState(() {
      _productos.addAll(moreProducts); // Añade los nuevos productos a la lista existente.
      _isLoading = false;
      _hasMore = moreProducts.length == _pageSize;
    });

    // Actualiza la referencia al último documento.
    if (moreProducts.isNotEmpty) {
      final query = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(_pageSize)
          .get();
      if (query.docs.isNotEmpty) {
        setState(() => _lastDoc = query.docs.last);
      }
    }
  }

  // Listener del scroll que dispara la carga de más productos cuando se llega cerca del final.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchMoreProducts();
    }
  }

  // --- Construcción de la Interfaz de Usuario (UI) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Productos'),
        centerTitle: true,
        elevation: 0,
      ),
      // Muestra un indicador de carga inicial o la lista de productos.
      body: _productos.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Cuadrícula de productos.
                GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Dos columnas.
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7, // Relación de aspecto de las tarjetas.
                  ),
                  // El itemCount incluye un item extra para el indicador de carga si hay más productos.
                  itemCount: _productos.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Si es el último item y hay más por cargar, muestra un spinner.
                    if (index >= _productos.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Crea una tarjeta de producto para cada elemento de la lista.
                    final producto = _productos[index];
                    return ProductCard(
                      product: producto,
                      onEdit: () => _editProduct(producto),
                      onDelete: () => _deleteProduct(producto.id),
                      onImageTap: () => setState(() => imagenExpandida = index),
                    );
                  },
                ),
                // Muestra la imagen en pantalla completa si se ha seleccionado una.
                if (imagenExpandida != null)
                  GestureDetector(
                    onTap: () => setState(() => imagenExpandida = null),
                    child: Container(
                      color: Colors.black.withOpacity(0.85),
                      alignment: Alignment.center,
                      child: InteractiveViewer(
                        child: Image.network(_productos[imagenExpandida!].imageUrl, fit: BoxFit.contain),
                      ),
                    ),
                  ),
              ],
            ),
      // Botón flotante para agregar nuevos productos.
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
      // Barra de navegación inferior.
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // El índice 2 corresponde a "Productos".
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/schedule');
        },
      ),
    );
  }

  // --- Métodos de Navegación y Acciones ---

  // Navega a la pantalla de agregar producto y refresca la lista al volver.
  void _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
    ).then((_) => _fetchInitialProducts());
  }

  // Navega a la pantalla de edición con el producto seleccionado y refresca al volver.
  void _editProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditProductScreen(product: product)),
    ).then((_) => _fetchInitialProducts());
  }

  // Elimina un producto y muestra un mensaje de confirmación o error.
  Future<void> _deleteProduct(String productId) async {
    final success = await _productService.deleteProduct(productId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado exitosamente'), backgroundColor: Colors.green),
      );
      _fetchInitialProducts(); // Recarga la lista para reflejar la eliminación.
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el producto'), backgroundColor: Colors.red),
      );
    }
  }
}