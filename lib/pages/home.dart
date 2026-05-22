import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    final authService = AuthService();

    return Scaffold(

      appBar: AppBar(

        title: const Text('Sistema Médico'),

        actions: [

          IconButton(

            onPressed: () async {

              await authService.logout();

              Navigator.pop(context);

            },

            icon: const Icon(Icons.logout),
          ),

        ],
      ),

      body: const Center(
        child: Text('Usuário logado'),
      ),
    );
  }
}