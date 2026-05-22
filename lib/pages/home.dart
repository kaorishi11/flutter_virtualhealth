import 'package:flutter/material.dart';
import 'package:virtualhealth/services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.usuarioAtual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Bem-vindo!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text('Email: ${user?.email ?? ''}'),
            const SizedBox(height: 5),
            Text('ID: ${user?.id ?? ''}'),
          ],
        ),
      ),
    );
  }
}