import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
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
            _nomeController.text = _usuarioNome ?? '';
            _emailController.text = _usuarioEmail ?? '';
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
          backgroundColor: Color(0xFF14B8A6),
          behavior: SnackBarBehavior.floating,
        ),
      );

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
          backgroundColor: Color(0xFF14B8A6),
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(isMobile),
            const SizedBox(height: 40),
            _buildForm(isMobile),
            const SizedBox(height: 50),
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
      height: isMobile ? 300 : 380,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2C33), Color(0xFF0D2C33)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.contact_support,
                  color: Color(0xFF14B8A6),
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'POSSUI ALGUMA DÚVIDA?',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'FALE CONOSCO',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 44,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14B8A6),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: 60,
                height: 3,
                color: const Color(0xFF14B8A6),
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
                'com rapidez, segurança e atendimento humanizado',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
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
    // Obtém o primeiro nome do usuário logado
    String firstName = '';
    if (_isLoggedIn && _usuarioNome != null && _usuarioNome!.isNotEmpty) {
      firstName = _usuarioNome!.split(' ')[0];
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80),
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF14B8A6),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Envie sua mensagem',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D2C33),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLoggedIn && firstName.isNotEmpty
                            ? 'Olá $firstName! Deixe sua mensagem abaixo.'
                            : 'Preencha os campos abaixo para enviar sua mensagem.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Nome
            _buildTextField(
              label: 'NOME COMPLETO',
              controller: _nomeController,
              hint: 'Digite seu nome completo',
              icon: Icons.person_outline,
              enabled: !_isLoggedIn,
              isMobile: isMobile,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite seu nome completo';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

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

            const SizedBox(height: 20),

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

            const SizedBox(height: 32),

            // Botão Enviar
            SizedBox(
              width: double.infinity,
              height: isMobile ? 50 : 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enviarMensagem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
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
                              fontSize: isMobile ? 15 : 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.send, size: 20),
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
    IconData? icon,
    int maxLines = 1,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: const Color(0xFF14B8A6)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 11 : 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D2C33),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: isMobile ? 15 : 16, color: const Color(0xFF0D2C33)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 14 : 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}