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

  // Paleta de cores do Virtual Health
  final Color primaryColor = const Color(0xFF14B8A6);
  final Color secondaryColor = const Color(0xFF0D2C33);
  final Color backgroundColor = const Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;

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
        title: const Text('Desconectar'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sair', style: TextStyle(color: Color(0xFF14B8A6)))),
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
      backgroundColor: Colors.white,
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: primaryColor,
                  child: Text(
                    _userName != null && _userName!.isNotEmpty
                        ? _userName![0].toUpperCase()
                        : 'M',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _userProfile?['nome'] ?? 'Médico',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _getTipoDisplay(_userTipo),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline,
                      color: Color(0xFF14B8A6)),
                  title: const Text('Meu Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/medico/perfil');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.health_and_safety,
                      color: Color(0xFF14B8A6)),
                  title: const Text('Dicas de Saúde'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/medico/dicas');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('Sair', style: TextStyle(color: Colors.red)),
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
      'JANEIRO',
      'FEVEREIRO',
      'MARÇO',
      'ABRIL',
      'MAIO',
      'JUNHO',
      'JULHO',
      'AGOSTO',
      'SETEMBRO',
      'OUTUBRO',
      'NOVEMBRO',
      'DEZEMBRO'
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

  // Função auxiliar para criar cor com opacidade (compatível com Flutter Web)
  Color _colorWithOpacity(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('MINHA AGENDA'),
        backgroundColor: secondaryColor,
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
                      return _buildAppointmentCard(
                          _filteredAppointments[index]);
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
      color: cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => _mudarData(-1),
            color: primaryColor,
          ),
          Text(
            _formatarDataPersonalizada(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 28),
            onPressed: () => _mudarData(1),
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cardColor,
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
              backgroundColor: Colors.grey[100],
              selectedColor: _colorWithOpacity(primaryColor, 0.1),
              checkmarkColor: primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? primaryColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? primaryColor : Colors.transparent,
                  width: 1,
                ),
              ),
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
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma consulta agendada',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione outra data ou aguarde novos agendamentos',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _colorWithOpacity(Colors.black, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _colorWithOpacity(primaryColor, 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      _formatarHorario(horario),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      duracao,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorWithOpacity(Colors.green, 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Confirmado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pacienteNome,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (isPrimeiraConsulta)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _colorWithOpacity(Colors.purple, 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '1ª consulta',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.purple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? _colorWithOpacity(primaryColor, 0.1)
                            : _colorWithOpacity(Colors.blue, 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOnline ? Icons.videocam : Icons.location_on,
                            size: 10,
                            color: isOnline ? primaryColor : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment['tipo'] ?? 'Presencial',
                            style: TextStyle(
                              fontSize: 10,
                              color: isOnline ? primaryColor : Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (podeIniciar) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _iniciarTeleconsulta(appointment),
                      icon: const Icon(Icons.videocam, size: 18),
                      label: const Text('Iniciar Chamada'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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