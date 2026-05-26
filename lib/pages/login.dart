import 'package:flutter/material.dart';
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

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String _userType = 'paciente';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    // TODO: Implementar carregamento de credenciais salvas
    if (_rememberMe) {
      // Carregar credenciais do storage
    }
  }

  Future<void> _saveCredentials() async {
    // TODO: Implementar salvamento de credenciais
    if (_rememberMe) {
      // Salvar credenciais no storage
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

      // Busca função do usuário no Supabase
      final funcao = await _auth.pegarFuncaoUsuario();

      if (funcao == null) {
        throw Exception(
          'Usuário sem função cadastrada.',
        );
      }

      // Admin ignora seleção
      if (funcao != 'admin') {
        // Valida botão paciente/médico
        if (funcao != _userType) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                'Você selecionou "$_userType", mas sua conta é "$funcao".',
              ),
              backgroundColor: Colors.red,
              behavior:
                  SnackBarBehavior.floating,
            ),
          );

          await _auth.logout();

          setState(() {
            _isLoading = false;
          });

          return;
        }
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Login realizado com sucesso!',
          ),
          backgroundColor: Colors.green,
          behavior:
              SnackBarBehavior.floating,
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
        MaterialPageRoute(
          builder: (_) => destino,
        ),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = error;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior:
              SnackBarBehavior.floating,
          duration:
              const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _errorMessage =
            'Erro inesperado. Tente novamente.';
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          backgroundColor: Colors.red,
          behavior:
              SnackBarBehavior.floating,
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
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo ou ícone para mobile
              Container(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                'assets/logo.png',
                height: 80,)
              ),
              
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Entre com sua conta para acessar a plataforma.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // BOTÕES PACIENTE/MÉDICO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tipoButton(
                    tipo: 'paciente',
                    texto: 'Sou\npaciente',
                    imagem: 'assets/paciente.png',
                    isMobile: true,
                  ),
                  const SizedBox(width: 16),
                  _tipoButton(
                    tipo: 'medico',
                    texto: 'Sou\nmédico',
                    imagem: 'assets/medico.png',
                    isMobile: true,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Campo de E-mail
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
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
              const SizedBox(height: 16),

              // Campo de Senha
              TextFormField(
                controller: _senhaController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
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
              const SizedBox(height: 16),

              // Lembrar de mim
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: _isLoading ? null : (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF3FA9C6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
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

              // Mensagem de erro
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
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
              const SizedBox(height: 24),

              // Botão de Login
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3FA9C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),

              // Link para Cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem conta?',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
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
                      'Cadastre-se aqui',
                      style: TextStyle(
                        color: Color(0xFF006B88),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Esqueceu a senha
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _handleResetPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      color: const Color(0xFF3FA9C6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // LADO ESQUERDO - IMAGEM
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB9DEFF),
                  Color(0xFF6DB7FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/mulhercomlogo.png',
                width: 690,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.medical_services,
                    size: 100,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
        ),

        // LADO DIREITO - FORMULÁRIO
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Bem-vindo de volta!',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Entre com sua conta para acessar a plataforma.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // BOTÕES PACIENTE/MÉDICO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _tipoButton(
                            tipo: 'paciente',
                            texto: 'Sou\npaciente',
                            imagem: 'assets/paciente.png',
                            isMobile: false,
                          ),
                          const SizedBox(width: 20),
                          _tipoButton(
                            tipo: 'medico',
                            texto: 'Sou\nmédico',
                            imagem: 'assets/medico.png',
                            isMobile: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Campo de E-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
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
                      const SizedBox(height: 20),

                      // Campo de Senha
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
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
                      const SizedBox(height: 16),

                      // Lembrar de mim
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: _isLoading ? null : (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF3FA9C6),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
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

                      // Mensagem de erro
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
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
                      const SizedBox(height: 30),

                      // Botão de Login
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3FA9C6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Link para Cadastro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Não tem conta?',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
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
                            child: const Text(
                              'Cadastre-se aqui',
                              style: TextStyle(
                                color: Color(0xFF006B88),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Esqueceu a senha
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleResetPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              color: const Color(0xFF3FA9C6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tipoButton({
    required String tipo,
    required String texto,
    required String imagem,
    required bool isMobile,
  }) {
    final bool selecionado = _userType == tipo;

    return GestureDetector(
      onTap: _isLoading ? null : () {
        setState(() {
          _userType = tipo;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isMobile ? 130 : 150,
        height: isMobile ? 65 : 75,
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(0xFFAEE8F5)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagem,
              width: isMobile ? 28 : 38,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  tipo == 'paciente' ? Icons.person : Icons.medical_services,
                  size: isMobile ? 28 : 38,
                  color: selecionado ? const Color(0xFF006B88) : Colors.grey.shade600,
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              texto,
              style: TextStyle(
                fontSize: isMobile ? 13 : 16,
                color: selecionado ? const Color(0xFF006B88) : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}