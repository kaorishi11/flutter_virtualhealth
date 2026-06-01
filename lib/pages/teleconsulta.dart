import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class TeleconsultaPacientePage extends StatefulWidget {
  const TeleconsultaPacientePage({super.key});

  @override
  State<TeleconsultaPacientePage> createState() =>
      _TeleconsultaPacientePageState();
}

class _TeleconsultaPacientePageState extends State<TeleconsultaPacientePage> {
  final AuthService _auth = AuthService();
  bool _isLoggedIn = false;
  String _userName = '';
  String? _userFuncao;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
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
            _userFuncao = profile['funcao'] ?? 'paciente';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _userName = '';
            _userProfile = null;
            _userFuncao = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar auth: $e');
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userName = '';
        _userProfile = null;
        _userFuncao = null;
      });
      Navigator.pushReplacementNamed(context, '/');
    }
  }

   void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
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
                  backgroundColor: const Color(0xFF14B8A6),
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
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
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF14B8A6)),
                  title: const Text('Editar perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/perfil');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: Color(0xFF14B8A6)),
                  title: const Text('Meus agendamentos'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/agendamentos');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(isMobile),
            _buildHowItWorksSection(isMobile),
            _buildFeaturesSection(isMobile),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 4, // Teleconsulta
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

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 60 : 80,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2C33), Color(0xFF0D2C33)],
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.videocam, color: Color(0xFF14B8A6), size: 16),
                SizedBox(width: 6),
                Text(
                  'TELECONSULTA ONLINE',
                  style: TextStyle(
                    color: Color(0xFF14B8A6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cuide da sua saúde\nsem sair de casa',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Consulte médicos especialistas online com segurança,\nconforto e praticidade — disponível 24h por dia.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: isMobile ? 15 : 18,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          if (isMobile)
            Center(child: _buildConsultarButton(isMobile))
          else
            _buildConsultarButton(isMobile),
        ],
      ),
    );
  }

  Widget _buildConsultarButton(bool isMobile) {
    return ElevatedButton.icon(
      onPressed: () {
        if (!_isLoggedIn) {
          Navigator.pushNamed(context, '/login');
        } else {
          Navigator.pushNamed(context, '/clinicas');
        }
      },
      icon: const Icon(Icons.videocam_rounded, size: 20),
      label: Text(
        _isLoggedIn ? 'Iniciar Teleconsulta' : 'Faça login para consultar',
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 28 : 40,
          vertical: isMobile ? 14 : 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isMobile) {
    final steps = [
      {
        'icon': Icons.person_search_rounded,
        'title': 'Escolha o especialista',
        'desc': 'Selecione entre dezenas de médicos disponíveis.',
      },
      {
        'icon': Icons.calendar_today_rounded,
        'title': 'Agende sua consulta',
        'desc': 'Escolha o melhor horário para você.',
      },
      {
        'icon': Icons.videocam_rounded,
        'title': 'Conecte-se online',
        'desc': 'Na hora marcada, entre na sala virtual.',
      },
      {
        'icon': Icons.description_rounded,
        'title': 'Receba os documentos',
        'desc': 'Receitas e laudos no seu prontuário.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 48 : 64,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'COMO FUNCIONA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF14B8A6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Em 4 passos simples',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D2C33),
            ),
          ),
          const SizedBox(height: 48),
          isMobile
              ? Column(
                  children: steps
                      .map((s) => _buildStepCard(
                            s['icon'] as IconData,
                            s['title'] as String,
                            s['desc'] as String,
                            isMobile,
                          ))
                      .toList(),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps
                      .map((s) => Expanded(
                            child: _buildStepCard(
                              s['icon'] as IconData,
                              s['title'] as String,
                              s['desc'] as String,
                              isMobile,
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
      IconData icon, String title, String desc, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(
        right: isMobile ? 0 : 16,
        bottom: isMobile ? 16 : 0,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF7F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF14B8A6), size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 15 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D2C33),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isMobile) {
    final features = [
      {
        'icon': Icons.lock_rounded,
        'title': 'Seguro e Privado',
        'desc': 'Consultas criptografadas e totalmente sigilosas.',
      },
      {
        'icon': Icons.access_time_rounded,
        'title': 'Disponível 24h',
        'desc': 'Acesse médicos a qualquer hora.',
      },
      {
        'icon': Icons.devices_rounded,
        'title': 'Multi-plataforma',
        'desc': 'Funciona no celular, tablet e computador.',
      },
      {
        'icon': Icons.receipt_long_rounded,
        'title': 'Documentos Digitais',
        'desc': 'Receitas e atestados válidos.',
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Médicos Verificados',
        'desc': 'Todos validados pelo CRM.',
      },
      {
        'icon': Icons.payments_rounded,
        'title': 'Preço Acessível',
        'desc': 'Valores menores que consulta presencial.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 48 : 64,
      ),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'VANTAGENS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF14B8A6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Por que escolher a Teleconsulta?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 22 : 30,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D2C33),
            ),
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 0.9 : 1.1,
            ),
            itemCount: features.length,
            itemBuilder: (context, i) {
              final f = features[i];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        f['icon'] as IconData,
                        color: const Color(0xFF14B8A6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      f['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 15,
                        color: const Color(0xFF0D2C33),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      f['desc'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}