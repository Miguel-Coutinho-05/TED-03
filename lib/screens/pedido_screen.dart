import 'package:flutter/material.dart';

class PedidoScreen extends StatelessWidget {
  const PedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos'), centerTitle: true),
      body: Center(
        child: Text(
          'Tela do Entregador',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
