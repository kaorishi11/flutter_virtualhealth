import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> _enviarMensagem() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Verifica se a tabela existe (opcional, apenas para debug)
      debugPrint('Tentando enviar mensagem...');
      debugPrint('Nome: ${_nomeController.text.trim()}');
      debugPrint('Email: ${_emailController.text.trim()}');
      debugPrint('Mensagem: ${_mensagemController.text.trim()}');
      
      final Map<String, dynamic> dadosMensagem = {
        'nome_remetente': _nomeController.text.trim(),
        'email_remetente': _emailController.text.trim(),
        'mensagem': _mensagemController.text.trim(),
        'status': 'pendente',
      };
      
      if (_isLoggedIn && _usuarioId != null) {
        dadosMensagem['usuario_id'] = _usuarioId;
      }
      
      debugPrint('Dados a serem inseridos: $dadosMensagem');
      
      // Insere na tabela 'mensagens'
      final response = await Supabase.instance.client
          .from('mensagens')
          .insert(dadosMensagem)
          .select();
      
      debugPrint('Resposta do Supabase: $response');
      
      if (!mounted) return;
      
      if (!_isLoggedIn) {
        _nomeController.clear();
        _emailController.clear();
      }
      _mensagemController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensagem enviada com sucesso! Nossa equipe retornará em breve.'),
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
          content: Text(mensagemErro),
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
      appBar: AppBar(
        title: const Text('Contato'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(40),
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              child: Column(
                children: [
                  const Text(
                    'POSSUI ALGUMA DÚVIDA? NOS CONTATE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                      children: const [
                        TextSpan(text: 'Nossa equipe está '),
                        TextSpan(
                          text: 'pronta para te ajudar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        TextSpan(text: ', com '),
                        TextSpan(
                          text: 'rapidez e segurança',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Formulário de contato
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fale Conosco',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoggedIn
                              ? 'Olá $_usuarioNome! Deixe sua mensagem abaixo.'
                              : 'Preencha os campos abaixo para enviar sua mensagem.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 32),
                        
                        // Nome Completo
                        _buildTextField(
                          controller: _nomeController,
                          label: 'NOME COMPLETO',
                          icon: Icons.person_outline,
                          enabled: !_isLoggedIn,
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
                          controller: _emailController,
                          label: 'E-MAIL',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoggedIn,
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
                          controller: _mensagemController,
                          label: 'SUA MENSAGEM',
                          icon: Icons.message_outlined,
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
                        
                        const SizedBox(height: 32),
                        
                        // Botão Enviar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
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
                                : const Text(
                                    'Enviar Mensagem',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
            
            const SizedBox(height: 48),
            
            // Footer com informações
            Container(
              padding: const EdgeInsets.all(40),
              color: const Color(0xFF1B5E20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Serviços
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Serviços',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildServiceItem('Teleconsulta 24h'),
                      _buildServiceItem('Agendamento online'),
                      _buildServiceItem('Especialidades'),
                      _buildServiceItem('Perguntas frequentes'),
                    ],
                  ),
                  
                  // Virtual Health
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Virtual Health',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Seu médico virtual 24h',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  
                  // Contato
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contato',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContactItem(Icons.location_on, 'Sesi Caçapava SP'),
                      _buildContactItem(Icons.phone, '(12) 9966-9732'),
                      _buildContactItem(Icons.email, 'Virtualhealthassistencia@gmail.com'),
                      _buildContactItem(Icons.access_time, 'Equipe 24h'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      ),
      validator: validator,
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white70),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}