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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Dashboard';

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
      final usuarios = await supabase.from('perfis').select('id');

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

  void _onPageChanged(String page) {
    setState(() {
      _currentPage = page;
    });

    if (page == 'Dashboard') {
      // Já está na dashboard
    } else if (page == 'Usuários') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminUsuariosPage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Profissionais') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminProfissionaisPage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Consultas') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminConsultasPage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Clínicas') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminClinicasPage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Mensagens') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminMensagensPage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Sair') {
      _confirmLogout();
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      backgroundColor: const Color(0xfff4f6f8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: isMobile ? 120 : 180,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bem-vindo, Admin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isMobile ? 2 : 3,
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
                          'Consultas Hoje',
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estatísticas Mensais',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'Gráfico em desenvolvimento',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Consultas Recentes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      itemCount: consultasRecentes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final consulta = consultasRecentes[index];
                        final paciente = consulta['perfis']?['nome_completo'] ?? 'Paciente';
                        final status = consulta['status'];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(paciente),
                            subtitle: Text(consulta['data_agendada']?.split('T')[0] ?? 'Data não definida'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor(status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopNavigationBar(isMobile),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopNavigationBar(bool isMobile) {
    final navItems = ['Dashboard', 'Usuários', 'Profissionais', 'Consultas', 'Clínicas', 'Mensagens'];

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: const Icon(Icons.menu, size: 28, color: Colors.teal),
            ),
            Image.asset(
              'assets/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.medical_services, size: 50, color: Colors.teal);
              },
            ),
            Container(width: 40),
          ],
        ),
      );
    }

    // Desktop layout - estilo igual à home
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.medical_services, size: 60, color: Colors.teal);
            },
          ),
          Row(
            children: navItems.map((item) {
              final isActive = _currentPage == item;
              return GestureDetector(
                onTap: () => _onPageChanged(item),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.teal : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isActive ? 24 : 0,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _confirmLogout(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 38, color: color),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal, Colors.tealAccent],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.medical_services, size: 80, color: Colors.white);
                  },
                ),
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem('Dashboard', Icons.dashboard, () {
                    Navigator.pop(context);
                    _onPageChanged('Dashboard');
                  }),
                  _buildDrawerItem('Usuários', Icons.people, () {
                    Navigator.pop(context);
                    _onPageChanged('Usuários');
                  }),
                  _buildDrawerItem('Profissionais', Icons.medical_services, () {
                    Navigator.pop(context);
                    _onPageChanged('Profissionais');
                  }),
                  _buildDrawerItem('Consultas', Icons.calendar_today, () {
                    Navigator.pop(context);
                    _onPageChanged('Consultas');
                  }),
                  _buildDrawerItem('Clínicas', Icons.business, () {
                    Navigator.pop(context);
                    _onPageChanged('Clínicas');
                  }),
                  _buildDrawerItem('Mensagens', Icons.mail, () {
                    Navigator.pop(context);
                    _onPageChanged('Mensagens');
                  }),
                  const Divider(color: Colors.white54, thickness: 1),
                  _buildDrawerItem('Sair', Icons.logout, () {
                    Navigator.pop(context);
                    _onPageChanged('Sair');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      splashColor: Colors.white.withOpacity(0.2),
    );
  }
}