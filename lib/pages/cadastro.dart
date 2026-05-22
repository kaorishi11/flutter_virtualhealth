import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virtualhealth/services/auth_service.dart';
import 'login.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Tipo de cadastro
  String _tipoCadastro = 'paciente'; // 'paciente' ou 'medico'
  
  // Controllers comuns
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cepController = TextEditingController();
  
  // Controllers específicos do paciente
  final _cpfController = TextEditingController();
  
  // Controllers específicos do médico
  final _telefoneController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _registroProfissionalController = TextEditingController();
  final _universidadeController = TextEditingController();
  final _anoFormacaoController = TextEditingController();
  final _especialidadeController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _cepController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _dataNascimentoController.dispose();
    _registroProfissionalController.dispose();
    _universidadeController.dispose();
    _anoFormacaoController.dispose();
    _especialidadeController.dispose();
    super.dispose();
  }

  Future<void> _handleCadastro() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    String? error;
    
    if (_tipoCadastro == 'paciente') {
      error = await _auth.cadastrarPaciente(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        cep: _cepController.text.trim(),
        cpf: _cpfController.text.trim(),
      );
    } else {
      error = await _auth.cadastrarMedico(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        telefone: _telefoneController.text.trim(),
        cep: _cepController.text.trim(),
        dataNascimento: _selectedDate!,
        registroProfissional: _registroProfissionalController.text.trim(),
        universidade: _universidadeController.text.trim(),
        anoFormacao: int.parse(_anoFormacaoController.text.trim()),
        especialidade: _especialidadeController.text.trim(),
      );
    }
    
    setState(() => _isLoading = false);
    
    if (error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selecionarDataNascimento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[700]!, Colors.blue[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo/Título
                        Icon(
                          Icons.health_and_safety,
                          size: 64,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _tipoCadastro == 'paciente' 
                              ? 'Cadastre-se' 
                              : 'Bem-vindo Profissional',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tipoCadastro == 'paciente'
                              ? 'Acesse nossa plataforma e descubra ferramentas inovadoras.'
                              : 'Acesse nossa plataforma e ajude muitas pessoas.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Seletor de tipo (Paciente/Médico)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTypeButton('paciente', 'Sou paciente'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTypeButton('medico', 'Sou médico'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Nome Completo
                        _buildTextField(
                          controller: _nomeController,
                          label: 'Nome Completo',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite seu nome completo';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // E-mail
                        _buildTextField(
                          controller: _emailController,
                          label: 'E-mail',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite seu e-mail';
                            }
                            if (!value.contains('@')) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                        ),
                        
                        // Campos específicos para médico
                        if (_tipoCadastro == 'medico') ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _telefoneController,
                            label: 'Telefone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite seu telefone';
                              }
                              return null;
                            },
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // CEP
                        _buildTextField(
                          controller: _cepController,
                          label: 'CEP',
                          icon: Icons.location_on_outlined,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite seu CEP';
                            }
                            return null;
                          },
                        ),
                        
                        // CPF para paciente
                        if (_tipoCadastro == 'paciente') ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _cpfController,
                            label: 'CPF',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite seu CPF';
                              }
                              if (value.length < 11) {
                                return 'CPF inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                        
                        // Campos específicos para médico
                        if (_tipoCadastro == 'medico') ...[
                          const SizedBox(height: 16),
                          
                          // Data de Nascimento
                          GestureDetector(
                            onTap: _selecionarDataNascimento,
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: _dataNascimentoController,
                                label: 'Data de nascimento',
                                icon: Icons.cake_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione sua data de nascimento';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Registro Profissional (CRM)
                          _buildTextField(
                            controller: _registroProfissionalController,
                            label: 'Registro profissional (CRM)',
                            icon: Icons.medical_services_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite seu CRM';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Universidade
                          _buildTextField(
                            controller: _universidadeController,
                            label: 'Universidade',
                            icon: Icons.school_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite sua universidade';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Ano de Formação
                          _buildTextField(
                            controller: _anoFormacaoController,
                            label: 'Ano de Formação',
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o ano de formação';
                              }
                              final ano = int.tryParse(value);
                              if (ano == null || ano < 1900 || ano > DateTime.now().year) {
                                return 'Ano inválido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Especialidade
                          _buildTextField(
                            controller: _especialidadeController,
                            label: 'Especialidade',
                            icon: Icons.medical_information_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite sua especialidade';
                              }
                              return null;
                            },
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Senha
                        _buildTextField(
                          controller: _senhaController,
                          label: 'Senha',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
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
                        
                        const SizedBox(height: 24),
                        
                        // Botão Cadastrar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleCadastro,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
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
                                : const Text(
                                    'Cadastrar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Link para login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tem conta?',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                );
                              },
                              child: const Text(
                                'Faça Login',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildTypeButton(String tipo, String label) {
    final isSelected = _tipoCadastro == tipo;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoCadastro = tipo;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tipo == 'paciente' ? Icons.person : Icons.medical_services,
              size: 20,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue[700] : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
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
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        suffixIcon: suffixIcon,
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
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}