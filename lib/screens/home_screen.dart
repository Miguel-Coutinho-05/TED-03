import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color corStatus(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'em_transporte':
        return Colors.blue;
      case 'entregue':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String textoStatus(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'em_transporte':
        return 'Em transporte';
      case 'entregue':
        return 'Entregue';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  Future<void> cancelarPedido(
    BuildContext context,
    DocumentReference pedidoRef,
  ) async {
    await pedidoRef.update({'status': 'cancelado'});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido cancelado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    final pedidosStream = FirebaseFirestore.instance
        .collection('pedidos')
        .where('proprietarioId', isEqualTo: usuario?.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel do Comerciante'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: pedidosStream,
          builder: (context, snapshot) {
            final pedidos = snapshot.hasData ? snapshot.data!.docs : [];

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Área do Comerciante',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gerencie seus pedidos e acompanhe as entregas.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/novo_pedido');
                        },
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.add_box,
                                  size: 50,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Novo Pedido',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.list_alt,
                                size: 50,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${pedidos.length}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Pedidos',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Erro ao carregar pedidos'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (pedidos.isEmpty) {
                        return const Center(
                          child: Text('Nenhum pedido cadastrado'),
                        );
                      }

                      return ListView.builder(
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedidoDoc = pedidos[index];
                          final pedido =
                              pedidoDoc.data() as Map<String, dynamic>;

                          final status = pedido['status'] ?? 'pendente';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Icon(
                                Icons.local_shipping,
                                color: corStatus(status),
                              ),
                              title: Text(pedido['cliente'] ?? 'Sem cliente'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pedido['descricao'] ?? ''),
                                  Text(pedido['endereco'] ?? ''),
                                  Text('Valor: R\$ ${pedido['valor'] ?? '0'}'),
                                  Text(
                                    'Status: ${textoStatus(status)}',
                                    style: TextStyle(
                                      color: corStatus(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: status == 'cancelado'
                                  ? const Icon(Icons.cancel, color: Colors.red)
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Cancelar pedido',
                                      onPressed: () {
                                        cancelarPedido(
                                          context,
                                          pedidoDoc.reference,
                                        );
                                      },
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
