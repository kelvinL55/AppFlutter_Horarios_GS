import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:http/http.dart' as http;

// --- Pantalla para Agregar o Editar un Producto ---
// Este widget con estado (StatefulWidget) permite a los usuarios crear un nuevo producto
// o modificar uno existente. La decisión se basa en si se le pasa un objeto `product`.
class AddEditProductScreen extends StatefulWidget {
  // El producto a editar. Si es `null`, la pantalla estará en modo "crear".
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  // --- Claves y Controladores ---
  // Clave global para identificar y validar el formulario.
  final _formKey = GlobalKey<FormState>();
  // Controladores para gestionar el texto de los campos del formulario.
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Instancia del servicio de productos para interactuar con Firestore.
  final _productService = ProductService();

  // --- Variables de Estado ---
  // Indica si se está realizando una operación asíncrona (guardando).
  bool _isLoading = false;
  // Indica si se está validando la URL de la imagen.
  bool _isValidatingImage = false;
  // Almacena el resultado de la validación de la imagen.
  bool _isImageValid = false;
  // Almacena la categoría seleccionada en el menú desplegable.
  String? _selectedCategory;

  // Lista de categorías predefinidas para el menú desplegable.
  final List<String> _categories = [
    'smartphone',
    'laptop',
    'tablet',
    'drone',
    'camera',
    'headphones',
    'smartwatch',
    'gaming',
    'accessories',
    'other',
  ];

  // --- Ciclo de Vida del Widget ---

  @override
  void initState() {
    super.initState();
    // Si se proporciona un producto, estamos en "modo edición".
    // Se inicializan los controladores con los datos del producto existente.
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _selectedCategory = widget.product!.category;
      _descriptionController.text = widget.product!.description;
      _isImageValid = true; // Asumimos que la imagen de un producto existente es válida.
    }
  }

  @override
  void dispose() {
    // Libera los recursos de los controladores para evitar fugas de memoria.
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Métodos de Validación del Formulario ---

  // Valida el nombre del producto, asegurando que no esté vacío,
  // tenga una longitud mínima y no esté duplicado al crear un nuevo producto.
  Future<String?> _validateProductName(String? value) async {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese el nombre del producto';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    // La validación de duplicados solo se ejecuta al crear un producto nuevo.
    if (widget.product == null) {
      final products = await _productService.getProducts().first;
      final existingProduct = products
          .where((p) => p.name.toLowerCase().trim() == value.toLowerCase().trim())
          .firstOrNull;
      if (existingProduct != null) {
        return 'Ya existe un producto con este nombre';
      }
    }
    return null; // Retorna null si la validación es exitosa.
  }

  // Valida el precio, asegurando que no esté vacío, sea un número válido,
  // no sea negativo y no exceda un límite.
  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el precio';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Por favor ingrese un precio válido';
    }
    if (price < 0) {
      return 'El precio no puede ser negativo';
    }
    if (price > 999999.99) {
      return 'El precio no puede ser mayor a \$999,999.99';
    }
    return null;
  }

  // Valida la URL de la imagen, asegurando que no esté vacía y
  // siga un formato de URL básico (http o https).
  String? _validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese la URL de la imagen';
    }
    final urlPattern = RegExp(r'^https?:\/\/.+');
    if (!urlPattern.hasMatch(value)) {
      return 'Por favor ingrese una URL válida que comience con http:// o https://';
    }
    return null;
  }

  // Valida la descripción, asegurando que no esté vacía y
  // cumpla con los límites de longitud.
  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese la descripción';
    }
    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    if (value.trim().length > 500) {
      return 'La descripción no puede exceder 500 caracteres';
    }
    return null;
  }

  // Valida la categoría, asegurando que se haya seleccionado una opción.
  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor seleccione una categoría';
    }
    return null;
  }

  // --- Lógica de Negocio ---

  // Realiza una petición HTTP GET a la URL de la imagen para verificar si es accesible.
  // Actualiza el estado para mostrar un ícono de éxito o error.
  Future<void> _testImageUrl() async {
    if (_imageUrlController.text.trim().isEmpty) return;
    setState(() => _isValidatingImage = true);
    try {
      final response = await http.get(Uri.parse(_imageUrlController.text.trim()));
      setState(() {
        _isImageValid = response.statusCode >= 200 && response.statusCode < 300;
      });
    } catch (e) {
      setState(() => _isImageValid = false);
    } finally {
      setState(() => _isValidatingImage = false);
    }
  }

  // Guarda el producto (crea uno nuevo o actualiza uno existente).
  Future<void> _saveProduct() async {
    // Primero, valida todos los campos del formulario.
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Crea un objeto ProductModel con los datos de los controladores.
        final product = ProductModel(
          id: widget.product?.id ?? '',
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: _imageUrlController.text.trim(),
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
          createdAt: widget.product?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        bool success;
        // Decide si crear o actualizar basándose en si `widget.product` es nulo.
        if (widget.product == null) {
          final newId = await _productService.createProduct(product);
          success = newId != null;
        } else {
          success = await _productService.updateProduct(product);
        }

        // Muestra un mensaje de éxito o error y regresa a la pantalla anterior.
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.product == null
                  ? 'Producto creado exitosamente'
                  : 'Producto actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          // Manejo de error si la operación falla.
        }
      } catch (e) {
        // Manejo de excepciones generales.
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // --- Construcción de la Interfaz de Usuario (UI) ---

  @override
  Widget build(BuildContext context) {
    // Determina si la pantalla está en modo edición para cambiar títulos y textos.
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Agregar Producto'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // --- Campos del Formulario ---

                      // Campo Nombre (con validación asíncrona en FutureBuilder)
                      FutureBuilder<String?>(
                        future: _validateProductName(_nameController.text),
                        builder: (context, snapshot) {
                          return TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre del producto',
                              prefixIcon: const Icon(Icons.shopping_bag),
                              border: const OutlineInputBorder(),
                              errorText: snapshot.data,
                              suffixIcon: _nameController.text.isNotEmpty
                                  ? Icon(
                                      snapshot.data == null ? Icons.check_circle : Icons.error,
                                      color: snapshot.data == null ? Colors.green : Colors.red,
                                    )
                                  : null,
                            ),
                            onChanged: (value) => setState(() {}),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Precio
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _validatePrice,
                      ),
                      const SizedBox(height: 16),

                      // Campo URL de Imagen (con botón de prueba)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: InputDecoration(
                                labelText: 'URL de la imagen',
                                prefixIcon: const Icon(Icons.image),
                                border: const OutlineInputBorder(),
                                suffixIcon: _imageUrlController.text.isNotEmpty
                                    ? Icon(
                                        _isImageValid ? Icons.check_circle : Icons.error,
                                        color: _isImageValid ? Colors.green : Colors.red,
                                      )
                                    : null,
                              ),
                              onChanged: (value) => setState(() => _isImageValid = false),
                              validator: _validateImageUrl,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _isValidatingImage ? null : _testImageUrl,
                            icon: _isValidatingImage
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                            tooltip: 'Probar URL de imagen',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Campo Categoría (Menú Desplegable)
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
                        validator: _validateCategory,
                      ),
                      const SizedBox(height: 16),

                      // Campo Descripción
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: const Icon(Icons.description),
                          border: const OutlineInputBorder(),
                          counterText: '${_descriptionController.text.length}/500',
                        ),
                        maxLines: 3,
                        maxLength: 500,
                        validator: _validateDescription,
                        onChanged: (value) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón de Guardar/Actualizar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Guardando...'),
                          ],
                        )
                      : Text(
                          isEditing ? 'Actualizar Producto' : 'Crear Producto',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}