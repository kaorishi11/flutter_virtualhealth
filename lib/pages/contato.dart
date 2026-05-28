import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'clinicas.dart';
import 'login.dart';
import 'chatbot.dart';
import 'cadastro.dart';
import 'home.dart';

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _mensagemController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _usuarioId;
  String? _usuarioEmail;
  String? _usuarioNome;

  @override
  void initState() {
    super.initState();
    _verificarUsuario();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _verificarUsuario() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    setState(() {
      _isLoggedIn = user != null;
    });
    
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('perfis')
            .select('id, nome_completo, email')
            .eq('auth_id', user.id)
            .maybeSingle();
        
        if (response != null && mounted) {
          setState(() {
            _usuarioId = response['id'];
            _usuarioNome = response['nome_completo'];
            _usuarioEmail = response['email'];
            _nomeController.text = _usuarioNome!;
            _emailController.text = _usuarioEmail!;
          });
        }
      } catch (e) {
        debugPrint('Erro ao buscar perfil: $e');
      }
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _usuarioId = null;
        _usuarioNome = null;
        _usuarioEmail = null;
        _nomeController.clear();
        _emailController.clear();
        _mensagemController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.logout, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Logout realizado com sucesso!'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
      
      await Supabase.instance.client
          .from('mensagens')
          .insert(dadosMensagem);
      
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
              Expanded(child: Text('Mensagem enviada com sucesso! Nossa equipe retornará em breve.')),
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
      
      String mensagemErro = 'Erro ao enviar mensagem. ';
      if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
        mensagemErro += 'A tabela "mensagens" não existe no banco de dados.';
      } else if (e.toString().contains('column')) {
        mensagemErro += 'Verifique as colunas da tabela "mensagens".';
      } else {
        mensagemErro += e.toString();
      }
      
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
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header com gradiente verde melhorado
              SliverToBoxAdapter(
                child: Container(
                  height: 350,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2E7D32),
                        Color(0xFF1B5E20),
                        Color(0xFF0A3B0E),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          Text(
                            'POSSUI ALGUMA DÚVIDA?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'NOS CONTATE',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6EF0C2),
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nossa equipe está pronta para te ajudar,',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'com rapidez e segurança',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6EF0C2),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Formulário de contato
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, -5),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
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
                          const Text(
                            'Envie sua mensagem',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
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
                            maxLines: 6,
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
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _enviarMensagem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Enviar Mensagem',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.send, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Footer
              SliverToBoxAdapter(
                child: _buildMobileFooter(),
              ),
            ],
          ),
          
          // Navbar com estilo glassmorphism (lateral esquerda)
          Positioned(
            top: 20,
            left: 20,
            child: _buildGlassNavbar(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            child: Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 22,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 350),
              ],
            ),
          ),
          
          // Separador
          Container(
            width: 1,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[300],
          ),
          
          // Menu Hamburguer
          GestureDetector(
            onTap: () => _showMenuBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.menu,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
            ),
          ),
        ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F9F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildMenuItem(
                icon: Icons.home_outlined,
                title: 'Início',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.local_hospital_outlined,
                title: 'Clínicas',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClinicasPage()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.chat_bubble_outline,
                title: 'Contato',
                isActive: true,
                onTap: () => Navigator.pop(context),
              ),
              _buildMenuItem(
                icon: Icons.calendar_today_outlined,
                title: 'Fazer Consulta',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatbotPage()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Cadastre-se / Logar',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroPage()),
                  );
                },
              ),
              if (_isLoggedIn) ...[
                const Divider(height: 1),
                _buildMenuItem(
                  icon: Icons.logout_outlined,
                  title: 'Sair',
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                  isDestructive: true,
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : (isActive ? const Color(0xFF2E7D32) : Colors.grey[600]),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isDestructive ? Colors.red : (isActive ? const Color(0xFF2E7D32) : Colors.grey[800]),
        ),
      ),
      trailing: isActive
          ? Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildMobileFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B5E20), Color(0xFF0A3B0E)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Serviços
          _buildFooterSection(
            title: 'Serviços',
            items: [
              'Teleconsulta 24h',
              'Agendamento online',
              'Especialidades',
              'Perguntas frequentes'
            ],
          ),
          const SizedBox(height: 24),
          
          // Virtual Health
          _buildFooterSection(
            title: 'Virtual Health',
            items: [
              'Seu médico virtual 24h',
            ],
          ),
          const SizedBox(height: 24),
          
          // Contato
          _buildFooterSection(
            title: 'Contato',
            items: [
              'Endereço: Sesi Caçapava SP',
              'Telefone: (12) 9966-9732',
              'Email: virtualhealthassistencia@gmail.com',
              'Horário: Equipe 24h'
            ],
          ),
          const SizedBox(height: 24),
          
          // Divisor
          Container(
            height: 1,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          
          // Copyright
          Center(
            child: Text(
              '© 2026 Virtual Health - Todos os direitos reservados',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFooterSection({required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                item,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            )),
      ],
    );
  }
}