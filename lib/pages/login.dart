import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'home.dart';
import 'cadastro.dart';
import '../adm/admin_home.dart';
import '../medico/medico_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String _userType = 'paciente';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberMe && savedEmail != null && savedPassword != null) {
        setState(() {
          _emailController.text = savedEmail;
          _senhaController.text = savedPassword;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Erro ao carregar credenciais: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _senhaController.text.trim());
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      print('Erro ao salvar credenciais: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final error = await _auth.login(
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
      );

      if (!mounted) return;

      if (error == null) {
        await _saveCredentials();

        final funcao = await _auth.pegarFuncaoUsuario();

        if (funcao == null) {
          throw Exception('Usuário sem função cadastrada.');
        }

        if (funcao != 'admin') {
          if (funcao != _userType) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Você selecionou "$_userType", mas sua conta é "$funcao".',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );

            await _auth.logout();

            setState(() {
              _isLoading = false;
            });

            return;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        Widget destino;

        switch (funcao) {
          case 'admin':
            destino = const AdminHomePage();
            break;
          case 'medico':
            destino = const MedicoHomePage();
            break;
          case 'paciente':
            destino = const HomePage();
            break;
          default:
            destino = const HomePage();
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destino),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = error;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro inesperado. Tente novamente.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite seu e-mail para recuperar a senha'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final error = await _auth.resetPassword(email);

      if (!mounted) return;

      if (error == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Recuperação de Senha'),
            content: Text(
              'Enviamos um link de recuperação para:\n\n$email\n\nVerifique sua caixa de entrada e a pasta de spam.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao recuperar senha. Tente novamente.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3FA9C6),
              Color(0xFF6DC8E0),
              Color(0xFFEDEDED),
              Color(0xFFEDEDED),
            ],
            stops: [0.0, 0.25, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Card Principal com animações
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Logo Centralizada
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Image.asset(
                                          'assets/logo.png',
                                          height: 90,
                                          width: 90,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  
                                  // Subtítulo
                                  const Text(
                                    'Bem-vindo de volta!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3FA9C6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Entre com sua conta para acessar a plataforma',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: 35),

                                  // BOTÕES PACIENTE/MÉDICO
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _tipoButton(
                                        tipo: 'paciente',
                                        texto: 'Paciente',
                                        imagem: 'assets/paciente.png',
                                      ),
                                      const SizedBox(width: 16),
                                      _tipoButton(
                                        tipo: 'medico',
                                        texto: 'Médico',
                                        imagem: 'assets/medico.png',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 35),

                                  // Campo de E-mail
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    enabled: !_isLoading,
                                    style: const TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      labelText: 'E-mail',
                                      hintText: 'seu@email.com',
                                      labelStyle: TextStyle(color: Colors.grey.shade600),
                                      hintStyle: TextStyle(color: Colors.grey.shade400),
                                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF7F7F7),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Digite seu e-mail';
                                      }
                                      if (!value.contains('@') || !value.contains('.')) {
                                        return 'E-mail inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),

                                  // Campo de Senha
                                  TextFormField(
                                    controller: _senhaController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    enabled: !_isLoading,
                                    onFieldSubmitted: (_) => _handleLogin(),
                                    style: const TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      labelText: 'Senha',
                                      labelStyle: TextStyle(color: Colors.grey.shade600),
                                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: Colors.grey.shade500,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF7F7F7),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Digite sua senha';
                                      }
                                      if (value.length < 6) {
                                        return 'A senha deve ter no mínimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Lembrar de mim e Esqueceu a senha
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: _isLoading ? null : (value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                  if (!_rememberMe) {
                                                    _saveCredentials();
                                                  }
                                                });
                                              },
                                              activeColor: const Color(0xFF3FA9C6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Lembrar de mim',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: _isLoading ? null : _handleResetPassword,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                        ),
                                        child: const Text(
                                          'Esqueceu a senha?',
                                          style: TextStyle(
                                            color: Color(0xFF3FA9C6),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Mensagem de erro
                                  if (_errorMessage != null) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.red[200]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: TextStyle(color: Colors.red[700], fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 28),

                                  // Botão de Login
                                  SizedBox(
                                    width: double.infinity,
                                    height: 58,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3FA9C6),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Entrar',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Divisória
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.grey.shade300)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'ou',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Colors.grey.shade300)),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Link para Cadastro
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Não tem conta?',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _isLoading ? null : () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const CadastroPage(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                        child: const Text(
                                          'Cadastre-se',
                                          style: TextStyle(
                                            color: Color(0xFF006B88),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tipoButton({
    required String tipo,
    required String texto,
    required String imagem,
  }) {
    final bool selecionado = _userType == tipo;

    return Expanded(
      child: GestureDetector(
        onTap: _isLoading ? null : () {
          setState(() {
            _userType = tipo;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 65,
          decoration: BoxDecoration(
            gradient: selecionado
                ? const LinearGradient(
                    colors: [Color(0xFF3FA9C6), Color(0xFF5FC7E4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selecionado ? null : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selecionado ? Colors.transparent : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: selecionado
                ? [
                    BoxShadow(
                      color: const Color(0xFF3FA9C6).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagem,
                height: 28,
                width: 28,
                color: selecionado ? Colors.white : Colors.grey.shade600,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    tipo == 'paciente' ? Icons.person : Icons.medical_services,
                    size: 26,
                    color: selecionado ? Colors.white : Colors.grey.shade600,
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                  color: selecionado ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}