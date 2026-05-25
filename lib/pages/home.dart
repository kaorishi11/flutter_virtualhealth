import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'cadastro.dart';
import 'login.dart';
import 'clinicas.dart';
import 'contato.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentPage = 'Início';

void _onPageChanged(String page) {
  setState(() {
    _currentPage = page;
  });

  if (page == 'Clínicas') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClinicasPage()),
    ).then((_) {
      setState(() {
        _currentPage = 'Início';
      });
    });
  } else if (page == 'Contato') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContatoPage()),
    ).then((_) {
      setState(() {
        _currentPage = 'Início';
      });
    });
  } else if (page == 'Fazer Consulta') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const HeroSection(),
                const VideoPitchSection(),
                const VirtualPlanCard(),
                const FooterSection(),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TopNavigationBar(
                  currentPage: _currentPage,
                  onPageChanged: _onPageChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopNavigationBar extends StatefulWidget {
  final String currentPage;
  final Function(String) onPageChanged;

  const TopNavigationBar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  State<TopNavigationBar> createState() => _TopNavigationBarState();
}

class _TopNavigationBarState extends State<TopNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final navItems = [
      'Início',
      'Clínicas',
      'Contato',
      'Fazer Consulta',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.80),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 55,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            children: navItems.map((item) {
              final isActive = widget.currentPage == item;
              return _navItem(item, isActive);
            }).toList(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                widget.onPageChanged('Fazer Consulta');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Cadastre-se / Logar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, bool isActive) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onPageChanged(title);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF2E7D32) : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: isActive ? 24 : 0,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 550,
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
              const Color.fromRGBO(0, 40, 60, 0.75),
              const Color.fromRGBO(0, 40, 60, 0.25),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 140),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Você escolhe suas',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'consultas e exames',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6EF0C2),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Tudo que você precisa para cuidar da sua saúde em um só lugar — rápido, seguro e acessível.',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF006699),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Text(
                            'Agendar consulta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Text(
                            'Teleconsulta online',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 4,
                child: SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPitchSection extends StatefulWidget {
  const VideoPitchSection({super.key});

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
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      color: const Color(0xFFF5F9F5),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'NOSSO PROPÓSITO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Criamos uma plataforma acessível, humana e tecnológica',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'que coloca o paciente no centro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
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
                          height: 400,
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
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 400,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
            ),
          ),
          if (_isInitialized)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      _controller.seekTo(Duration.zero);
                    },
                    icon: const Icon(Icons.replay, color: Color(0xFF2E7D32)),
                    tooltip: 'Reiniciar',
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 300,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: const Color(0xFF2E7D32),
                        backgroundColor: Colors.grey[300]!,
                        bufferedColor: const Color(0xFF81C784),
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
  const VirtualPlanCard({super.key});

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
      margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      padding: const EdgeInsets.all(32),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/computadorhome.jpg',
                fit: BoxFit.cover,
                height: 275,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 275,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
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
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'COM O QUE TRABALHAMOS?',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
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
                    color: Color(0xFF1B5E20),
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
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF2E7D32),
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

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      color: const Color(0xFF1B5E20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Virtual Health',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cuidando da sua saúde com\ntecnologia e humanidade',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterColumn(
                    'Navegação',
                    ['Serviços', 'Benefícios', 'Depoimentos'],
                  ),
                  const SizedBox(width: 70),
                  _buildFooterColumn(
                    'Suporte',
                    ['Área do paciente', 'FAQ', 'Contato'],
                  ),
                  const SizedBox(width: 70),
                  _buildFooterColumn(
                    'Legal',
                    ['Termos de uso', 'Privacidade', 'Cookies'],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 50),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 28),
          Text(
            '© 2026 Virtual Health - Todos os direitos reservados',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () {},
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}