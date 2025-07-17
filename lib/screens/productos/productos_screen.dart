import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';
import 'package:flutter_application_1/widgets/product_card.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:flutter_application_1/screens/productos/add_edit_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 10;
  List<ProductModel> _productos = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  int? imagenExpandida;

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialProducts() async {
    setState(() => _isLoading = true);
    final products = await _productService.getProductsPaginated(
      limit: _pageSize,
    );
    setState(() {
      _productos = products;
      _isLoading = false;
      _hasMore = products.length == _pageSize;
      if (products.isNotEmpty) {
        _lastDoc = null;
      }
    });
    if (products.isNotEmpty) {
      final query = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize)
          .get();
      if (query.docs.isNotEmpty) {
        setState(() {
          _lastDoc = query.docs.last;
        });
      }
    }
  }

  Future<void> _fetchMoreProducts() async {
    if (_isLoading || !_hasMore || _lastDoc == null) return;
    setState(() => _isLoading = true);
    final moreProducts = await _productService.getNextProductsPaginated(
      lastDoc: _lastDoc!,
      limit: _pageSize,
    );
    setState(() {
      _productos.addAll(moreProducts);
      _isLoading = false;
      _hasMore = moreProducts.length == _pageSize;
    });
    if (moreProducts.isNotEmpty) {
      final query = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(_pageSize)
          .get();
      if (query.docs.isNotEmpty) {
        setState(() {
          _lastDoc = query.docs.last;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Productos'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _productos.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _productos.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _productos.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final producto = _productos[index];
                    return ProductCard(
                      product: producto,
                      onEdit: () => _editProduct(producto),
                      onDelete: () => _deleteProduct(producto.id),
                      onImageTap: () {
                        setState(() {
                          imagenExpandida = index;
                        });
                      },
                    );
                  },
                ),
                if (imagenExpandida != null)
                  GestureDetector(
                    onTap: () => setState(() => imagenExpandida = null),
                    child: Container(
                      color: Colors.black.withOpacity(0.85),
                      alignment: Alignment.center,
                      child: InteractiveViewer(
                        child: Image.network(
                          _productos[imagenExpandida!].imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/schedule');
          }
        },
      ),
    );
  }

  void _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
    ).then((_) => _fetchInitialProducts());
  }

  void _editProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(product: product),
      ),
    ).then((_) => _fetchInitialProducts());
  }

  Future<void> _deleteProduct(String productId) async {
    final success = await _productService.deleteProduct(productId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchInitialProducts();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar el producto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
