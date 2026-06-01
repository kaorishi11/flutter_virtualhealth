import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virtualhealth/medico/medico_bottom_nav_bar.dart';
import 'package:virtualhealth/services/auth_service.dart';
import 'package:virtualhealth/medico/teleconsultaMe.dart';

class AgendamentosPacientesPage extends StatefulWidget {
  const AgendamentosPacientesPage({super.key});

  @override
  State<AgendamentosPacientesPage> createState() =>
      _AgendamentosPacientesPageState();
}

class _AgendamentosPacientesPageState extends State<AgendamentosPacientesPage> {
  final AuthService _auth = AuthService();

  DateTime _dataSelecionada = DateTime.now();
  String _filtroTipo = 'Todos';

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userName;
  String? _userTipo;
  Map<String, dynamic>? _userProfile;

  final List<String> _tiposFiltro = ['Todos', 'Teleconsulta', 'Presencial'];

  // Dados mockados de agendamentos do médico
  final List<Map<String, dynamic>> _mockAppointments = [
    {
      'id': '1',
      'paciente': 'Maria Helena',
      'pacienteId': 'pac_001',
      'descricao': 'Revisão de lentes',
      'tipo': 'Teleconsulta',
      'horario': '08:00',
      'duracao': '30 min',
      'status': 'confirmado',
      'isPrimeiraConsulta': true,
    },
    {
      'id': '2',
      'paciente': 'Gabriel Jorge',
      'pacienteId': 'pac_002',
      'descricao': 'Check-up visual',
      'tipo': 'Presencial',
      'horario': '10:20',
      'duracao': '30 min',
      'status': 'confirmado',
      'isPrimeiraConsulta': false,
    },
    {
      'id': '3',
      'paciente': 'Ana Beatriz',
      'pacienteId': 'pac_003',
      'descricao': 'Consulta de rotina',
      'tipo': 'Teleconsulta',
      'horario': '14:30',
      'duracao': '30 min',
      'status': 'confirmado',
      'isPrimeiraConsulta': false,
    },
    {
      'id': '4',
      'paciente': 'Carlos Eduardo',
      'pacienteId': 'pac_004',
      'descricao': 'Retorno de cirurgia',
      'tipo': 'Presencial',
      'horario': '16:00',
      'duracao': '45 min',
      'status': 'confirmado',
      'isPrimeiraConsulta': false,
    },
  ];

  List<Map<String, dynamic>> _filteredAppointments = [];

  // Paleta de cores do Virtual Health (centralizada)
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color deepOcean = Color(0xFF0D2C33);
  static const Color actionTeal = Color(0xFF0F766E);
  static const Color backgroundWhite = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color secondaryTealSoft = Color(0xFFEDF7F6);
  static const Color mutedText = Color(0xFF6B7280);
  static const Color borderLight = Color(0x3314B8A6);
  
  // Cores de status
  static const Color statusConfirmed = Color(0xFF10B981);
  static const Color statusWaiting = Color(0xFFF59E0B);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color badgePurple = Color(0xFF8B5CF6);
  static const Color badgeBlue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _filtrarAgendamentos();
  }

  Future<void> _checkAuthState() async {
    if (!mounted) return;

    try {
      final isLoggedIn = _auth.isLoggedIn;
      if (isLoggedIn) {
        final profile = await _auth.getPerfilUsuario();
        if (profile != null && mounted) {
          setState(() {
            _isLoggedIn = true;
            _userProfile = profile;
            _userName = profile['nome']?.split(' ')[0] ?? 'Médico';
            _userTipo = profile['tipo'] ?? 'medico';
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar auth: $e');
    }
  }

  void _filtrarAgendamentos() {
    setState(() {
      _filteredAppointments = _mockAppointments.where((app) {
        if (_filtroTipo != 'Todos') {
          return app['tipo'] == _filtroTipo;
        }
        return true;
      }).toList();
    });
  }

  void _mudarData(int days) {
    setState(() {
      _dataSelecionada = _dataSelecionada.add(Duration(days: days));
    });
  }

  void _iniciarTeleconsulta(Map<String, dynamic> appointment) {
    final consultaId = appointment['id']?.toString() ?? '';
    final pacienteNome = appointment['paciente']?.toString() ?? 'Paciente';
    final pacienteId = appointment['pacienteId']?.toString() ?? '';

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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar', style: TextStyle(color: deepOcean, fontWeight: FontWeight.bold)),
        content: const Text('Tem certeza que deseja sair?', style: TextStyle(color: mutedText)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: mutedText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryTeal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      _userName != null && _userName!.isNotEmpty
                          ? _userName![0].toUpperCase()
                          : 'M',
                      style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _userProfile?['nome'] ?? 'Médico',
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: deepOcean,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _getTipoDisplay(_userTipo),
                  style: TextStyle(color: mutedText),
                ),
                const SizedBox(height: 20),
                Divider(color: borderLight, thickness: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: secondaryTealSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_outline, color: primaryTeal, size: 20),
                  ),
                  title: const Text('Meu Perfil', style: TextStyle(color: deepOcean)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/medico/perfil');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: secondaryTealSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.health_and_safety, color: primaryTeal, size: 20),
                  ),
                  title: const Text('Dicas de Saúde', style: TextStyle(color: deepOcean)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/medico/dicas');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusCancelled.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout, color: statusCancelled, size: 20),
                  ),
                  title: const Text('Sair', style: TextStyle(color: statusCancelled)),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTipoDisplay(String? tipo) {
    switch (tipo) {
      case 'paciente':
        return 'Paciente';
      case 'medico':
        return 'Médico';
      case 'admin':
        return 'Administrador';
      default:
        return 'Médico';
    }
  }

  String _formatarDataPersonalizada() {
    const meses = [
      'JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO',
      'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO'
    ];

    const dias = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

    final diaSemana = dias[_dataSelecionada.weekday - 1];
    final dia = _dataSelecionada.day;
    final mes = meses[_dataSelecionada.month - 1];

    return '$diaSemana – $dia DE $mes';
  }

  String _formatarHorario(String horario) {
    return horario.replaceFirst(':', 'H');
  }

  // Função auxiliar para criar cor com opacidade
  Color _colorWithOpacity(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'MINHA AGENDA',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: deepOcean,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildDataHeader(),
          _buildFiltros(),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredAppointments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredAppointments.length,
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _buildAppointmentCard(_filteredAppointments[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: MedicoBottomNavBar(
        currentIndex: 1,
        onProfileTap: () {
          _showUserMenu();
        },
      ),
    );
  }

  Widget _buildDataHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: cardWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryTealSoft, cardWhite],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderLight, width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: () => _mudarData(-1),
              color: primaryTeal,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [deepOcean, actionTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: deepOcean.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _formatarDataPersonalizada(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryTealSoft, cardWhite],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderLight, width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right, size: 28),
              onPressed: () => _mudarData(1),
              color: primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cardWhite,
      child: Row(
        children: _tiposFiltro.map((tipo) {
          final isSelected = _filtroTipo == tipo;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(tipo),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filtroTipo = tipo;
                  _filtrarAgendamentos();
                });
              },
              backgroundColor: secondaryTealSoft,
              selectedColor: _colorWithOpacity(primaryTeal, 0.15),
              checkmarkColor: primaryTeal,
              labelStyle: TextStyle(
                color: isSelected ? primaryTeal : mutedText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? primaryTeal : borderLight,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: secondaryTealSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_busy, size: 64, color: primaryTeal.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma consulta agendada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: deepOcean),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione outra data ou aguarde novos agendamentos',
            style: TextStyle(fontSize: 14, color: mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final isOnline = appointment['tipo'] == 'Teleconsulta';
    final isPrimeiraConsulta = appointment['isPrimeiraConsulta'] == true;
    final isConfirmado = appointment['status'] == 'confirmado';
    final podeIniciar = isOnline && isConfirmado;

    final pacienteNome = appointment['paciente']?.toString() ?? 'Paciente';
    final descricao = appointment['descricao']?.toString() ?? 'Consulta';
    final horario = appointment['horario']?.toString() ?? '00:00';
    final duracao = appointment['duracao']?.toString() ?? '30 min';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do card com horário e status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryTeal.withOpacity(0.08), secondaryTealSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderLight, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 16, color: primaryTeal),
                      const SizedBox(width: 6),
                      Text(
                        _formatarHorario(horario),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: deepOcean,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        duracao,
                        style: TextStyle(fontSize: 12, color: mutedText),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusConfirmed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusConfirmed.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusConfirmed,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Confirmado',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusConfirmed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: secondaryTealSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 20,
                        color: primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pacienteNome,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: deepOcean,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            descricao,
                            style: TextStyle(fontSize: 13, color: mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isPrimeiraConsulta)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: badgePurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: badgePurple.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, size: 12, color: badgePurple),
                            const SizedBox(width: 4),
                            Text(
                              '1ª consulta',
                              style: TextStyle(
                                fontSize: 11,
                                color: badgePurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? primaryTeal.withOpacity(0.1)
                            : badgeBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOnline ? primaryTeal.withOpacity(0.3) : badgeBlue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOnline ? Icons.videocam : Icons.location_on,
                            size: 12,
                            color: isOnline ? primaryTeal : badgeBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment['tipo'] ?? 'Presencial',
                            style: TextStyle(
                              fontSize: 11,
                              color: isOnline ? primaryTeal : badgeBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (podeIniciar) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _iniciarTeleconsulta(appointment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.white.withOpacity(0.2);
                            }
                            return null;
                          },
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Iniciar Chamada',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}