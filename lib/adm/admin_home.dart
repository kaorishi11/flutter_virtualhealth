import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'clinicas.dart';
import 'consultas.dart';
import 'mensagens.dart';
import 'profissionais.dart';
import 'usuarios.dart';
import '../services/auth_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final supabase = Supabase.instance.client;

  int totalUsuarios = 0;
  int consultasHoje = 0;
  int consultasConcluidas = 0;

  List<dynamic> consultasRecentes = [];

  @override
  void initState() {
    super.initState();
    carregarDashboard();
  }

  Future<void> carregarDashboard() async {
    try {
      final usuarios =
          await supabase.from('perfis').select('id');

      final consultasDia = await supabase
          .from('consultas')
          .select('id')
          .eq(
            'data_agendada',
            DateTime.now().toIso8601String().split('T')[0],
          );

      final concluidas = await supabase
          .from('consultas')
          .select('id')
          .eq('status', 'concluida');

      final recentes = await supabase
          .from('consultas')
          .select('''
            id,
            status,
            data_agendada,
            perfis!consultas_paciente_id_fkey(
              nome_completo
            )
          ''')
          .order('criado_em', ascending: false)
          .limit(5);

      setState(() {
        totalUsuarios = usuarios.length;
        consultasHoje = consultasDia.length;
        consultasConcluidas = concluidas.length;
        consultasRecentes = recentes;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;

      case 'concluida':
        return Colors.green;

      case 'cancelada':
        return Colors.red;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      backgroundColor: const Color(0xfff4f6f8),

      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
            ),
            const SizedBox(width: 10),
            const Text('Virtual Health'),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: carregarDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Bem-vindo, Admin 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  dashboardCard(
                    'Usuários',
                    totalUsuarios.toString(),
                    Icons.people,
                    Colors.teal,
                  ),

                  dashboardCard(
                    'Hoje',
                    consultasHoje.toString(),
                    Icons.calendar_today,
                    Colors.orange,
                  ),

                  dashboardCard(
                    'Concluídas',
                    consultasConcluidas.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mensal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'Gráfico aqui',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Consultas recentes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                itemCount:
                    consultasRecentes.length,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final consulta =
                      consultasRecentes[index];

                  final paciente =
                      consulta['perfis']
                              ?['nome_completo'] ??
                          'Paciente';

                  final status =
                      consulta['status'];

                  return Card(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(paciente),
                      subtitle: Text(status),
                      trailing: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: statusColor(
                              status),
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),
                        child: Text(
                          status,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 38, color: color),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
  return Drawer(
    child: ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.teal),
          child: Text(
            'Painel ADM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.pop(context);
            // Já está na dashboard
          },
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Usuários'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminUsuariosPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.medical_services),
          title: const Text('Profissionais'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminProfissionaisPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Consultas'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminConsultasPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.business),
          title: const Text('Clínicas'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminClinicasPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.mail),
          title: const Text('Mensagens'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminMensagensPage(),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sair', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await AuthService().logout();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          },
        ),
      ],
    ),
  );
}
}