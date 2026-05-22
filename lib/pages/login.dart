import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool loading = false;

  Future<void> cadastrar() async {

    try {

      setState(() => loading = true);

      await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado'),
        ),
      );

    } on AuthException catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );

    } finally {

      setState(() => loading = false);

    }
  }

  Future<void> login() async {

    try {

      setState(() => loading = true);

      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado'),
        ),
      );

    } on AuthException catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );

    } finally {

      setState(() => loading = false);

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Login Supabase'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: loading ? null : login,

                child: const Text('Entrar'),
              ),
            ),

            const SizedBox(height: 10),

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
    );
  }
}