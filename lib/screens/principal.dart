import 'package:flutter/material.dart';

class Principal extends StatelessWidget {
  const Principal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi primera ventana"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Cuerpo de la app",
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
            SizedBox(height: 20), // Espacio entre textos
            Text(
              "Cuerpo de la app",
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
            SizedBox(height: 20), // Espacio entre textos
            Text(
              "Cuerpo de la app",
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
