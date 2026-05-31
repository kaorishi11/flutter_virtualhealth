import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:virtualhealth/pages/teleconsulta.dart';
import 'package:virtualhealth/pages/cadastro.dart';
import 'package:virtualhealth/pages/login.dart';
import 'package:virtualhealth/pages/clinicas.dart';
import 'package:virtualhealth/pages/contato.dart';
import 'package:virtualhealth/pages/chatbot.dart';
import 'package:virtualhealth/pages/perfil.dart';
import 'package:virtualhealth/pages/agendamentos.dart';
import 'package:virtualhealth/services/auth_service.dart';
import 'package:virtualhealth/widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();
  String _currentPage = 'Início';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggedIn = false;
  String? _userName;
  String? _userFuncao;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        } else if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _userName = null;
            _userProfile = null;
            _userFuncao = null;
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
      print('Erro ao verificar auth: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userName = null;
          _userProfile = null;
          _userFuncao = null;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.logout();
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userName = null;
          _userProfile = null;
          _userFuncao = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout realizado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

  void _onPageChanged(String page) {
    setState(() {
      _currentPage = page;
    });

    if (page == 'Início') {
      Navigator.pop(context);
    } else if (page == 'Contato') {
      Navigator.pushNamed(context, '/contato').then((_) {
        if (mounted) {
          setState(() {
            _currentPage = 'Início';
          });
        }
      });
    } else if (page == 'Chatbot') {
      Navigator.pushNamed(context, '/chatbot').then((_) {
        if (mounted) {
          setState(() {
            _currentPage = 'Início';
          });
        }
      });
    } else if (page == 'Cadastro') {
      Navigator.pushNamed(context, '/cadastro').then((_) {
        if (mounted) {
          setState(() {
            _currentPage = 'Início';
          });
        }
      });
    } else if (page == 'Teleconsulta') {
      Navigator.pushNamed(context, '/teleconsulta').then((_) {
        if (mounted) {
          setState(() {
            _currentPage = 'Início';
          });
        }
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return SingleChildScrollView(
          child: Column(
            children: [
              HeroSection(isMobile: isMobile),
              VideoPitchSection(isMobile: isMobile),
              VirtualPlanCard(isMobile: isMobile),
              ModernFooterSection(isMobile: isMobile),
            ],
          ),
        );
      }),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
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
}

class HeroSection extends StatelessWidget {
  final bool isMobile;
  const HeroSection({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 500 : 550,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/homepage.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 140,
            vertical: isMobile ? 20 : 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SEJA BEM VINDO AO',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 50,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 16, 155, 102),
                  letterSpacing: 2,
                ),
              ),
              Text(
                'VIRTUAL HEALTH',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 80,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 16, 155, 102),
                  height: 1.1,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 28),
              Text(
                'Tudo que você precisa para cuidar da sua saúde em um só lugar — rápido, seguro e acessível.',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 22,
                  color: const Color.fromARGB(179, 0, 0, 0),
                ),
              ),
              SizedBox(height: isMobile ? 24 : 40),
              if (!isMobile)
                Row(
                  children: [
                    _buildAgendarButton(context, isMobile),
                    const SizedBox(width: 24),
                    _buildTeleconsultaButton(context, isMobile),
                  ],
                ),
              if (isMobile) ...[
                _buildAgendarButton(context, isMobile),
                const SizedBox(height: 12),
                _buildTeleconsultaButton(context, isMobile),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgendarButton(BuildContext context, bool isMobile) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/clinicas');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1565C0),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 36,
          vertical: isMobile ? 12 : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: Text(
        'Agendar consulta',
        style: TextStyle(
          fontSize: isMobile ? 14 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTeleconsultaButton(BuildContext context, bool isMobile) {
    return OutlinedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/teleconsulta');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(
          color: Colors.white,
          width: 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 36,
          vertical: isMobile ? 12 : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: Text(
        'Teleconsulta online',
        style: TextStyle(
          fontSize: isMobile ? 14 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class VideoPitchSection extends StatefulWidget {
  final bool isMobile;
  const VideoPitchSection({super.key, this.isMobile = false});

  @override
  State<VideoPitchSection> createState() => _VideoPitchSectionState();
}

class _VideoPitchSectionState extends State<VideoPitchSection> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video.mp4')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      }).catchError((error) {
        print('Erro ao carregar vídeo: $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 20 : 80,
          vertical: widget.isMobile ? 40 : 60),
      color: const Color(0xFFF0F4F8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'NOSSO PROPÓSITO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Criamos uma plataforma acessível, humana e tecnológica',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isMobile ? 20 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'que coloca o paciente no centro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isMobile ? 16 : 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: widget.isMobile
                ? MediaQuery.of(context).size.width * 0.95
                : MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: widget.isMobile ? 250 : 400,
                          child: VideoPlayer(_controller),
                        ),
                        Positioned(
                          child: FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                              });
                            },
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: widget.isMobile ? 24 : 32,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: widget.isMobile ? 250 : 400,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
            ),
          ),
          if (_isInitialized && !widget.isMobile)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      _controller.seekTo(Duration.zero);
                    },
                    icon: const Icon(Icons.replay, color: Color(0xFF1565C0)),
                    tooltip: 'Reiniciar',
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 300,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: const Color(0xFF1565C0),
                        backgroundColor: Colors.grey[300]!,
                        bufferedColor: const Color(0xFF64B5F6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class VirtualPlanCard extends StatelessWidget {
  final bool isMobile;
  const VirtualPlanCard({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      'Acesse pelo celular, tablet ou computador em todas as plataformas digitais.',
      'Segurança e privacidade garantidas para os dados de todos os usuários.',
      'Fácil acesso a informações e exames com Inteligência Artificial (Chatbot).',
      'Agendamento para o mesmo dia pelo app ou site',
      'A equipe Virtual Health responde suas dúvidas com atenção e rapidez.',
    ];

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 80, vertical: isMobile ? 24 : 40),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/computadorhome.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'COM O QUE TRABALHAMOS?',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Para sua saúde e para a sua família',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 20),
                ...benefits.map((benefit) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF1565C0),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              benefit,
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/computadorhome.jpg',
                      height: 275,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'COM O QUE TRABALHAMOS?',
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 21,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Para sua saúde e para a sua família',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...benefits.map((benefit) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Color(0xFF1565C0),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: const TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class ModernFooterSection extends StatelessWidget {
  final bool isMobile;
  const ModernFooterSection({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                width: isMobile ? 150 : 200,
                height: isMobile ? 150 : 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
              child: Text(
                'Cuidando da sua saúde com tecnologia e humanidade. Disponível 24 horas por dia, 7 dias por semana.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile ? 14 : 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (isMobile) ...[
              _buildFooterLinksCentralizado('Serviços', [
                'Teleconsultas 24h',
                'Agendamento online',
                'Especialidades',
                'Exames',
                'Prontuário digital',
              ]),
              const SizedBox(height: 30),
              _buildFooterLinksCentralizado('Institucional', [
                'Sobre nós',
                'Carreiras',
                'Blog',
                'Imprensa',
                'Seja parceiro',
              ]),
              const SizedBox(height: 30),
              _buildFooterLinksCentralizado('Suporte', [
                'Central de ajuda',
                'FAQ',
                'Contato',
                'Termos de uso',
                'Privacidade',
              ]),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterLinksCentralizado('Serviços', [
                    'Teleconsultas 24h',
                    'Agendamento online',
                    'Especialidades',
                    'Exames',
                    'Prontuário digital',
                  ]),
                  _buildFooterLinksCentralizado('Institucional', [
                    'Sobre nós',
                    'Carreiras',
                    'Blog',
                    'Imprensa',
                    'Seja parceiro',
                  ]),
                  _buildFooterLinksCentralizado('Suporte', [
                    'Central de ajuda',
                    'FAQ',
                    'Contato',
                    'Termos de uso',
                    'Privacidade',
                  ]),
                ],
              ),
            ],
            const SizedBox(height: 40),
            Divider(color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 24),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(Icons.facebook),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.phone_android),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.email),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '© 2026 Virtual Health - Todos os direitos reservados',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isMobile ? 10 : 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFooterLinksCentralizado(String title, List<String> links) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...links.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    if (link == 'Contato') {
                      Navigator.pushNamed(context, '/contato');
                    } else if (link == 'Termos de uso') {
                      Navigator.pushNamed(context, '/termos-uso');
                    } else if (link == 'Privacidade') {
                      Navigator.pushNamed(context, '/privacidade');
                    } else if (link == 'Teleconsultas 24h') {
                      Navigator.pushNamed(context, '/teleconsulta');
                    } else if (link == 'Agendamento online') {
                      Navigator.pushNamed(context, '/clinicas');
                    }
                  },
                  child: Text(
                    link,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: (link == 'Contato' ||
                              link == 'Termos de uso' ||
                              link == 'Privacidade' ||
                              link == 'Teleconsultas 24h' ||
                              link == 'Agendamento online')
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
