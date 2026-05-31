import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
      debugPrint('Erro ao verificar auth: $e');
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
            backgroundColor: Color(0xFF14B8A6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
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
                  (_userProfile?['funcao'] ?? 'paciente') == 'paciente'
                      ? 'Paciente'
                      : 'Médico',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF14B8A6),
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
                    color: Color(0xFF14B8A6),
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
              CTASection(isMobile: isMobile),
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

// Seção Hero Modernizada
class HeroSection extends StatelessWidget {
  final bool isMobile;
  const HeroSection({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 550 : 600,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/homepage.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D2C33).withOpacity(0.85),
              const Color(0xFF0D2C33).withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 140,
            vertical: isMobile ? 20 : 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'SEJA BEM VINDO AO',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'VIRTUAL HEALTH',
                style: TextStyle(
                  fontSize: isMobile ? 42 : 90,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: isMobile ? 80 : 120,
                height: 4,
                color: const Color(0xFF14B8A6),
              ),
              const SizedBox(height: 24),
              Text(
                'Tudo que você precisa para cuidar da sua saúde\nem um só lugar — rápido, seguro e acessível.',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 20,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
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
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 40,
          vertical: isMobile ? 14 : 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 12),
          Text(
            'Agendar consulta',
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          horizontal: isMobile ? 24 : 40,
          vertical: isMobile ? 14 : 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam, size: 20),
          const SizedBox(width: 12),
          Text(
            'Teleconsulta online',
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildStatItem(String number, String label, IconData icon) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF14B8A6).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF14B8A6), size: 28),
      ),
      const SizedBox(height: 12),
      Text(
        number,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D2C33),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// Seção de Vídeo Modernizada
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
        debugPrint('Erro ao carregar vídeo: $error');
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
        vertical: widget.isMobile ? 40 : 60,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'NOSSO PROPÓSITO',
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
            'Criamos uma plataforma acessível,',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isMobile ? 22 : 36,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF0D2C33),
            ),
          ),
          Text(
            'humana e tecnológica',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isMobile ? 22 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'que coloca o paciente no centro do cuidado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isMobile ? 14 : 18,
              color: Colors.grey[600],
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
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
                            backgroundColor: const Color(0xFF14B8A6),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: widget.isMobile ? 28 : 36,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: widget.isMobile ? 250 : 400,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF14B8A6),
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
                    icon: const Icon(Icons.replay, color: Color(0xFF14B8A6)),
                    tooltip: 'Reiniciar',
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 300,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: const Color(0xFF14B8A6),
                        backgroundColor: Colors.grey[300]!,
                        bufferedColor: const Color(0xFF5EEAD4),
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

// Card do Plano Virtual Modernizado
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
        horizontal: isMobile ? 16 : 80,
        vertical: isMobile ? 24 : 40,
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF14B8A6).withOpacity(0.2),
        ),
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
                    color: const Color(0xFF14B8A6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'COM O QUE TRABALHAMOS?',
                    style: TextStyle(
                      color: Color(0xFF14B8A6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Para sua saúde e para a sua família',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D2C33),
                  ),
                ),
                const SizedBox(height: 20),
                ...benefits.map((benefit) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Color(0xFF14B8A6),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              benefit,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 13,
                                height: 1.4,
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
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          '⚡ COM O QUE TRABALHAMOS?',
                          style: TextStyle(
                            color: Color(0xFF14B8A6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Para sua saúde e para a sua família',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D2C33),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...benefits.map((benefit) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14B8A6)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF14B8A6),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 15,
                                      height: 1.5,
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

// Nova Seção CTA (Call to Action)
class CTASection extends StatelessWidget {
  final bool isMobile;
  const CTASection({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 30 : 50,
      ),
      padding: EdgeInsets.all(isMobile ? 30 : 50),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(169, 219, 229, 231),
            Color.fromARGB(201, 205, 209, 211)
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo sem fundo arredondado e maior
          Image.asset(
            'assets/logo.png',
            width: isMobile ? 120 : 160,
            height: isMobile ? 120 : 160,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'Pronto para cuidar da sua saúde?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 22 : 32,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(157, 10, 46, 155),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agende sua consulta agora mesmo e tenha acesso\nà saúde de qualidade onde você estiver.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: const Color.fromARGB(255, 10, 46, 155),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/clinicas');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 30 : 48,
                vertical: isMobile ? 14 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_forward, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Começar agora',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 18,
                    fontWeight: FontWeight.bold,
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
