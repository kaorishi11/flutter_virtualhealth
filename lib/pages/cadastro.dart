import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {

  final authService = AuthService();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final telefoneController = TextEditingController();

  String funcao = 'paciente';

  bool loading = false;

  Future<void> cadastrar() async {

    setState(() => loading = true);

    final erro = await authService.cadastrar(
      nome: nomeController.text,
      email: emailController.text,
      senha: senhaController.text,
      telefone: telefoneController.text,
      funcao: funcao,
    );

    setState(() => loading = false);

    if (erro != null) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro realizado'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Cadastro'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(

          child: Column(

            children: [

              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: funcao,

                items: const [

                  DropdownMenuItem(
                    value: 'paciente',
                    child: Text('Paciente'),
                  ),

                  DropdownMenuItem(
                    value: 'medico',
                    child: Text('Médico'),
                  ),

                ],

                onChanged: (value) {
                  setState(() {
                    funcao = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: loading ? null : cadastrar,

                  child: const Text('Cadastrar'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}