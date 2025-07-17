import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:http/http.dart' as http;

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // null para crear, con datos para editar

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productService = ProductService();

  bool _isLoading = false;
  bool _isValidatingImage = false;
  bool _isImageValid = false;
  String? _selectedCategory;

  // Categorías predefinidas
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

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Modo edición
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _selectedCategory = widget.product!.category;
      _descriptionController.text = widget.product!.description;
      _isImageValid = true; // Asumimos que la imagen existente es válida
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Validar que el nombre no esté duplicado
  Future<String?> _validateProductName(String? value) async {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese el nombre del producto';
    }

    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    // Solo validar duplicados si estamos creando un nuevo producto
    if (widget.product == null) {
      final products = await _productService.getProducts().first;
      final existingProduct = products
          .where(
            (p) => p.name.toLowerCase().trim() == value.toLowerCase().trim(),
          )
          .firstOrNull;

      if (existingProduct != null) {
        return 'Ya existe un producto con este nombre';
      }
    }

    return null;
  }

  // Validar precio
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

  // Validar URL de imagen
  String? _validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese la URL de la imagen';
    }

    // Validación básica de formato de URL
    final urlPattern = RegExp(r'^https?:\/\/.+');

    if (!urlPattern.hasMatch(value)) {
      return 'Por favor ingrese una URL válida que comience con http:// o https://';
    }

    return null;
  }

  // Validar descripción
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

  // Validar categoría
  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor seleccione una categoría';
    }
    return null;
  }

  // Probar URL de imagen
  Future<void> _testImageUrl() async {
    if (_imageUrlController.text.trim().isEmpty) return;

    setState(() {
      _isValidatingImage = true;
    });

    try {
      final response = await http.get(
        Uri.parse(_imageUrlController.text.trim()),
      );
      setState(() {
        _isImageValid = response.statusCode >= 200 && response.statusCode < 300;
        _isValidatingImage = false;
      });
    } catch (e) {
      setState(() {
        _isImageValid = false;
        _isValidatingImage = false;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
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
        if (widget.product == null) {
          // Crear nuevo producto
          final newId = await _productService.createProduct(product);
          success = newId != null;
        } else {
          // Actualizar producto existente
          success = await _productService.updateProduct(product);
        }

        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null
                    ? 'Producto creado exitosamente'
                    : 'Producto actualizado exitosamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar el producto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Agregar Producto'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card principal
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Campo Nombre
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
                                      snapshot.data == null
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: snapshot.data == null
                                          ? Colors.green
                                          : Colors.red,
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePrice,
                      ),
                      const SizedBox(height: 16),

                      // Campo URL de imagen
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
                                        _isImageValid
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: _isImageValid
                                            ? Colors.green
                                            : Colors.red,
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _isImageValid = false;
                                });
                              },
                              validator: _validateImageUrl,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _isValidatingImage
                                ? null
                                : _testImageUrl,
                            icon: _isValidatingImage
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.search),
                            tooltip: 'Probar URL de imagen',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Campo Categoría (Dropdown)
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
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
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
                          counterText:
                              '${_descriptionController.text.length}/500',
                        ),
                        maxLines: 3,
                        maxLength: 500,
                        validator: _validateDescription,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón guardar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
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
