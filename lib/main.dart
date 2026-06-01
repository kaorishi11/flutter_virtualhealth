import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:virtualhealth/pages/agendamentos.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/cadastro.dart';
import 'pages/clinicas.dart';
import 'pages/contato.dart';
import 'pages/chatbot.dart';
import 'pages/teleconsulta.dart';
import 'pages/termos_uso.dart';
import 'pages/privacidade.dart';
import 'pages/perfil.dart';
import 'pages/agendamentos.dart'; // Paciente

import 'adm/admin_home.dart';
import 'adm/usuarios.dart';
import 'adm/consultas.dart';
import 'adm/clinicas.dart';
import 'adm/mensagens.dart';
import 'adm/profissionais.dart';

import 'medico/medico_home.dart';
import 'medico/agendamentosMe.dart';
import 'medico/dicas.dart';
import 'medico/perfilMe.dart';
import 'medico/teleconsultaMe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();
  await initializeDateFormatting('pt_BR', null);

  await Supabase.initialize(
    url: 'https://zswqxvhkchazgupmaigw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpzd3F4dmhrY2hhemd1cG1haWd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNzg3MzksImV4cCI6MjA5NTY1NDczOX0.2Bef2OgOpdAC76YP2So4q7m-MKRsSrxvfTVtRseQLG8',
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
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/cadastro': (context) => const CadastroPage(),
        '/clinicas': (context) => const ClinicasPage(),
        '/contato': (context) => const ContatoPage(),
        '/chatbot': (context) => const ChatbotPage(),
        '/teleconsulta': (context) => const TeleconsultaPacientePage(),
        '/perfil': (context) => const ConfigPerfilPage(),
        '/agendamentos': (context) => const AgendamentosMedicosPage(),
        '/termos-uso': (context) => const TermosUsoPage(),
        '/privacidade': (context) => const PrivacidadePage(),
        '/admin': (context) => const AdminHomePage(),
        '/medico': (context) => const MedicoHomePage(),
        '/medico/agendamentos': (context) => const AgendamentosPacientesPage(),
        '/medico/dicas': (context) => const DicasSaudePage(),
        '/medico/perfil': (context) => const PerfilMedicoPage(),
        '/admin-usuarios': (context) => const AdminUsuariosPage(),
        '/admin-consultas': (context) => const AdminConsultasPage(),
        '/admin-clinicas': (context) => const AdminClinicasPage(),
        '/admin-mensagens': (context) => const AdminMensagensPage(),
        '/admin-profissionais': (context) => const AdminProfissionaisPage(),
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
