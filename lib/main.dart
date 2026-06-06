import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pedido_screen.dart';
import 'screens/novo_pedido_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Balsas Entregas LTDA',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home_vendedor': (context) => const HomeScreen(),
        '/home_entregador': (context) => const PedidoScreen(),
        '/novo_pedido': (context) => const NovoPedidoScreen(),
      },
    );
  }
}
