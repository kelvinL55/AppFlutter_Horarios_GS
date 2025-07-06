import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<dynamic> productos = [];
  bool loading = true;
  int? imagenExpandida;
  int itemsToShow = 10;
  final int itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    cargarProductos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !loading) {
      setState(() {
        itemsToShow = (itemsToShow + itemsPerPage).clamp(0, productos.length);
      });
    }
  }

  Future<void> cargarProductos() async {
    final String response = await rootBundle.loadString(
      'assets/data/tech_products.json',
    );
    final data = await json.decode(response);
    setState(() {
      productos = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos'), centerTitle: true),
      body: loading
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
                  itemCount: itemsToShow,
                  itemBuilder: (context, index) {
                    if (index >= productos.length) return const SizedBox();
                    final producto = productos[index];
                    return _ProductoCard(
                      producto: producto,
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
                          productos[imagenExpandida!]['image_url'],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
              ],
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
}

class _ProductoCard extends StatefulWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onImageTap;
  const _ProductoCard({required this.producto, required this.onImageTap});

  @override
  State<_ProductoCard> createState() => _ProductoCardState();
}

class _ProductoCardState extends State<_ProductoCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onImageTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      widget.producto['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.producto['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Categoría: ${widget.producto['category']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      ...widget.producto.entries
                          .where(
                            (e) =>
                                e.key != 'name' &&
                                e.key != 'category' &&
                                e.key != 'image_url' &&
                                e.key != 'id',
                          )
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                '${e.key[0].toUpperCase()}${e.key.substring(1)}: ${e.value}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
