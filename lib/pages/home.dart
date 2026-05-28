import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_player/video_player.dart';
import 'cadastro.dart';
import 'login.dart';
import 'clinicas.dart';
import 'contato.dart';
import 'chatbot.dart';

void main() {
  // Remove o # da URL para rotas limpas
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Health',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/clinicas': (context) => const ClinicasPage(),
        '/contato': (context) => const ContatoPage(),
        '/chatbot': (context) => const ChatbotPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentPage = 'Início';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onPageChanged(String page) {
    setState(() {
      _currentPage = page;
    });

    if (page == 'Clínicas') {
      Navigator.pushNamed(context, '/clinicas').then((_) {
        setState(() {
          _currentPage = 'Início';
        });
      });
    } else if (page == 'Contato') {
      Navigator.pushNamed(context, '/contato').then((_) {
        setState(() {
          _currentPage = 'Início';
        });
      });
    } else if (page == 'Fazer Consulta') {
      Navigator.pushNamed(context, '/login');
    } else if (page == 'Chatbot') {
      Navigator.pushNamed(context, '/chatbot');
    } else if (page == 'Cadastro') {
      Navigator.pushNamed(context, '/cadastro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Divider(color: Colors.white54, thickness: 1),
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem('Início', Icons.home, () {
                      Navigator.pop(context);
                      _onPageChanged('Início');
                    }),
                    _buildDrawerItem('Clínicas', Icons.local_hospital, () {
                      Navigator.pop(context);
                      _onPageChanged('Clínicas');
                    }),
                    _buildDrawerItem('Contato', Icons.contact_mail, () {
                      Navigator.pop(context);
                      _onPageChanged('Contato');
                    }),
                    _buildDrawerItem('Chatbot', Icons.chat, () {
                      Navigator.pop(context);
                      _onPageChanged('Chatbot');
                    }),
                    _buildDrawerItem('Fazer Consulta', Icons.calendar_today, () {
                      Navigator.pop(context);
                      _onPageChanged('Fazer Consulta');
                    }),
                    const Divider(color: Colors.white54, thickness: 1),
                    _buildDrawerItem('Cadastro', Icons.app_registration, () {
                      Navigator.pop(context);
                      _onPageChanged('Cadastro');
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: isMobile ? 100 : 160),
                    HeroSection(isMobile: isMobile),
                    VideoPitchSection(isMobile: isMobile),
                    VirtualPlanCard(isMobile: isMobile),
                    ModernFooterSection(isMobile: isMobile),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopNavigationBar(
                  currentPage: _currentPage,
                  onPageChanged: _onPageChanged,
                  isMobile: isMobile,
                  scaffoldKey: _scaffoldKey,
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      splashColor: Colors.white.withOpacity(0.2),
    );
  }
}

class TopNavigationBar extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageChanged;
  final bool isMobile;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const TopNavigationBar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    this.isMobile = false,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = ['Início', 'Clínicas', 'Contato', 'Chatbot'];

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                scaffoldKey?.currentState?.openDrawer();
              },
              icon: const Icon(Icons.menu, size: 28, color: Color(0xFF1565C0)),
            ),
            Image.asset(
              'assets/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            Container(width: 40),
          ],
        ),
      );
    }

    // Desktop layout
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          Row(
            children: navItems.map((item) {
              final isActive = currentPage == item;
              return GestureDetector(
                onTap: () => onPageChanged(item),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isActive ? const Color(0xFF1565C0) : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isActive ? 24 : 0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onPageChanged('Fazer Consulta'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF0D47A1).withOpacity(0.85),
              const Color(0xFF1565C0).withOpacity(0.5),
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
              Text(
                'SEJA BEM VINDO AO',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 50,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'VIVIDO EM VIDA!',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 80,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4FC3F7),
                  height: 1.1,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 28),
              Text(
                'Tudo que você precisa para cuidar da sua saúde em um só lugar — rápido, seguro e acessível.',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 22,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: isMobile ? 24 : 40),
              if (!isMobile)
                Row(
                  children: [
                    _buildAgendarButton(isMobile),
                    const SizedBox(width: 24),
                    _buildTeleconsultaButton(isMobile),
                  ],
                ),
              if (isMobile) ...[
                _buildAgendarButton(isMobile),
                const SizedBox(height: 12),
                _buildTeleconsultaButton(isMobile),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgendarButton(bool isMobile) {
    return ElevatedButton(
      onPressed: () {},
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

  Widget _buildTeleconsultaButton(bool isMobile) {
    return OutlinedButton(
      onPressed: () {},
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
        vertical: widget.isMobile ? 40 : 60
      ),
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
        horizontal: isMobile ? 16 : 80, 
        vertical: isMobile ? 24 : 40
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    return Column(
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
                onTap: () {},
                child: Text(
                  link,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
      ],
    );
  }
}