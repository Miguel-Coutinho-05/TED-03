import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NovoPedidoScreen extends StatefulWidget {
  const NovoPedidoScreen({super.key});

  @override
  State<NovoPedidoScreen> createState() => _NovoPedidoScreenState();
}

class _NovoPedidoScreenState extends State<NovoPedidoScreen> {
  final clienteController = TextEditingController();
  final enderecoController = TextEditingController();
  final descricaoController = TextEditingController();
  final valorController = TextEditingController();

  Future<void> salvarPedido() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não está logado.')));
      return;
    }

    if (clienteController.text.trim().isEmpty ||
        enderecoController.text.trim().isEmpty ||
        descricaoController.text.trim().isEmpty ||
        valorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('pedidos').add({
      'cliente': clienteController.text.trim(),
      'endereco': enderecoController.text.trim(),
      'descricao': descricaoController.text.trim(),
      'valor': valorController.text.trim(),
      'status': 'pendente',
      'proprietarioId': usuario.uid,
      'entregadorId': '',
      'criadoEm': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido cadastrado com sucesso!')),
    );

    clienteController.clear();
    enderecoController.clear();
    descricaoController.clear();
    valorController.clear();

    Navigator.pop(context);
  }

  @override
  void dispose() {
    clienteController.dispose();
    enderecoController.dispose();
    descricaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: clienteController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do cliente',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: enderecoController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço de entrega',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do pedido',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor da entrega',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: salvarPedido,
                    icon: const Icon(Icons.save),
                    label: const Text('Cadastrar Pedido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
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
