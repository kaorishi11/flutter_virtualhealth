import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import 'login.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
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

  final List<String> especialidades = [
    'Cardiologia',
    'Dermatologia',
    'Pediatria',
    'Neurologia',
    'Psiquiatria',
    'Ortopedia',
    'Clínico Geral',
  ];

  String? _especialidadeSelecionada;
  String? _generoSelecionado;

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
        registroProfissional: _registroController.text.trim(),
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
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: isMobile
            ? _buildMobileLayout(isMedico)
            : _buildDesktopLayout(isMedico),
      ),
    );
  }

  Widget _buildMobileLayout(bool isMedico) {
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
              
              Text(
                isMedico ? 'Bem-vindo Profissional' : 'Cadastre-se',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                isMedico
                    ? 'Acesse nossa plataforma e ajude muitas pessoas.'
                    : 'Acesse nossa plataforma e descubra ferramentas incríveis.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // BOTÕES
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tipoButton(
                    tipo: 'paciente',
                    texto: 'Sou\npaciente',
                    imagem: 'assets/paciente.png',
                  ),
                  const SizedBox(width: 20),
                  _tipoButton(
                    tipo: 'medico',
                    texto: 'Sou\nmédico',
                    imagem: 'assets/medico.png',
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // NOME
              _campo(
                titulo: isMedico ? 'Nome Completo' : 'Nome',
                hint: isMedico ? 'Digite seu nome completo' : 'Digite seu nome',
                controller: _nomeController,
              ),
              const SizedBox(height: 20),

              // EMAIL
              if (!isMedico)
                _campo(
                  titulo: 'E-mail',
                  hint: 'Digite seu e-mail',
                  controller: _emailController,
                ),
              if (isMedico) ...[
                _campo(
                  titulo: 'E-mail',
                  hint: 'Digite seu e-mail',
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                _campo(
                  titulo: 'Telefone',
                  hint: 'Digite seu telefone',
                  controller: _telefoneController,
                ),
              ],
              const SizedBox(height: 20),

              // CEP / CPF
              _campo(
                titulo: 'CEP',
                hint: 'Digite seu CEP',
                controller: _cepController,
              ),
              const SizedBox(height: 20),
              _campo(
                titulo: 'CPF',
                hint: 'Digite seu CPF',
                controller: _cpfController,
              ),

              // CAMPOS MÉDICO
              if (isMedico) ...[
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                _campo(
                  titulo: 'Registro profissional',
                  hint: 'Ex: CRM-SP 00000',
                  controller: _registroController,
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                _campo(
                  titulo: 'Universidade',
                  hint: 'Ex: USP',
                  controller: _universidadeController,
                ),
                const SizedBox(height: 20),
                _campo(
                  titulo: 'Ano de Formação',
                  hint: 'Digite o ano',
                  controller: _anoController,
                ),
              ],
              const SizedBox(height: 20),

              // SENHA
              _campo(
                titulo: 'Senha',
                hint: 'Digite sua senha',
                controller: _senhaController,
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),

              // BOTÃO
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _loading ? null : _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3FA9C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tem conta?',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Faça Login',
                      style: TextStyle(
                        color: Color(0xFF006B88),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isMedico) {
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
                      Text(
                        isMedico ? 'Bem-vindo Profissional' : 'Cadastre-se',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isMedico
                            ? 'Acesse nossa plataforma e ajude muitas pessoas.'
                            : 'Acesse nossa plataforma e descubra ferramentas incríveis.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // BOTÕES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _tipoButton(
                            tipo: 'paciente',
                            texto: 'Sou\npaciente',
                            imagem: 'assets/paciente.png',
                          ),
                          const SizedBox(width: 20),
                          _tipoButton(
                            tipo: 'medico',
                            texto: 'Sou\nmédico',
                            imagem: 'assets/medico.png',
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // NOME
                      _campo(
                        titulo: isMedico ? 'Nome Completo' : 'Nome',
                        hint: isMedico ? 'Digite seu nome completo' : 'Digite seu nome',
                        controller: _nomeController,
                      ),
                      const SizedBox(height: 20),

                      // EMAIL
                      if (!isMedico)
                        _campo(
                          titulo: 'E-mail',
                          hint: 'Digite seu e-mail',
                          controller: _emailController,
                        ),
                      if (isMedico)
                        Row(
                          children: [
                            Expanded(
                              child: _campo(
                                titulo: 'E-mail',
                                hint: 'Digite seu e-mail',
                                controller: _emailController,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _campo(
                                titulo: 'Telefone',
                                hint: 'Digite seu telefone',
                                controller: _telefoneController,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // CEP / CPF
                      Row(
                        children: [
                          Expanded(
                            child: _campo(
                              titulo: 'CEP',
                              hint: 'Digite seu CEP',
                              controller: _cepController,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _campo(
                              titulo: 'CPF',
                              hint: 'Digite seu CPF',
                              controller: _cpfController,
                            ),
                          ),
                        ],
                      ),

                      // CAMPOS MÉDICO
                      if (isMedico) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _selecionarData,
                                child: AbsorbPointer(
                                  child: _campo(
                                    titulo: 'Data de nascimento',
                                    hint: 'DD/MM/AAAA',
                                    controller: _dataNascimentoController,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _dropdown(
                                titulo: 'Gênero',
                                valor: _generoSelecionado,
                                itens: ['Masculino', 'Feminino', 'Outro'],
                                onChanged: (v) {
                                  setState(() {
                                    _generoSelecionado = v;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _campo(
                                titulo: 'Registro profissional',
                                hint: 'Ex: CRM-SP 00000',
                                controller: _registroController,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _dropdown(
                                titulo: 'Especialidade',
                                valor: _especialidadeSelecionada,
                                itens: especialidades,
                                onChanged: (v) {
                                  setState(() {
                                    _especialidadeSelecionada = v;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _campo(
                                titulo: 'Universidade',
                                hint: 'Ex: USP',
                                controller: _universidadeController,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _campo(
                                titulo: 'Ano de Formação',
                                hint: 'Digite o ano',
                                controller: _anoController,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      // SENHA
                      _campo(
                        titulo: 'Senha',
                        hint: 'Digite sua senha',
                        controller: _senhaController,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // BOTÃO
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _cadastrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3FA9C6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tem conta?',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Faça Login',
                              style: TextStyle(
                                color: Color(0xFF006B88),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
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
  }) {
    final bool selecionado = _tipoCadastro == tipo;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoCadastro = tipo;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 130,
        height: 70,
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFFAEE8F5) : Colors.white,
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
              width: 32,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  tipo == 'paciente' ? Icons.person : Icons.medical_services,
                  size: 32,
                  color: selecionado ? const Color(0xFF006B88) : Colors.grey,
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                color: selecionado ? const Color(0xFF006B88) : Colors.grey.shade700,
              ),
            ),
          ],
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: valor,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3FA9C6), width: 2),
            ),
          ),
          hint: const Text('Selecione'),
          items: itens.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
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