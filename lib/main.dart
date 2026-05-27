import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/cadastro.dart';
import 'pages/clinicas.dart';
import 'pages/contato.dart';

import '../adm/admin_home.dart';

import '../medico/medico_home.dart';
import '../medico/agendamentos.dart';
import '../medico/dicas.dart';
import '../medico/perfil.dart';
import '../medico/teleconsulta.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa locale pt_BR
  await initializeDateFormatting('pt_BR', null);

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
        primaryColor: const Color(0xFF3FA9C6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3FA9C6),
          primary: const Color(0xFF3FA9C6),
          secondary: const Color(0xFF81C784),
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xfff5f7fa),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3FA9C6),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/cadastro': (context) => const CadastroPage(),
        '/clinicas': (context) => const ClinicasPage(),
        '/contato': (context) => const ContatoPage(),
        '/admin': (context) => const AdminHomePage(),
        '/medico': (context) => const MedicoHomePage(),
        '/medico/agenda': (context) => const MinhaAgendaPage(),
        '/medico/dicas': (context) => const DicasSaudePage(),
        '/medico/perfil': (context) => const PerfilMedicoPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/medico/teleconsulta') {
          final args = settings.arguments as Map<String, dynamic>?;
          
          return MaterialPageRoute(
            builder: (context) => TeleconsultaPage(
              consultaId: args?['consultaId'] ?? '',
              pacienteNome: args?['pacienteNome'] ?? '',
              pacienteId: args?['pacienteId'] ?? '',
            ),
          );
        }
        return null;
      },
    );
  }
}