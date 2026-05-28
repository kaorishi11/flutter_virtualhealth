import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'cadastro.dart';
import 'login.dart';
import 'clinicas.dart';
import 'contato.dart';
import 'chatbot.dart';

void main() {
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
      home: const HomePage(),
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
    } else if (page == 'Chatbot') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatbotPage()),
      );
    } else if (page == 'Cadastro') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CadastroPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                TopNavigationBar(
                  currentPage: _currentPage,
                  onPageChanged: _onPageChanged,
                  isMobile: isMobile,
                ),
                HeroSection(isMobile: isMobile),
                VideoPitchSection(isMobile: isMobile),
                VirtualPlanCard(isMobile: isMobile),
                ModernFooterSection(isMobile: isMobile),
              ],
            ),
          );
        }
      ),
    );
  }
}

class TopNavigationBar extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageChanged;
  final bool isMobile;

  const TopNavigationBar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = ['Início', 'Clínicas', 'Contato', 'Chatbot'];

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIRTUAL HEALTH',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        Text(
                          'Sua saúde em boas mãos',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => onPageChanged('Fazer Consulta'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: navItems.map((item) {
                  final isActive = currentPage == item;
                  return GestureDetector(
                    onTap: () => onPageChanged(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? const Color(0xFF1565C0).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive 
                              ? const Color(0xFF1565C0)
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop layout
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Row(
            children: navItems.map((item) {
              final isActive = currentPage == item;
              return _buildNavItem(item, isActive);
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

  Widget _buildNavItem(String title, bool isActive) {
    return GestureDetector(
      onTap: () => onPageChanged(title),
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
                'Você escolhe suas',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'consultas e exames',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 72,
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
                  child: Container(
                    height: 200,
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    child: const Center(
                      child: Icon(
                        Icons.computer,
                        size: 80,
                        color: Color(0xFF1565C0),
                      ),
                    ),
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
                    child: Container(
                      height: 275,
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          Icons.computer,
                          size: 100,
                          color: Color(0xFF1565C0),
                        ),
                      ),
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
            // Logo e descrição
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isMobile ? 1 : 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: isMobile ? 45 : 60,
                            height: isMobile ? 45 : 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              color: Color(0xFF1565C0),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VIRTUAL HEALTH',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Sua saúde em boas mãos',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cuidando da sua saúde com tecnologia e humanidade. Disponíveis 24 horas por dia, 7 dias por semana.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 12 : 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildSocialIcon(Icons.facebook),
                          const SizedBox(width: 12),
                          _buildSocialIcon(Icons.phone_android),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (!isMobile) ...[
                  const SizedBox(width: 60),
                  Expanded(
                    child: _buildFooterLinks('Serviços', [
                      'Teleconsultas 24h',
                      'Agendamento online',
                      'Especialidades',
                      'Exames',
                      'Prontuário digital',
                    ]),
                  ),
                  Expanded(
                    child: _buildFooterLinks('Institucional', [
                      'Sobre nós',
                      'Carreiras',
                      'Blog',
                      'Imprensa',
                      'Seja parceiro',
                    ]),
                  ),
                  Expanded(
                    child: _buildFooterLinks('Suporte', [
                      'Central de ajuda',
                      'FAQ',
                      'Contato',
                      'Termos de uso',
                      'Privacidade',
                    ]),
                  ),
                ],
              ],
            ),
            
            if (isMobile) ...[
              const SizedBox(height: 30),
              _buildFooterLinks('Serviços', [
                'Teleconsultas 24h',
                'Agendamento online',
                'Especialidades',
                'Exames',
                'Prontuário digital',
              ]),
              const SizedBox(height: 24),
              _buildFooterLinks('Institucional', [
                'Sobre nós',
                'Carreiras',
                'Blog',
                'Imprensa',
                'Seja parceiro',
              ]),
              const SizedBox(height: 24),
              _buildFooterLinks('Suporte', [
                'Central de ajuda',
                'FAQ',
                'Contato',
                'Termos de uso',
                'Privacidade',
              ]),
            ],
            
            const SizedBox(height: 40),
            Divider(color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2026 Virtual Health - Todos os direitos reservados',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
                if (!isMobile)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Política de privacidade',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Termos de serviço',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Cookies',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFooterLinks(String title, List<String> links) {
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
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {},
                child: Text(
                  link,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}