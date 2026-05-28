import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'agendamentos.dart';
import 'dicas.dart';
import 'perfil.dart';
import 'teleconsulta.dart';
import 'notificacoes.dart';

class MedicoHomePage extends StatefulWidget {
  const MedicoHomePage({super.key});

  @override
  State<MedicoHomePage> createState() => _MedicoHomePageState();
}

class _MedicoHomePageState extends State<MedicoHomePage> {
  final supabase = Supabase.instance.client;

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

      mediaAvaliacao =
          ((profissional['avaliacao'] ?? 0) as num).round();

      final hoje =
          DateTime.now().toIso8601String().split('T')[0];

      final consultasHojeResponse = await supabase
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
          .eq('data_agendada', hoje);

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
        totalConsultasCompletadas =
            consultasCompletadasResponse.length;

        consultas =
            List<Map<String, dynamic>>.from(proximasConsultas);

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

  void _irParaMinhaAgenda() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MinhaAgendaPage(),
      ),
    );
  }

  void _irParaDicasSaude() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DicasSaudePage(),
      ),
    );
  }

  void _irParaPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PerfilMedicoPage(),
      ),
    );
  }

  void _irParaNotificacoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificacoesPage(),
      ),
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

  Future<int> _getNotificacoesNaoLidas() async {
    try {
      if (perfilId.isEmpty) return 0;

      final response = await supabase
          .from('notificacoes')
          .select('id')
          .eq('usuario_id', perfilId)
          .eq('lida', false);

      return response.length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      backgroundColor: const Color(0xfff5f7fa),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: carregarDados,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF3FA9C6),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Painel Médico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  nomeMedico.toUpperCase(),
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

          _buildDrawerItem(
            Icons.dashboard_outlined,
            'Visão geral',
            () {
              Navigator.pop(context);
            },
          ),

          _buildDrawerItem(
            Icons.calendar_today_outlined,
            'Minha agenda',
            () {
              Navigator.pop(context);
              _irParaMinhaAgenda();
            },
          ),

          _buildDrawerItem(
            Icons.video_call_outlined,
            'Teleconsulta',
            () {
              Navigator.pop(context);
            },
          ),

          _buildDrawerItem(
            Icons.health_and_safety_outlined,
            'Dicas de saúde',
            () {
              Navigator.pop(context);
              _irParaDicasSaude();
            },
          ),

          _buildDrawerItem(
            Icons.person_outline,
            'Meu perfil',
            () {
              Navigator.pop(context);
              _irParaPerfil();
            },
          ),

          _buildDrawerItem(
            Icons.logout_outlined,
            'Desconectar',
            () {
              Navigator.pop(context);
              _confirmLogout();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDestructive
                ? Colors.red
                : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              isDestructive
                  ? Colors.red
                  : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      title: const Text(
        'Área Médica',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        FutureBuilder<int>(
          future: _getNotificacoesNaoLidas(),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: _irParaNotificacoes,
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.all(4),
                      decoration:
                          const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
        'titulo': 'Avaliação',
        'valor': '$mediaAvaliacao ★',
        'icone': Icons.star,
        'cor': Colors.amber,
      },
      {
        'titulo': 'Concluídas',
        'valor':
            totalConsultasCompletadas.toString(),
        'icone': Icons.check_circle,
        'cor': Colors.green,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
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
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                card['icone'] as IconData,
                color: card['cor'] as Color,
                size: 32,
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: consultas.length,
          itemBuilder: (context, index) {
            final consulta = consultas[index];

            final paciente =
                consulta['perfis']
                        ?['nome_completo'] ??
                    'Paciente';

            final horario =
                consulta['horario_agendado'] ??
                    '--:--';

            return Container(
              margin:
                  const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        primaryColor.withOpacity(0.1),
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          paciente,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        Text(horario),
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