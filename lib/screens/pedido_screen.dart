import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PedidoScreen extends StatelessWidget {
  const PedidoScreen({super.key});

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

  Future<void> aceitarPedido(
    BuildContext context,
    DocumentReference pedidoRef,
  ) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não está logado.')));
      return;
    }

    await pedidoRef.update({
      'status': 'em_transporte',
      'entregadorId': usuario.uid,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pedido aceito com sucesso!')));
  }

  Future<void> finalizarPedido(
    BuildContext context,
    DocumentReference pedidoRef,
  ) async {
    await pedidoRef.update({'status': 'entregue'});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entrega finalizada com sucesso!')),
    );
  }

  Widget cardResumo({
    required IconData icone,
    required Color cor,
    required int total,
    required String titulo,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 40),
              const SizedBox(height: 8),
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    final pedidosDisponiveisStream = FirebaseFirestore.instance
        .collection('pedidos')
        .where('status', isEqualTo: 'pendente')
        .snapshots();

    final minhasEntregasStream = FirebaseFirestore.instance
        .collection('pedidos')
        .where('entregadorId', isEqualTo: usuario?.uid)
        .snapshots();

    final emAndamentoStream = FirebaseFirestore.instance
        .collection('pedidos')
        .where('entregadorId', isEqualTo: usuario?.uid)
        .where('status', isEqualTo: 'em_transporte')
        .snapshots();

    final entreguesStream = FirebaseFirestore.instance
        .collection('pedidos')
        .where('entregadorId', isEqualTo: usuario?.uid)
        .where('status', isEqualTo: 'entregue')
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel do Entregador'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Área do Motoboy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aceite entregas e acompanhe seu trabalho.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: pedidosDisponiveisStream,
                  builder: (context, snapshot) {
                    final total = snapshot.hasData
                        ? snapshot.data!.docs.length
                        : 0;

                    return cardResumo(
                      icone: Icons.assignment,
                      cor: Colors.orange,
                      total: total,
                      titulo: 'Disponíveis',
                    );
                  },
                ),
                const SizedBox(width: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: emAndamentoStream,
                  builder: (context, snapshot) {
                    final total = snapshot.hasData
                        ? snapshot.data!.docs.length
                        : 0;

                    return cardResumo(
                      icone: Icons.delivery_dining,
                      cor: Colors.blue,
                      total: total,
                      titulo: 'Em andamento',
                    );
                  },
                ),
                const SizedBox(width: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: entreguesStream,
                  builder: (context, snapshot) {
                    final total = snapshot.hasData
                        ? snapshot.data!.docs.length
                        : 0;

                    return cardResumo(
                      icone: Icons.check_circle,
                      cor: Colors.green,
                      total: total,
                      titulo: 'Entregues',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pedidos disponíveis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: pedidosDisponiveisStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar pedidos disponíveis'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final pedidos = snapshot.data!.docs;

                  if (pedidos.isEmpty) {
                    return const Center(
                      child: Text('Nenhum pedido disponível'),
                    );
                  }

                  return ListView.builder(
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      final pedidoDoc = pedidos[index];
                      final pedido = pedidoDoc.data() as Map<String, dynamic>;

                      final status = pedido['status'] ?? 'pendente';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Icon(
                            Icons.delivery_dining,
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
                          trailing: ElevatedButton(
                            onPressed: () {
                              aceitarPedido(context, pedidoDoc.reference);
                            },
                            child: const Text('Aceitar'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Minhas entregas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: minhasEntregasStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar minhas entregas'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final pedidos = snapshot.data!.docs;

                  if (pedidos.isEmpty) {
                    return const Center(child: Text('Nenhuma entrega aceita'));
                  }

                  return ListView.builder(
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      final pedidoDoc = pedidos[index];
                      final pedido = pedidoDoc.data() as Map<String, dynamic>;

                      final status = pedido['status'] ?? 'em_transporte';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Icon(
                            status == 'entregue'
                                ? Icons.check_circle
                                : Icons.delivery_dining,
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
                          trailing: status == 'entregue'
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    finalizarPedido(
                                      context,
                                      pedidoDoc.reference,
                                    );
                                  },
                                  child: const Text('Entregue'),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
