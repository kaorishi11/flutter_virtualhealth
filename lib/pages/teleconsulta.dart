import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class TeleconsultaPacientePage extends StatefulWidget {
  const TeleconsultaPacientePage({super.key});

  @override
  State<TeleconsultaPacientePage> createState() =>
      _TeleconsultaPacientePageState();
}

class _TeleconsultaPacientePageState extends State<TeleconsultaPacientePage>
    with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  bool _isLoggedIn = false;
  String? _userName;
  String? _userFuncao;
  Map<String, dynamic>? _userProfile;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkAuthState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
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
            _userName = null;
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
        _userName = null;
        _userProfile = null;
        _userFuncao = null;
      });
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _userProfile?['nome_completo'] ?? 'Usuário',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _userFuncao == 'paciente' ? 'Paciente' : 'Médico',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(isMobile),
              _buildHowItWorksSection(isMobile),
              _buildFeaturesSection(isMobile),
              _buildSpecialtiesSection(isMobile),
              _buildCTASection(isMobile),
              _buildFAQSection(isMobile),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: -1,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'TELECONSULTA ONLINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cuide da sua saúde\nsem sair de casa',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: isMobile ? 30 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Consulte médicos especialistas online com segurança,\nconforto e praticidade — disponível 24h por dia.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
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
    return ScaleTransition(
      scale: _pulseAnimation,
      child: ElevatedButton.icon(
        onPressed: () {
          if (!_isLoggedIn) {
            Navigator.pushNamed(context, '/login');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Em breve! Estamos finalizando esta funcionalidade.'),
                backgroundColor: Color(0xFF1565C0),
                behavior: SnackBarBehavior.floating,
              ),
            );
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
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: const Color(0xFF0D47A1),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 36,
            vertical: isMobile ? 14 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isMobile) {
    final steps = [
      {
        'icon': Icons.person_search_rounded,
        'color': const Color(0xFF1565C0),
        'title': '1. Escolha o especialista',
        'desc':
            'Selecione entre dezenas de médicos disponíveis na plataforma.',
      },
      {
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFF00897B),
        'title': '2. Agende sua consulta',
        'desc':
            'Escolha o horário que melhor se encaixa na sua rotina.',
      },
      {
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFF6A1B9A),
        'title': '3. Conecte-se online',
        'desc':
            'Na hora marcada, entre na sala virtual e consulte com segurança.',
      },
      {
        'icon': Icons.description_rounded,
        'color': const Color(0xFFE65100),
        'title': '4. Receba o resultado',
        'desc':
            'Receitas, atestados e laudos digitalmente no seu prontuário.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      color: Colors.white,
      child: Column(
        children: [
          _buildSectionBadge('COMO FUNCIONA'),
          const SizedBox(height: 12),
          Text(
            'Em 4 passos simples',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 22 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 40),
          isMobile
              ? Column(
                  children: steps
                      .map((s) => _buildStepCard(
                            s['icon'] as IconData,
                            s['color'] as Color,
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
                              s['color'] as Color,
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
      IconData icon, Color color, String title, String desc, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(
        right: isMobile ? 0 : 16,
        bottom: isMobile ? 16 : 0,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 15 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey[700],
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
        'desc': 'Todas as consultas são criptografadas e totalmente sigilosas.',
      },
      {
        'icon': Icons.access_time_rounded,
        'title': 'Disponível 24h',
        'desc': 'Acesse médicos a qualquer hora, inclusive fins de semana.',
      },
      {
        'icon': Icons.devices_rounded,
        'title': 'Multi-plataforma',
        'desc': 'Funciona no celular, tablet e computador sem instalar nada.',
      },
      {
        'icon': Icons.receipt_long_rounded,
        'title': 'Documentos Digitais',
        'desc': 'Receitas e atestados válidos emitidos digitalmente.',
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Médicos Verificados',
        'desc': 'Todos os profissionais são validados pelo CRM.',
      },
      {
        'icon': Icons.payments_rounded,
        'title': 'Preço Acessível',
        'desc': 'Consultas com valores menores que a consulta presencial.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      color: const Color(0xFFF0F4F8),
      child: Column(
        children: [
          _buildSectionBadge('VANTAGENS'),
          const SizedBox(height: 12),
          Text(
            'Por que escolher a Teleconsulta Virtual Health?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 20 : 30,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 0.85 : 1.1,
            ),
            itemCount: features.length,
            itemBuilder: (context, i) {
              final f = features[i];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        f['icon'] as IconData,
                        color: const Color(0xFF1565C0),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      f['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 13 : 15,
                        color: const Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      f['desc'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
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

  Widget _buildSpecialtiesSection(bool isMobile) {
    final specialties = [
      {'icon': '🧠', 'name': 'Psiquiatria'},
      {'icon': '❤️', 'name': 'Cardiologia'},
      {'icon': '🩺', 'name': 'Clínica Geral'},
      {'icon': '🦴', 'name': 'Ortopedia'},
      {'icon': '🌿', 'name': 'Dermatologia'},
      {'icon': '👶', 'name': 'Pediatria'},
      {'icon': '🧬', 'name': 'Endocrinologia'},
      {'icon': '💊', 'name': 'Nutrologia'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      color: Colors.white,
      child: Column(
        children: [
          _buildSectionBadge('ESPECIALIDADES'),
          const SizedBox(height: 12),
          Text(
            'Mais de 30 especialidades disponíveis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 20 : 30,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todos os médicos possuem CRM ativo e experiência comprovada.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: specialties.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s['icon']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      s['name']!,
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 48 : 72,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white.withOpacity(0.8),
            size: isMobile ? 48 : 64,
          ),
          const SizedBox(height: 20),
          Text(
            'Sua saúde não pode esperar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 24 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agende agora e fale com um especialista hoje mesmo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              if (!_isLoggedIn) {
                Navigator.pushNamed(context, '/login');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Em breve! Funcionalidade em desenvolvimento.'),
                    backgroundColor: Color(0xFF1565C0),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(
              _isLoggedIn ? 'Agendar Teleconsulta' : 'Entrar e Agendar',
              style: TextStyle(
                fontSize: isMobile ? 15 : 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1565C0),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 28 : 40,
                vertical: isMobile ? 14 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(bool isMobile) {
    final faqs = [
      {
        'q': 'Qual é o valor de uma teleconsulta?',
        'a':
            'Os valores variam de acordo com a especialidade e o profissional. Em média, as teleconsultas são mais acessíveis que consultas presenciais.',
      },
      {
        'q': 'A receita médica emitida online é válida?',
        'a':
            'Sim! Seguimos todas as normas do CFM para emissão de receitas e atestados digitais com validade legal.',
      },
      {
        'q': 'Preciso instalar algum aplicativo?',
        'a':
            'Não! Nossa plataforma funciona diretamente pelo navegador em qualquer dispositivo com câmera e microfone.',
      },
      {
        'q': 'O que acontece se a conexão cair durante a consulta?',
        'a':
            'O médico aguardará a sua reconexão. Caso não seja possível reconectar, o reagendamento é feito sem custo adicional.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      color: const Color(0xFFF0F4F8),
      child: Column(
        children: [
          _buildSectionBadge('DÚVIDAS FREQUENTES'),
          const SizedBox(height: 12),
          Text(
            'Perguntas frequentes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 22 : 30,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 32),
          ...faqs.map((faq) => _buildFAQItem(
                faq['q']!,
                faq['a']!,
                isMobile,
              )),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 4,
        ),
        childrenPadding: EdgeInsets.only(
          left: isMobile ? 16 : 24,
          right: isMobile ? 16 : 24,
          bottom: 16,
        ),
        iconColor: const Color(0xFF1565C0),
        collapsedIconColor: Colors.grey,
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 15,
            color: const Color(0xFF1A237E),
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Color(0xFF1565C0),
        ),
      ),
    );
  }
}
