import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/cadastro.dart';
import 'pages/clinicas.dart';
import 'pages/contato.dart';
import 'pages/chatbot.dart';
import '../adm/admin_home.dart';
import '../medico/medico_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yxhvmckqfjymmrcognta.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4aHZtY2txZmp5bW1yY29nbnRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0MjAxNTcsImV4cCI6MjA5NDk5NjE1N30.KYEPDk5u8-rscXhLuDN2OIGi-w-STjFPhFFPe58LK6o',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Health',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF81C784),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/cadastro': (context) => const CadastroPage(),
        '/clinicas': (context) => const ClinicasPage(),
        '/contato': (context) => const ContatoPage(),
        '/chatbot': (context) => const ChatbotPage(),
        '/admin': (context) => const AdminHomePage(),
        '/medico': (context) => const MedicoHomePage(),
      },
    );
  }
}