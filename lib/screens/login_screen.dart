import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLogin = true;
  bool carregando = false;
  String tipoUsuario = 'Vendedor';

  Future<void> autenticar() async {
    setState(() {
      carregando = true;
    });

    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: senhaController.text.trim(),
        );

        final userDoc = await _firestore
            .collection('usuarios')
            .doc(_auth.currentUser!.uid)
            .get();

        final tipo = userDoc.data()?['tipo'] ?? 'Vendedor';

        if (!mounted) return;

        if (tipo == 'Vendedor') {
          Navigator.pushReplacementNamed(context, '/home_vendedor');
        } else {
          Navigator.pushReplacementNamed(context, '/home_entregador');
        }
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: senhaController.text.trim(),
        );

        await _firestore
            .collection('usuarios')
            .doc(_auth.currentUser!.uid)
            .set({
              'email': emailController.text.trim(),
              'tipo': tipoUsuario,
              'criadoEm': FieldValue.serverTimestamp(),
            });

        mensagem('Cadastro realizado com sucesso! Faça login.');

        setState(() {
          isLogin = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      mensagem(e.message ?? 'Erro de autenticação');
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.delivery_dining,
                    size: 70,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Balsas Entregas LTDA',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isLogin ? 'Acesse sua conta' : 'Crie sua conta no sistema',
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  if (!isLogin) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: tipoUsuario,
                      items: const [
                        DropdownMenuItem(
                          value: 'Vendedor',
                          child: Text('Comerciante / Vendedor'),
                        ),
                        DropdownMenuItem(
                          value: 'Entregador',
                          child: Text('Motoboy / Entregador'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tipoUsuario = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Tipo de usuário',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: carregando ? null : autenticar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: carregando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isLogin ? 'Entrar' : 'Cadastrar',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: carregando
                        ? null
                        : () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                    child: Text(
                      isLogin ? 'Criar uma conta' : 'Já tenho uma conta',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
