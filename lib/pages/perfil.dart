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
    if (nome.isEmpty) return 0xFF6366F1;

    final cores = [
      0xFF6366F1, 0xFF8B5CF6, 0xFFEC4899, 0xFFF43F5E,
      0xFFEF4444, 0xFFF97316, 0xFFF59E0B, 0xFF84CC16,
      0xFF10B981, 0xFF14B8A6, 0xFF06B6D4, 0xFF0EA5E9,
      0xFF3B82F6, 0xFF6366F1, 0xFF8B5CF6
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
    _showSnackBar('Dados salvos com sucesso!', Colors.green);
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
    _showSnackBar('Senha alterada com sucesso!', Colors.green);
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

    _showSnackBar('Foto atualizada com sucesso!', Colors.green);
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

      _showSnackBar('Foto atualizada com sucesso!', Colors.green);
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
    _showSnackBar('Conta excluída com sucesso!', Colors.green);
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
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF3FA9C6),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            // CORRIGIDO: usa _userData em vez de _userProfile
            Text(
              _userData['nome'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            // CORRIGIDO: usa _userFuncao que já existe
            Text(
              _userFuncao == 'paciente' ? 'Paciente' : 'Médico',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: Color(0xFF1565C0),
              ),
              title: const Text('Editar perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/perfil');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: Color(0xFF1565C0),
              ),
              title: const Text('Meus agendamentos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agendamentos');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Sair',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Configurações de Perfil'),
        backgroundColor: const Color(0xFF3FA9C6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildFotoPerfil(),
                  const SizedBox(height: 24),
                  _buildDadosPessoaisCard(),
                  const SizedBox(height: 24),
                  _buildSegurancaCard(),
                  const SizedBox(height: 24),
                  _buildAlertaExclusao(),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 4,
        isLoggedIn: _isLoggedIn,
        onProfileTap: _showUserMenu,
      ),
    );
  }

  Widget _buildFotoPerfil() {
    final String iniciais = getIniciais(_userData['nome']);
    final int corFundo = getCorFundo(_userData['nome']);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    border: Border.all(color: const Color(0xFF3FA9C6), width: 3),
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
                        color: Color(0xFF3FA9C6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_editandoFoto) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selecionarImagemGaleria,
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Galeria'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3FA9C6)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _editandoFoto = false),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancelar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('ou', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _novaFotoUrlController,
                      decoration: const InputDecoration(
                        hintText: 'Digite a URL da imagem',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _salvarFotoUrl,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              _userData['nome'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _userData['email'],
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDadosPessoaisCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFF3FA9C6)),
                  const SizedBox(width: 8),
                  const Text('DADOS PESSOAIS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 8,
                children: [
                  TextFormField(
                    initialValue: _userData['nome'],
                    decoration: const InputDecoration(labelText: 'Nome completo', border: OutlineInputBorder()),
                    onChanged: (value) => _userData['nome'] = value,
                    validator: (value) => value == null || value.isEmpty ? 'Nome é obrigatório' : null,
                  ),
                  TextFormField(
                    initialValue: _userData['cpf'],
                    decoration: const InputDecoration(labelText: 'CPF', border: OutlineInputBorder(), counterText: ''),
                    maxLength: 14,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                    onChanged: (value) => _userData['cpf'] = formatarCPF(value),
                  ),
                  TextFormField(
                    initialValue: _userData['email'],
                    decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                    enabled: false,
                  ),
                  TextFormField(
                    initialValue: _userData['telefone'],
                    decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder(), counterText: ''),
                    maxLength: 15,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                    onChanged: (value) => _userData['telefone'] = formatarTelefone(value),
                  ),
                  TextFormField(
                    initialValue: _userData['logradouro'],
                    decoration: const InputDecoration(labelText: 'Logradouro', border: OutlineInputBorder()),
                    onChanged: (value) => _userData['logradouro'] = value,
                  ),
                  TextFormField(
                    initialValue: _userData['bairro'],
                    decoration: const InputDecoration(labelText: 'Bairro', border: OutlineInputBorder()),
                    onChanged: (value) => _userData['bairro'] = value,
                  ),
                  TextFormField(
                    initialValue: _userData['cidade'],
                    decoration: const InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()),
                    onChanged: (value) => _userData['cidade'] = value,
                  ),
                  TextFormField(
                    initialValue: _userData['estado'],
                    decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                    maxLength: 2,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')), LengthLimitingTextInputFormatter(2)],
                    onChanged: (value) => _userData['estado'] = value,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _salvarDadosPessoais,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3FA9C6), padding: const EdgeInsets.symmetric(vertical: 12)),
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
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
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

  Widget _buildSegurancaCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _senhaFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock, color: Color(0xFF3FA9C6)),
                  const SizedBox(width: 8),
                  const Text('SEGURANÇA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha atual', border: OutlineInputBorder()),
                onChanged: (value) => _passwordData['senhaAtual'] = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Nova senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                onChanged: (value) => _passwordData['novaSenha'] = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: !_showPassword,
                decoration: const InputDecoration(labelText: 'Confirmar nova senha', border: OutlineInputBorder()),
                onChanged: (value) => _passwordData['confirmarSenha'] = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _alterarSenha,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3FA9C6), minimumSize: const Size(double.infinity, 45)),
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
      color: const Color(0xFFFFF3E0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ATENÇÃO!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                  const SizedBox(height: 8),
                  const Text(
                    'A exclusão da conta é permanente e não pode ser desfeita. Todos os seus dados, agendamentos e histórico médico serão removidos.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _excluirConta,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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