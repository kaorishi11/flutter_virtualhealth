import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virtualhealth/widgets/custom_bottom_nav_bar.dart';
import 'package:virtualhealth/services/auth_service.dart';

class AgendamentosMedicosPage extends StatefulWidget {
  const AgendamentosMedicosPage({super.key});

  @override
  State<AgendamentosMedicosPage> createState() => _AgendamentosMedicosPageState();
}

class _AgendamentosMedicosPageState extends State<AgendamentosMedicosPage> {
  final AuthService _auth = AuthService();
  
  int _currentMonth = DateTime.now().month - 1;
  int _currentYear = DateTime.now().year;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userName;
  Map<String, dynamic>? _userProfile;
  
  // GETTER CORRIGIDO
  String get _userFuncao => _userProfile?['funcao'] ?? 'paciente';
  
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  
  final List<String> _months = [
    "JANEIRO", "FEVEREIRO", "MARÇO", "ABRIL", "MAIO", "JUNHO",
    "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO"
  ];

  // Dados mockados de agendamentos
  final List<Map<String, dynamic>> _mockAppointments = [
    {
      'id': '1',
      'dia': 15,
      'medico': 'Dr. Carlos Silva',
      'especialidade': 'Cardiologia',
      'tipo': 'Presencial',
      'horario': '09:00',
      'duracao': '30 min',
      'local': 'Consultório',
      'status': 'confirmada',
      'statusText': 'Confirmada',
      'link_teleconsulta': '',
    },
    {
      'id': '2',
      'dia': 18,
      'medico': 'Dra. Ana Oliveira',
      'especialidade': 'Dermatologia',
      'tipo': 'Teleconsulta',
      'horario': '14:30',
      'duracao': '30 min',
      'local': '',
      'status': 'agendada',
      'statusText': 'Agendada',
      'link_teleconsulta': 'https://meet.example.com/consulta123',
    },
    {
      'id': '3',
      'dia': 22,
      'medico': 'Dr. Roberto Santos',
      'especialidade': 'Ortopedia',
      'tipo': 'Presencial',
      'horario': '11:00',
      'duracao': '30 min',
      'local': 'Consultório',
      'status': 'confirmada',
      'statusText': 'Confirmada',
      'link_teleconsulta': '',
    },
    {
      'id': '4',
      'dia': 10,
      'medico': 'Dra. Maria Costa',
      'especialidade': 'Pediatria',
      'tipo': 'Teleconsulta',
      'horario': '08:30',
      'duracao': '30 min',
      'local': '',
      'status': 'realizada',
      'statusText': 'Realizada',
      'link_teleconsulta': 'https://meet.example.com/consulta456',
    },
    {
      'id': '5',
      'dia': 5,
      'medico': 'Dr. Paulo Lima',
      'especialidade': 'Clínica Geral',
      'tipo': 'Presencial',
      'horario': '16:00',
      'duracao': '30 min',
      'local': 'Consultório',
      'status': 'cancelada',
      'statusText': 'Cancelada',
      'link_teleconsulta': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _carregarAgendamentosMock();
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
            _userName = profile['nome_completo']?.split(' ')[0] ?? 'Usuário';
          });
        }
      } else if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userName = null;
          _userProfile = null;
        });
      }
    } catch (e) {
      print('Erro ao verificar auth: $e');
    }
  }

  void _carregarAgendamentosMock() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final filtered = _mockAppointments.where((app) {
        return true;
      }).toList();

      setState(() {
        _appointments = filtered;
        _filteredAppointments = List.from(filtered);
        _isLoading = false;
      });
    });
  }

  String _getBotaoTexto(String status, String tipo) {
    if (status == 'agendada') {
      return 'Cancelar';
    }
    if (status == 'confirmada' && tipo == 'Teleconsulta') {
      return 'Acessar link';
    }
    if (status == 'realizada') {
      return 'Ver relatório';
    }
    return '';
  }

  String _getBotaoAcao(String status, String tipo) {
    if (status == 'agendada') {
      return 'cancelar';
    }
    if (status == 'confirmada' && tipo == 'Teleconsulta') {
      return 'link';
    }
    if (status == 'realizada') {
      return 'relatorio';
    }
    return '';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmada':
        return Colors.green;
      case 'agendada':
        return Colors.orange;
      case 'realizada':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_currentMonth == 0) {
        _currentMonth = 11;
        _currentYear--;
      } else {
        _currentMonth--;
      }
      _filtrarPorMes();
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_currentMonth == 11) {
        _currentMonth = 0;
        _currentYear++;
      } else {
        _currentMonth++;
      }
      _filtrarPorMes();
    });
  }

  void _filtrarPorMes() {
    setState(() {
      _filteredAppointments = List.from(_appointments);
      _isLoading = false;
    });
  }

  Future<void> _handleButtonClick(String acao, Map<String, dynamic> appointment) async {
    if (acao == 'cancelar') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancelar consulta'),
          content: Text('Tem certeza que deseja cancelar a consulta com ${appointment['medico']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sim, cancelar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() {
          _isLoading = true;
        });

        await Future.delayed(const Duration(seconds: 1));
        
        setState(() {
          final index = _filteredAppointments.indexWhere((a) => a['id'] == appointment['id']);
          if (index != -1) {
            _filteredAppointments[index]['status'] = 'cancelada';
            _filteredAppointments[index]['statusText'] = 'Cancelada';
          }
          _isLoading = false;
        });

        _showSnackBar('Consulta cancelada com sucesso!', Colors.green);
      }
    } 
    else if (acao == 'link') {
      final link = appointment['link_teleconsulta'];
      if (link != null && link.isNotEmpty) {
        _showSnackBar('Abrindo link da teleconsulta...', Colors.blue);
      } else {
        _showSnackBar('Link não disponível', Colors.orange);
      }
    }
    else if (acao == 'relatorio') {
      _showSnackBar('Função de relatório em desenvolvimento', Colors.blue);
    }
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
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
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
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      ),
    ),
    isScrollControlled: true,  // ESSA LINHA É ESSENCIAL
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
                backgroundColor: const Color(0xFF3FA9C6),
                child: Text(
                  _userName != null && _userName!.isNotEmpty
                      ? _userName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _userProfile?['nome_completo'] ?? 'Usuário',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                (_userProfile?['funcao'] ?? 'paciente') == 'paciente' ? 'Paciente' : 'Médico',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF1565C0),
                ),
                title: const Text('Editar perfil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/perfil');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF1565C0),
                ),
                title: const Text('Meus agendamentos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/agendamentos');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
              const SizedBox(height: 20), // Espaço extra no final
            ],
          ),
        ),
      );
    },
  );
}

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Agendamentos Médicos'),
        backgroundColor: const Color(0xFF3FA9C6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando agendamentos...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildMonthHeader(),
                  const SizedBox(height: 20),
                  _buildAppointmentsList(),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        isLoggedIn: _isLoggedIn,
        onProfileTap: () {
          if (_isLoggedIn) {
            _showUserMenu();
          } else {
            Navigator.pushNamed(context, '/login');
          }
        },
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _goToPreviousMonth,
                icon: const Icon(Icons.chevron_left, size: 32),
                color: const Color(0xFF3FA9C6),
              ),
              Text(
                '${_months[_currentMonth]} $_currentYear',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              IconButton(
                onPressed: _goToNextMonth,
                icon: const Icon(Icons.chevron_right, size: 32),
                color: const Color(0xFF3FA9C6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_filteredAppointments.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum agendamento para ${_months[_currentMonth]} de $_currentYear',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/clinicas');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3FA9C6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Agendar nova consulta'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredAppointments.length,
      itemBuilder: (context, index) {
        final app = _filteredAppointments[index];
        final botaoTexto = _getBotaoTexto(app['status'], app['tipo']);
        final botaoAcao = _getBotaoAcao(app['status'], app['tipo']);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3FA9C6).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${app['dia']}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${app['medico']} – ${app['especialidade']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${app['tipo']} - ${app['horario']}'
                        '${app['duracao'] != null && app['duracao'].isNotEmpty ? ' - ${app['duracao']}' : ''}'
                        '${app['local'] != null && app['local'].isNotEmpty ? ' - ${app['local']}' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(app['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          app['statusText'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(app['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (botaoTexto.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    onPressed: () => _handleButtonClick(botaoAcao, app),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: botaoAcao == 'cancelar'
                          ? Colors.red
                          : const Color(0xFF3FA9C6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      botaoTexto,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}