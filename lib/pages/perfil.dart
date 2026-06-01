import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ConfigPerfilPage extends StatefulWidget {
  const ConfigPerfilPage({super.key});

  @override
  State<ConfigPerfilPage> createState() => _ConfigPerfilPageState();
}

class _ConfigPerfilPageState extends State<ConfigPerfilPage> {
  bool _loading = false;
  bool _showPassword = false;
  bool _editandoFoto = false;
  bool _fotoErro = false;
  bool _isLoggedIn = true;

  // Dados do usuário (mockados - sem banco de dados)
  final Map<String, dynamic> _userData = {
    'nome': 'Jamile de Oliveira Franquilim',
    'email': 'jamile@email.com',
    'funcao': 'paciente',
    'cpf': '123.456.789-00',
    'telefone': '(11) 91234-5678',
    'data_nascimento': '01/01/1990',
    'logradouro': 'Rua Exemplo, 123',
    'bairro': 'Centro',
    'cidade': 'São Paulo',
    'estado': 'SP',
    'foto': '',
  };

  final Map<String, String> _passwordData = {
    'senhaAtual': '',
    'novaSenha': '',
    'confirmarSenha': '',
  };

  final TextEditingController _novaFotoUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _senhaFormKey = GlobalKey<FormState>();

  String get _userName => _userData['nome'].split(' ')[0];
  String get _userFuncao => _userData['funcao'];

  @override
  void dispose() {
    _novaFotoUrlController.dispose();
    super.dispose();
  }

  String formatarCPF(String valor) {
    String cpf = valor.replaceAll(RegExp(r'\D'), '');
    if (cpf.length <= 11) {
      if (cpf.length >= 3 && cpf.length <= 5) {
        return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
      } else if (cpf.length >= 6 && cpf.length <= 8) {
        return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
      } else if (cpf.length >= 9) {
        return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
      }
    }
    return cpf;
  }

  String formatarTelefone(String valor) {
    String telefone = valor.replaceAll(RegExp(r'\D'), '');
    if (telefone.length == 10) {
      return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 6)}-${telefone.substring(6)}';
    } else if (telefone.length == 11) {
      return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}';
    }
    return telefone;
  }

  String getIniciais(String nome) {
    if (nome.isEmpty) return '?';
    final nomes = nome.trim().split(' ');
    if (nomes.length == 1) return nomes[0][0].toUpperCase();
    return (nomes[0][0] + nomes[nomes.length - 1][0]).toUpperCase();
  }

  int getCorFundo(String nome) {
    if (nome.isEmpty) return 0xFF14B8A6;

    final cores = [
      0xFF14B8A6, 0xFF0F766E, 0xFF0D2C33, 0xFF1A8F7A,
      0xFF2C9B8A, 0xFF3FA9C6, 0xFF5BB8D4, 0xFF7EC8E2,
    ];

    int hash = 0;
    for (int i = 0; i < nome.length; i++) {
      hash = nome.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % cores.length;
    return cores[index];
  }

  Future<void> _salvarDadosPessoais() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    _showSnackBar('Dados salvos com sucesso!', const Color(0xFF14B8A6));
    setState(() => _loading = false);
  }

  Future<void> _alterarSenha() async {
    if (!_senhaFormKey.currentState!.validate()) return;

    if (_passwordData['novaSenha'] != _passwordData['confirmarSenha']) {
      _showSnackBar('As senhas não coincidem!', Colors.orange);
      return;
    }

    if (_passwordData['novaSenha']!.length < 6) {
      _showSnackBar('A nova senha deve ter pelo menos 6 caracteres!', Colors.orange);
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    _showSnackBar('Senha alterada com sucesso!', const Color(0xFF14B8A6));
    setState(() {
      _passwordData.updateAll((key, value) => '');
      _loading = false;
    });
  }

  Future<void> _salvarFotoUrl() async {
    final url = _novaFotoUrlController.text.trim();

    if (url.isEmpty) {
      _showSnackBar('Digite uma URL válida', Colors.orange);
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _userData['foto'] = url;
      _editandoFoto = false;
      _novaFotoUrlController.clear();
      _fotoErro = false;
      _loading = false;
    });

    _showSnackBar('Foto atualizada com sucesso!', const Color(0xFF14B8A6));
  }

  Future<void> _selecionarImagemGaleria() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _userData['foto'] = 'https://via.placeholder.com/150';
        _editandoFoto = false;
        _fotoErro = false;
        _loading = false;
      });

      _showSnackBar('Foto atualizada com sucesso!', const Color(0xFF14B8A6));
    }
  }

  Future<void> _excluirConta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text('A exclusão é permanente! Todos os seus dados serão removidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    _showSnackBar('Conta excluída com sucesso!', const Color(0xFF14B8A6));
    setState(() => _loading = false);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
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
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _userData['nome'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userFuncao == 'paciente' ? 'Paciente' : 'Médico',
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Configurações de Perfil'),
        backgroundColor: const Color(0xFF0D2C33),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF14B8A6)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              child: Column(
                children: [
                  _buildFotoPerfil(isMobile),
                  const SizedBox(height: 24),
                  _buildDadosPessoaisCard(isMobile),
                  const SizedBox(height: 24),
                  _buildSegurancaCard(isMobile),
                  const SizedBox(height: 24),
                  _buildAlertaExclusao(),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 5,
        isLoggedIn: _isLoggedIn,
        onProfileTap: _showUserMenu,
      ),
    );
  }

  Widget _buildFotoPerfil(bool isMobile) {
    final String iniciais = getIniciais(_userData['nome']);
    final int corFundo = getCorFundo(_userData['nome']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(corFundo),
                    border: Border.all(color: const Color(0xFF14B8A6), width: 3),
                  ),
                  child: _userData['foto'] != null &&
                          _userData['foto'].toString().isNotEmpty &&
                          !_fotoErro
                      ? ClipOval(
                          child: Image.network(
                            _userData['foto'],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              _fotoErro = true;
                              return CircleAvatar(
                                radius: 60,
                                backgroundColor: Color(corFundo),
                                child: Text(iniciais, style: const TextStyle(fontSize: 40, color: Colors.white)),
                              );
                            },
                          ),
                        )
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(corFundo),
                          child: Text(iniciais, style: const TextStyle(fontSize: 40, color: Colors.white)),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => setState(() => _editandoFoto = true),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF14B8A6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_editandoFoto) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selecionarImagemGaleria,
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Galeria'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _editandoFoto = false),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF14B8A6),
                      side: const BorderSide(color: Color(0xFF14B8A6)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('ou', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _novaFotoUrlController,
                      decoration: InputDecoration(
                        hintText: 'Digite a URL da imagem',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF14B8A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _salvarFotoUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Text(
              _userData['nome'],
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D2C33),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _userData['email'],
              style: TextStyle(color: Colors.grey[600]),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _userFuncao == 'paciente' ? 'Paciente' : 'Médico',
                style: const TextStyle(color: Color(0xFF14B8A6), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDadosPessoaisCard(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF14B8A6)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DADOS PESSOAIS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D2C33)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 10,
                children: [
                  TextFormField(
                    initialValue: _userData['nome'],
                    decoration: InputDecoration(
                      labelText: 'Nome completo',
                      labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                      ),
                    ),
                    onChanged: (value) => _userData['nome'] = value,
                    validator: (value) => value == null || value.isEmpty ? 'Nome é obrigatório' : null,
                  ),
                  TextFormField(
                    initialValue: _userData['cpf'],
                    decoration: InputDecoration(
                      labelText: 'CPF',
                      labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                      ),
                      counterText: '',
                    ),
                    maxLength: 14,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                    onChanged: (value) => _userData['cpf'] = formatarCPF(value),
                  ),
                  TextFormField(
                    initialValue: _userData['email'],
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                      ),
                    ),
                    enabled: false,
                  ),
                  TextFormField(
                    initialValue: _userData['telefone'],
                    decoration: InputDecoration(
                      labelText: 'Telefone',
                      labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                      ),
                      counterText: '',
                    ),
                    maxLength: 15,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                    onChanged: (value) => _userData['telefone'] = formatarTelefone(value),
                  ),
                  TextFormField(
                    initialValue: _userData['logradouro'],
                    decoration: InputDecoration(
                      labelText: 'Logradouro',
                      labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                      ),
                    ),
                    onChanged: (value) => _userData['logradouro'] = value,
                  ),
                  TextFormField(
                    initialValue: _userData['bairro'],
                    decoration: InputDecoration(
                      labelText: 'Bairro',
                      labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                      ),
                    ),
                    onChanged: (value) => _userData['bairro'] = value,
                  ),
                  TextFormField(
                    initialValue: _userData['cidade'],
                    decoration: InputDecoration(
                      labelText: 'Cidade',
                      labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                      ),
                    ),
                    onChanged: (value) => _userData['cidade'] = value,
                  ),
                  TextFormField(
                    initialValue: _userData['estado'],
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                      ),
                      counterText: '',
                    ),
                    maxLength: 2,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')), LengthLimitingTextInputFormatter(2)],
                    onChanged: (value) => _userData['estado'] = value,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _salvarDadosPessoais,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Salvar alterações'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _userData['nome'] = 'Jamile de Oliveira Franquilim';
                          _userData['cpf'] = '123.456.789-00';
                          _userData['telefone'] = '(11) 91234-5678';
                          _userData['logradouro'] = 'Rua Exemplo, 123';
                          _userData['bairro'] = 'Centro';
                          _userData['cidade'] = 'São Paulo';
                          _userData['estado'] = 'SP';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF14B8A6),
                        side: const BorderSide(color: Color(0xFF14B8A6)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegurancaCard(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Form(
          key: _senhaFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock, color: Color(0xFF14B8A6)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SEGURANÇA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D2C33)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha atual',
                  labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                  ),
                ),
                onChanged: (value) => _passwordData['senhaAtual'] = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Nova senha',
                  labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF14B8A6)),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                onChanged: (value) => _passwordData['novaSenha'] = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar nova senha',
                  labelStyle: const TextStyle(color: Color(0xFF0D2C33)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                  ),
                ),
                onChanged: (value) => _passwordData['confirmarSenha'] = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _alterarSenha,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Alterar senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertaExclusao() {
    return Card(
      color: const Color(0xFFFEF3C7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ATENÇÃO!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD97706))),
                  const SizedBox(height: 8),
                  const Text(
                    'A exclusão da conta é permanente e não pode ser desfeita. Todos os seus dados, agendamentos e histórico médico serão removidos.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF78350F)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _excluirConta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Excluir conta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}