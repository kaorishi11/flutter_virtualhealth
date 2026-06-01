import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import 'login.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _tipoCadastro = 'paciente';

  // Controllers
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cepController = TextEditingController();
  final _cpfController = TextEditingController();

  // Médico
  final _telefoneController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _registroController = TextEditingController();
  final _universidadeController = TextEditingController();
  final _anoController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  DateTime? _selectedDate;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> especialidades = [
    'Cardiologia',
    'Gastroenterologia',
    'Dermatologia',
    'Pediatria',
    'Neurologia',
    'Psiquiatria',
    'Ortopedia',
    'Clínico Geral',
    'Outros',
  ];

  String? _especialidadeSelecionada;
  String? _generoSelecionado;

  @override
  void initState() {
    super.initState();
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
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _cepController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _dataNascimentoController.dispose();
    _registroController.dispose();
    _universidadeController.dispose();
    _anoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 25),
      ),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dataNascimentoController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    String? erro;

    if (_tipoCadastro == 'paciente') {
      erro = await _auth.cadastrarPaciente(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        cep: _cepController.text.trim(),
        cpf: _cpfController.text.trim(),
      );
    } else {
      erro = await _auth.cadastrarMedico(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        telefone: _telefoneController.text.trim(),
        cep: _cepController.text.trim(),
        dataNascimento: _selectedDate!,
        crm: _registroController.text.trim(),
        universidade: _universidadeController.text.trim(),
        anoFormacao: int.parse(_anoController.text.trim()),
        especialidade: _especialidadeSelecionada ?? '',
      );
    }

    setState(() => _loading = false);

    if (erro == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMedico = _tipoCadastro == 'medico';

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
                                  // Logo
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      height: 80,
                                      width: 80,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.medical_services,
                                          size: 80,
                                          color: Color(0xFF3FA9C6),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 10),
                                  
                                  // Título
                                  Text(
                                    isMedico ? 'Cadastro Médico' : 'Criar Conta',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3FA9C6),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Subtítulo
                                  Text(
                                    isMedico
                                        ? 'Junte-se à nossa plataforma e ajude muitas pessoas'
                                        : 'Cadastre-se para acessar nossa plataforma',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  const SizedBox(height: 35),

                                  // Botões Paciente/Médico
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

                                  // Nome
                                  _campo(
                                    titulo: 'Nome Completo',
                                    hint: 'Digite seu nome completo',
                                    controller: _nomeController,
                                  ),
                                  const SizedBox(height: 18),

                                  // Email
                                  _campo(
                                    titulo: 'E-mail',
                                    hint: 'Digite seu e-mail',
                                    controller: _emailController,
                                  ),
                                  const SizedBox(height: 18),

                                  // Telefone (apenas médico)
                                  if (isMedico) ...[
                                    _campo(
                                      titulo: 'Telefone',
                                      hint: 'Digite seu telefone',
                                      controller: _telefoneController,
                                    ),
                                    const SizedBox(height: 18),
                                  ],

                                  // CEP
                                  _campo(
                                    titulo: 'CEP',
                                    hint: 'Digite seu CEP',
                                    controller: _cepController,
                                  ),
                                  const SizedBox(height: 18),

                                  // CPF
                                  _campo(
                                    titulo: 'CPF',
                                    hint: 'Digite seu CPF',
                                    controller: _cpfController,
                                  ),

                                  // Campos específicos para médico
                                  if (isMedico) ...[
                                    const SizedBox(height: 18),
                                    
                                    // Data de Nascimento
                                    GestureDetector(
                                      onTap: _selecionarData,
                                      child: AbsorbPointer(
                                        child: _campo(
                                          titulo: 'Data de nascimento',
                                          hint: 'DD/MM/AAAA',
                                          controller: _dataNascimentoController,
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 18),
                                    
                                    // Gênero
                                    _dropdown(
                                      titulo: 'Gênero',
                                      valor: _generoSelecionado,
                                      itens: ['Masculino', 'Feminino', 'Outro'],
                                      onChanged: (v) {
                                        setState(() {
                                          _generoSelecionado = v;
                                        });
                                      },
                                    ),
                                    
                                    const SizedBox(height: 18),
                                    
                                    // Registro Profissional
                                    _campo(
                                      titulo: 'Registro profissional',
                                      hint: 'Ex: CRM-SP 00000',
                                      controller: _registroController,
                                    ),
                                    
                                    const SizedBox(height: 18),
                                    
                                    // Especialidade
                                    _dropdown(
                                      titulo: 'Especialidade',
                                      valor: _especialidadeSelecionada,
                                      itens: especialidades,
                                      onChanged: (v) {
                                        setState(() {
                                          _especialidadeSelecionada = v;
                                        });
                                      },
                                    ),
                                    
                                    const SizedBox(height: 18),
                                    
                                    // Universidade
                                    _campo(
                                      titulo: 'Universidade',
                                      hint: 'Ex: USP',
                                      controller: _universidadeController,
                                    ),
                                    
                                    const SizedBox(height: 18),
                                    
                                    // Ano de Formação
                                    _campo(
                                      titulo: 'Ano de Formação',
                                      hint: 'Digite o ano',
                                      controller: _anoController,
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 18),

                                  // Senha
                                  _campo(
                                    titulo: 'Senha',
                                    hint: 'Digite sua senha',
                                    controller: _senhaController,
                                    obscure: _obscurePassword,
                                    suffix: IconButton(
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
                                  ),
                                  
                                  const SizedBox(height: 30),

                                  // Botão de Cadastro
                                  SizedBox(
                                    width: double.infinity,
                                    height: 58,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _cadastrar,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3FA9C6),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Cadastrar',
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

                                  // Link para Login
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Já tem conta?',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _loading ? null : () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const LoginPage(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                        child: const Text(
                                          'Faça Login',
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
    final bool selecionado = _tipoCadastro == tipo;

    return Expanded(
      child: GestureDetector(
        onTap: _loading ? null : () {
          setState(() {
            _tipoCadastro = tipo;
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

  Widget _campo({
    required String titulo,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: !_loading,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo obrigatório';
            }
            if (titulo == 'E-mail' && (!value.contains('@') || !value.contains('.'))) {
              return 'E-mail inválido';
            }
            if (titulo == 'Senha' && value.length < 6) {
              return 'Senha deve ter no mínimo 6 caracteres';
            }
            if (titulo == 'Ano de Formação') {
              final ano = int.tryParse(value);
              if (ano == null || ano < 1950 || ano > DateTime.now().year) {
                return 'Ano inválido';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _dropdown({
    required String titulo,
    required String? valor,
    required List<String> itens,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: valor,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          hint: Text(
            'Selecione',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          items: itens.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: _loading ? null : onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecione uma opção';
            }
            return null;
          },
        ),
      ],
    );
  }
}