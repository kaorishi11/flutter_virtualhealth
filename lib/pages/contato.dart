import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'chatbot.dart';
import 'cadastro.dart';
import 'home.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final AuthService _auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _mensagemController = TextEditingController();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userName;
  String? _userFuncao;
  Map<String, dynamic>? _userProfile;
  String? _usuarioId;
  String? _usuarioEmail;
  String? _usuarioNome;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _mensagemController.dispose();
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
            _usuarioId = profile['id'];
            _usuarioNome = profile['nome_completo'];
            _usuarioEmail = profile['email'];
            _nomeController.text = _usuarioNome!;
            _emailController.text = _usuarioEmail!;
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
        _nomeController.clear();
        _emailController.clear();
        _mensagemController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout realizado com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Voltar para Home após logout
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

  Future<void> _enviarMensagem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> dadosMensagem = {
        'nome_remetente': _nomeController.text.trim(),
        'email_remetente': _emailController.text.trim(),
        'mensagem': _mensagemController.text.trim(),
        'status': 'pendente',
      };

      if (_isLoggedIn && _usuarioId != null) {
        dadosMensagem['usuario_id'] = _usuarioId;
      }

      await Supabase.instance.client.from('mensagens').insert(dadosMensagem);

      if (!mounted) return;

      if (!_isLoggedIn) {
        _nomeController.clear();
        _emailController.clear();
      }
      _mensagemController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                  child: Text(
                      'Mensagem enviada com sucesso! Nossa equipe retornará em breve.')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('Erro detalhado: $e');
      if (!mounted) return;

      String mensagemErro = 'Erro ao enviar mensagem. Tente novamente.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(mensagemErro)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPageChanged(String page) {
    if (page == 'Início') {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (page == 'Contato') {
      // Já está na página de contato
      Navigator.pop(context);
    } else if (page == 'Chatbot') {
      Navigator.pushReplacementNamed(context, '/chatbot');
    } else if (page == 'Cadastro') {
      Navigator.pushReplacementNamed(context, '/cadastro');
    } else if (page == 'Teleconsulta') {
      Navigator.pushReplacementNamed(context, '/teleconsulta');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(isMobile),
            const SizedBox(height: 30),
            _buildForm(isMobile),
            const SizedBox(height: 50),
            _buildFooter(isMobile),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
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
      height: isMobile ? 280 : 350,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'POSSUI ALGUMA DÚVIDA?',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'NOS CONTATE',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4FC3F7),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Nossa equipe está pronta para te ajudar,',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'com rapidez e segurança',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4FC3F7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envie sua mensagem',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoggedIn
                  ? 'Olá $_usuarioNome! Deixe sua mensagem abaixo.'
                  : 'Preencha os campos abaixo para enviar sua mensagem.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Nome
            _buildTextField(
              label: 'NOME COMPLETO',
              controller: _nomeController,
              hint: 'Digite seu nome completo',
              enabled: !_isLoggedIn,
              isMobile: isMobile,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite seu nome completo';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email
            _buildTextField(
              label: 'E-MAIL',
              controller: _emailController,
              hint: 'Digite seu e-mail',
              enabled: !_isLoggedIn,
              keyboardType: TextInputType.emailAddress,
              isMobile: isMobile,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite seu e-mail';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Digite um e-mail válido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Mensagem
            _buildTextField(
              label: 'SUA MENSAGEM',
              controller: _mensagemController,
              hint: 'Digite sua mensagem aqui...',
              maxLines: 5,
              isMobile: isMobile,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite sua mensagem';
                }
                if (value.length < 10) {
                  return 'Mensagem muito curta (mínimo 10 caracteres)';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Botão Enviar
            SizedBox(
              width: double.infinity,
              height: isMobile ? 48 : 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enviarMensagem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Enviar Mensagem',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.send, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: isMobile ? 14 : 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F9F5),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 16,
              vertical: isMobile ? 12 : 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // ================= FOOTER =================
  Widget _buildFooter(bool isMobile) {
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
                onTap: () {
                  if (link == 'Contato') {
                    Navigator.pop(context);
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
    );
  }
}
