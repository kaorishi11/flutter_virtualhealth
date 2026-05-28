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

  // Métricas reais
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

      // 1. Buscar perfil do médico
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();
      
      perfilId = perfil['id'] as String;
      nomeMedico = perfil['nome_completo'] ?? 'Médico';

      // 2. Buscar dados profissionais
      final profissional = await supabase
          .from('profissionais')
          .select()
          .eq('perfil_id', perfilId)
          .single();
      
      profissionalId = profissional['id'] as String;
      especialidade = profissional['especialidade'] ?? 'Médico';
      mediaAvaliacao = (profissional['avaliacao'] ?? 0).round();

      // 3. Data de hoje formatada
      final hoje = DateTime.now().toIso8601String().split('T')[0];
      final primeiroDiaMes = DateTime(DateTime.now().year, DateTime.now().month, 1)
          .toIso8601String().split('T')[0];
      final ultimoDiaMes = DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
          .toIso8601String().split('T')[0];

      // 4. Buscar consultas de hoje
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

      // 5. Buscar consultas pendentes
      final consultasPendentesResponse = await supabase
          .from('consultas')
          .select('id')
          .eq('profissional_id', profissionalId)
          .eq('status', 'pendente');
      
      consultasPendentes = consultasPendentesResponse.length;

      // 6. Buscar pacientes únicos do mês
      final pacientesMesResponse = await supabase
          .from('consultas')
          .select('paciente_id')
          .eq('profissional_id', profissionalId)
          .gte('data_agendada', primeiroDiaMes)
          .lte('data_agendada', ultimoDiaMes);
      
      final pacientesUnicos = pacientesMesResponse.map((c) => c['paciente_id']).toSet();
      pacientesMes = pacientesUnicos.length;

      // 7. Buscar total de consultas completadas
      final consultasCompletadasResponse = await supabase
          .from('consultas')
          .select('id')
          .eq('profissional_id', profissionalId)
          .eq('status', 'concluida');
      
      totalConsultasCompletadas = consultasCompletadasResponse.length;

      // 8. Buscar próximas consultas
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
          .gte('data_agendada', hoje)
          .order('data_agendada', ascending: true)
          .order('horario_agendado', ascending: true)
          .limit(10);

      // 9. Buscar consultas da semana para o gráfico
      final inicioSemana = _getStartOfWeek(DateTime.now());
      final diasSemana = List.generate(7, (i) => 
        inicioSemana.add(Duration(days: i)).toIso8601String().split('T')[0]
      );
      
      final consultasSemanaResponse = await supabase
          .from('consultas')
          .select('data_agendada')
          .eq('profissional_id', profissionalId)
          .inFilter('data_agendada', diasSemana);
      
      // Processar dados da semana
      final Map<String, int> consultasPorDia = {};
      for (var dia in diasSemana) {
        consultasPorDia[dia] = 0;
      }
      for (var consulta in consultasSemanaResponse) {
        final data = consulta['data_agendada'] as String;
        consultasPorDia[data] = (consultasPorDia[data] ?? 0) + 1;
      }
      
      final diasNomes = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      consultasSemana = [];
      for (int i = 0; i < diasSemana.length; i++) {
        consultasSemana.add({
          'dia': diasNomes[i],
          'qtd': consultasPorDia[diasSemana[i]] ?? 0,
          'data': diasSemana[i],
        });
      }

      setState(() {
        consultasHoje = consultasHojeResponse.length;
        consultas = proximasConsultas.cast<Map<String, dynamic>>();
        isLoading = false;
      });
      
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    final daysToSubtract = dayOfWeek - DateTime.monday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  void _irParaMinhaAgenda() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MinhaAgendaPage()),
    ).then((_) => carregarDados());
  }

  void _irParaDicasSaude() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DicasSaudePage()),
    );
  }

  void _irParaPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilMedicoPage()),
    ).then((_) => carregarDados());
  }

  void _irParaTeleconsulta(String consultaId, String pacienteNome, String pacienteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeleconsultaPage(
          consultaId: consultaId,
          pacienteNome: pacienteNome,
          pacienteId: pacienteId,
        ),
      ),
    ).then((_) => carregarDados());
  }

  void _iniciarPrimeiraTeleconsulta() {
    final teleconsulta = consultas.firstWhere(
      (c) => c['modo'] == 'teleconsulta' && c['status'] == 'confirmada',
      orElse: () => {},
    );

    if (teleconsulta.isNotEmpty) {
      _irParaTeleconsulta(
        teleconsulta['id'],
        teleconsulta['perfis']?['nome_completo'] ?? 'Paciente',
        teleconsulta['perfis']?['id'] ?? '',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma teleconsulta confirmada disponível'),
        ),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
    } catch (e) {
      return 0;
    }
  }

  void _irParaNotificacoes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificacoesPage()),
    ).then((_) => carregarDados());
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
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 20),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildCalendarSection(),
                    const SizedBox(height: 20),
                    _buildTodayAppointments(),
                    const SizedBox(height: 20),
                    if (consultasSemana.isNotEmpty) _buildWeeklyAppointments(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
<<<<<<< HEAD
      child: ListView(
        children: const [
          DrawerHeader(
            decoration:
                BoxDecoration(
              color:
                  Color(0xFF3FA9C6),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Icon(
                  Icons.medical_services,
                  color:
                      Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  'Painel Médico',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
=======
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
>>>>>>> 93fff73856976b72d6e7d9bcaaafc2484bfbf6a1
                  ),
                  child: Icon(Icons.medical_services, color: primaryColor, size: 32),
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
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$mediaAvaliacao ($totalConsultasCompletadas)',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDrawerItem(Icons.dashboard_outlined, 'Visão geral', () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.calendar_today_outlined, 'Minha agenda', () {
            Navigator.pop(context);
            _irParaMinhaAgenda();
          }),
          const Divider(),
          _buildDrawerItem(
            Icons.video_call_outlined,
            'Iniciar consulta',
            () {
              Navigator.pop(context);
              _iniciarPrimeiraTeleconsulta();
            },
          ),
          _buildDrawerItem(Icons.health_and_safety_outlined, 'Dicas de saúde', () {
            Navigator.pop(context);
            _irParaDicasSaude();
          }),
          const Spacer(),
          _buildDrawerItem(Icons.person_outline, 'Meu perfil', () {
            Navigator.pop(context);
            _irParaPerfil();
          }),
          const Divider(),
          _buildDrawerItem(Icons.logout_outlined, 'Desconectar', () {
            Navigator.pop(context);
            _confirmLogout();
          }, isDestructive: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

<<<<<<< HEAD
          ListTile(
            leading:
                Icon(Icons.home),
            title:
                Text('Dashboard'),
=======
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.medical_services, color: Color(0xFF3FA9C6), size: 24),
            ),
>>>>>>> 93fff73856976b72d6e7d9bcaaafc2484bfbf6a1
          ),
          const SizedBox(width: 10),
          const Text('Área Médica'),
        ],
      ),
      actions: [
        FutureBuilder<int>(
          future: _getNotificacoesNaoLidas(),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: _irParaNotificacoes,
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

<<<<<<< HEAD
          ListTile(
            leading:
                Icon(Icons.calendar_today),
            title:
                Text('Consultas'),
          ),

          ListTile(
            leading:
                Icon(Icons.people),
            title:
                Text('Pacientes'),
          ),

          ListTile(
            leading:
                Icon(Icons.logout),
            title: Text('Sair'),
=======
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          const SizedBox(height: 4),
          Text(
            especialidade,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.today, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
>>>>>>> 93fff73856976b72d6e7d9bcaaafc2484bfbf6a1
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final statsCards = [
      {'titulo': 'Consultas hoje', 'valor': consultasHoje.toString(), 'icone': Icons.calendar_today, 'cor': Colors.blue},
      {'titulo': 'Pacientes no mês', 'valor': pacientesMes.toString(), 'icone': Icons.people, 'cor': Colors.teal},
      {'titulo': 'Pendentes', 'valor': consultasPendentes.toString(), 'icone': Icons.access_time, 'cor': Colors.orange},
      {'titulo': 'Avaliação', 'valor': '$mediaAvaliacao ★', 'icone': Icons.star, 'cor': Colors.amber},
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(card['icone'] as IconData, color: card['cor'] as Color, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card['valor'] as String,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    card['titulo'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Calendário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _irParaMinhaAgenda,
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _buildSimpleCalendar(),
        ),
      ],
    );
  }

  Widget _buildSimpleCalendar() {
    final daysOfWeek = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    List<DateTime?> days = [];
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(selectedDate.year, selectedDate.month, i));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy', 'pt_BR').format(selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isToday = day != null &&
                  day.day == DateTime.now().day &&
                  day.month == DateTime.now().month &&
                  day.year == DateTime.now().year;

              if (index < 7) {
                return Center(
                  child: Text(
                    daysOfWeek[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: daysOfWeek[index] == 'DOM' ? Colors.red : Colors.grey[600],
                    ),
                  ),
                );
              }

              if (day == null) {
                return const SizedBox();
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    focusedDay = day;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? primaryColor.withOpacity(0.3)
                        : (focusedDay.day == day.day && focusedDay.month == day.month
                            ? primaryColor
                            : null),
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: focusedDay.day == day.day && focusedDay.month == day.month
                            ? Colors.white
                            : (isToday ? primaryColor : Colors.black87),
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments() {
    final hoje = DateTime.now().toIso8601String().split('T')[0];
    final consultasHojeList = consultas.where((c) => c['data_agendada'] == hoje).toList();

    if (consultasHojeList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Consultas de hoje', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Nenhuma consulta hoje', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Consultas de hoje', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _irParaMinhaAgenda,
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: consultasHojeList.length > 4 ? 4 : consultasHojeList.length,
          itemBuilder: (context, index) {
            final consulta = consultasHojeList[index];
            final paciente = consulta['perfis']?['nome_completo'] ?? 'Paciente';
            final pacienteId = consulta['perfis']?['id'] ?? '';
            final horario = consulta['horario_agendado'] ?? '--:--';
            final modo = consulta['modo'] ?? 'presencial';
            final status = consulta['status'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getIniciais(paciente),
                        style: const TextStyle(
                          color: Color(0xFF3FA9C6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(paciente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_getStatusText(status), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(horario.substring(0, 5), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: modo == 'teleconsulta' ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              modo == 'teleconsulta' ? 'Online' : 'Presencial',
                              style: TextStyle(fontSize: 10, color: modo == 'teleconsulta' ? Colors.purple : Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(status, modo, consulta['id'], paciente, pacienteId),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String? status, String? modo, String consultaId, String pacienteNome, String pacienteId) {
    if (modo == 'teleconsulta' && status == 'confirmada') {
      return ElevatedButton(
        onPressed: () => _irParaTeleconsulta(consultaId, pacienteNome, pacienteId),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Iniciar', style: TextStyle(fontSize: 10)),
      );
    } else if (modo == 'teleconsulta') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Online', style: TextStyle(fontSize: 10, color: Color(0xFF3FA9C6), fontWeight: FontWeight.w500)),
      );
    } else {
      return TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
        child: const Text('Ver', style: TextStyle(fontSize: 10)),
      );
    }
  }

  Widget _buildWeeklyAppointments() {
    if (consultasSemana.isEmpty) return const SizedBox();

    final maxQtd = consultasSemana.map((d) => d['qtd'] as int).reduce((a, b) => a > b ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Consultas da semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: consultasSemana.map((day) {
              final qtd = day['qtd'] as int;
              final double altura = maxQtd > 0 ? (qtd / maxQtd) * 40 : 0;
              
              return Column(
                children: [
                  Text(day['dia'] as String, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 36,
                    height: 48,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (qtd > 0)
                          Container(
                            width: 24,
                            height: altura,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          qtd.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: qtd > 0 ? primaryColor : Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getIniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.isEmpty) return 'P';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pendente': return 'Pendente';
      case 'concluida': return 'Concluída';
      case 'cancelada': return 'Cancelada';
      case 'confirmada': return 'Confirmada';
      case 'agendada': return 'Agendada';
      default: return status ?? 'Agendada';
    }
  }
}