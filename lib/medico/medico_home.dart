import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'agendamentosMe.dart';
import 'dicas.dart';
import 'perfilMe.dart';
import 'teleconsultaMe.dart';
import 'medico_bottom_nav_bar.dart';

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

  // CORREÇÃO: Usando a paleta de cores do Virtual Health
  final Color primaryColor = const Color(0xFF14B8A6); // Teal
  final Color secondaryColor = const Color(0xFF0D2C33); // Dark teal
  final Color backgroundColor = const Color(0xFFF8FAFC); // Light gray
  final Color cardColor = Colors.white;

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

      // CORREÇÃO: Usando a tabela 'usuarios' em vez de 'perfis'
      final usuario = await supabase
          .from('usuarios')
          .select()
          .eq('id', user.id)
          .single();

      perfilId = usuario['id'].toString();
      nomeMedico = usuario['nome'] ?? 'Médico';
      especialidade = usuario['especialidade'] ?? 'Médico';

      setState(() {
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
        MaterialPageRoute(
            builder: (context) => const AgendamentosPacientesPage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    } else if (page == 'Teleconsulta') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma consulta para iniciar a teleconsulta'),
          backgroundColor: Color(0xFF14B8A6),
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
        MaterialPageRoute(builder: (context) => const PerfilMedicoPage()),
      ).then((_) {
        setState(() {
          _currentPage = 'Dashboard';
        });
      });
    }
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
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: carregarDados,
        color: primaryColor,
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
                  child: CircularProgressIndicator(
                    color: Color(0xFF14B8A6),
                  ),
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
      bottomNavigationBar: MedicoBottomNavBar(
        currentIndex: 0,
        onProfileTap: () {
          Navigator.pushNamed(context, '/medico/perfil');
        },
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
            colors: [secondaryColor, secondaryColor.withOpacity(0.9)],
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
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            size: 50,
                            color: Colors.white,
                          ),
                        );
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
            primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
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
        'cor': primaryColor,
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
      {
        'titulo': 'Avaliação',
        'valor': '★ $mediaAvaliacao',
        'icone': Icons.star,
        'cor': Colors.amber,
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
            color: cardColor,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (card['cor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  card['icone'] as IconData,
                  color: card['cor'] as Color,
                  size: 24,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card['valor'] as String,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card['titulo'] as String,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
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
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Próximas consultas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2C33),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AgendamentosPacientesPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: consultas.length > 5 ? 5 : consultas.length,
          itemBuilder: (context, index) {
            final consulta = consultas[index];

            final paciente = consulta['perfis']?['nome_completo'] ?? 
                            consulta['perfis']?['nome'] ?? 'Paciente';

            final horario = consulta['horario_agendado'] ?? '--:--';
            final data = consulta['data_agendada'] ?? '';
            final modo = consulta['modo'] ?? 'presencial';
            final status = consulta['status'] ?? 'pendente';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      paciente.isNotEmpty ? paciente[0].toUpperCase() : 'P',
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
                            color: Color(0xFF0D2C33),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy').parse(data).isAfter(DateTime.now().subtract(const Duration(days: 1)))
                                  ? data
                                  : 'Hoje',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 11),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time,
                                size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(horario,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 11)),
                            const SizedBox(width: 12),
                            Icon(
                                modo == 'online'
                                    ? Icons.videocam
                                    : Icons.location_on,
                                size: 12,
                                color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                                modo == 'online'
                                    ? 'Teleconsulta'
                                    : 'Presencial',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 11)),
                          ],
                        ),
                        if (status == 'pendente')
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Pendente',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (modo == 'online' && status == 'pendente')
                    ElevatedButton(
                      onPressed: () => _irParaTeleconsulta(
                        consulta['id'].toString(),
                        paciente,
                        consulta['paciente_id'].toString(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.video_call, size: 16),
                          SizedBox(width: 4),
                          Text('Iniciar'),
                        ],
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