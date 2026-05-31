import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'agendamentosMe.dart';
import 'dicas.dart';
import 'perfilMe.dart';
import 'teleconsultaMe.dart';

class MedicoHomePage extends StatefulWidget {
  const MedicoHomePage({super.key});

  @override
  State<MedicoHomePage> createState() => _MedicoHomePageState();
}

class _MedicoHomePageState extends State<MedicoHomePage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Dashboard';

  int consultasHoje = 0;
  int consultasPendentes = 0;
  int pacientesMes = 0;
  int mediaAvaliacao = 0;
  int totalConsultasCompletadas = 0;

  String nomeMedico = 'Médico';
  String especialidade = 'Médico';
  String profissionalId = '';
  String perfilId = '';

  List<Map<String, dynamic>> consultas = [];
  List<Map<String, dynamic>> consultasSemana = [];

  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();

  final Color primaryColor = const Color(0xFF3FA9C6);

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();

      perfilId = perfil['id'].toString();
      nomeMedico = perfil['nome_completo'] ?? 'Médico';

      final profissional = await supabase
          .from('profissionais')
          .select()
          .eq('perfil_id', perfilId)
          .single();

      profissionalId = profissional['id'].toString();

      especialidade = profissional['especialidade'] ?? 'Médico';

      mediaAvaliacao = ((profissional['avaliacao'] ?? 0) as num).round();

      final hoje = DateTime.now().toIso8601String().split('T')[0];

      final consultasHojeResponse = await supabase.from('consultas').select('''
            id,
            status,
            data_agendada,
            horario_agendado,
            modo,
            paciente_id,
            perfis:perfis!consultas_paciente_id_fkey(
              id,
              nome_completo
            )
          ''').eq('profissional_id', profissionalId).eq('data_agendada', hoje);

      final consultasPendentesResponse = await supabase
          .from('consultas')
          .select('id')
          .eq('profissional_id', profissionalId)
          .eq('status', 'pendente');

      final consultasCompletadasResponse = await supabase
          .from('consultas')
          .select('id')
          .eq('profissional_id', profissionalId)
          .eq('status', 'concluida');

      final proximasConsultas = await supabase
          .from('consultas')
          .select('''
            id,
            status,
            data_agendada,
            horario_agendado,
            modo,
            paciente_id,
            perfis:perfis!consultas_paciente_id_fkey(
              id,
              nome_completo
            )
          ''')
          .eq('profissional_id', profissionalId)
          .order('data_agendada')
          .order('horario_agendado');

      setState(() {
        consultasHoje = consultasHojeResponse.length;
        consultasPendentes = consultasPendentesResponse.length;
        totalConsultasCompletadas = consultasCompletadasResponse.length;

        consultas = List<Map<String, dynamic>>.from(proximasConsultas);

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro: $e');

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onPageChanged(String page) {
    setState(() {
      _currentPage = page;
    });

    if (page == 'Dashboard') {
      // Já está na dashboard
    } else if (page == 'Minha Agenda') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AgendamentosPacientesPage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Teleconsulta') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma consulta para iniciar a teleconsulta'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _currentPage = 'Dashboard';
      });
    } else if (page == 'Dicas de Saúde') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DicasSaudePage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Meu Perfil') {
      Navigator.push(
        context,
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Sair') {
      _confirmLogout();
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text(
            'Deseja realmente sair?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await supabase.auth.signOut();

                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _irParaTeleconsulta(
    String consultaId,
    String pacienteNome,
    String pacienteId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeleconsultaPage(
          consultaId: consultaId,
          pacienteNome: pacienteNome,
          pacienteId: pacienteId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      backgroundColor: const Color(0xfff5f7fa),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: carregarDados,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: isMobile ? 120 : 180,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(),
                            const SizedBox(height: 20),
                            _buildStatsGrid(),
                            const SizedBox(height: 20),
                            _buildTodayAppointments(),
                          ],
                        ),
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
    final navItems = [
      'Dashboard',
      'Minha Agenda',
      'Teleconsulta',
      'Dicas de Saúde',
      'Meu Perfil'
    ];

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
              icon: const Icon(Icons.menu, size: 28, color: Color(0xFF3FA9C6)),
            ),
            Image.asset(
              'assets/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.medical_services,
                    size: 50, color: Color(0xFF3FA9C6));
              },
            ),
            const SizedBox(width: 40),
          ],
        ),
      );
    }

    // Desktop layout
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
              return const Icon(Icons.medical_services,
                  size: 60, color: Color(0xFF3FA9C6));
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
                          color: isActive ? primaryColor : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isActive ? 24 : 0,
                        decoration: BoxDecoration(
                          color: primaryColor,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildDrawer() {
    final navItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard},
      {'title': 'Minha Agenda', 'icon': Icons.calendar_today},
      {'title': 'Teleconsulta', 'icon': Icons.video_call},
      {'title': 'Dicas de Saúde', 'icon': Icons.health_and_safety},
      {'title': 'Meu Perfil', 'icon': Icons.person},
    ];

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.medical_services,
                            size: 80, color: Colors.white);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nomeMedico,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      especialidade,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1),
            Expanded(
              child: ListView(
                children: [
                  ...navItems.map((item) => _buildDrawerItem(
                        item['title'] as String,
                        item['icon'] as IconData,
                        () {
                          Navigator.pop(context);
                          _onPageChanged(item['title'] as String);
                        },
                      )),
                  const Divider(color: Colors.white54, thickness: 1),
                  _buildDrawerItem('Sair', Icons.logout, () {
                    Navigator.pop(context);
                    _onPageChanged('Sair');
                  }, isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 18,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      splashColor: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, Dr(a). $nomeMedico',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            especialidade,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            DateFormat(
              "EEEE, d 'de' MMMM",
              'pt_BR',
            ).format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final statsCards = [
      {
        'titulo': 'Consultas hoje',
        'valor': consultasHoje.toString(),
        'icone': Icons.calendar_today,
        'cor': Colors.blue,
      },
      {
        'titulo': 'Pendentes',
        'valor': consultasPendentes.toString(),
        'icone': Icons.access_time,
        'cor': Colors.orange,
      },
      {
        'titulo': 'Concluídas',
        'valor': totalConsultasCompletadas.toString(),
        'icone': Icons.check_circle,
        'cor': Colors.green,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: statsCards.length,
      itemBuilder: (context, index) {
        final card = statsCards[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                card['icone'] as IconData,
                color: card['cor'] as Color,
                size: 32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card['valor'] as String,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    card['titulo'] as String,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayAppointments() {
    if (consultas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Nenhuma consulta agendada',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximas consultas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: consultas.length,
          itemBuilder: (context, index) {
            final consulta = consultas[index];

            final paciente = consulta['perfis']?['nome_completo'] ?? 'Paciente';

            final horario = consulta['horario_agendado'] ?? '--:--';

            final modo = consulta['modo'] ?? 'presencial';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      paciente[0].toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paciente,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(horario,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(width: 12),
                            Icon(
                                modo == 'online'
                                    ? Icons.videocam
                                    : Icons.location_on,
                                size: 14,
                                color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                                modo == 'online'
                                    ? 'Teleconsulta'
                                    : 'Presencial',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (modo == 'online')
                    ElevatedButton.icon(
                      onPressed: () => _irParaTeleconsulta(
                        consulta['id'].toString(),
                        paciente,
                        consulta['paciente_id'].toString(),
                      ),
                      icon: const Icon(Icons.video_call, size: 16),
                      label: const Text('Iniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
