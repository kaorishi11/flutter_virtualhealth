import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PerfilMedicoPage extends StatefulWidget {
  const PerfilMedicoPage({super.key});

  @override
  State<PerfilMedicoPage> createState() => _PerfilMedicoPageState();
}

class _PerfilMedicoPageState extends State<PerfilMedicoPage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Meu Perfil';
  
  // Controllers para dados pessoais
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailPessoalController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailProfissionalController = TextEditingController();
  final TextEditingController _enderecoConsultorioController = TextEditingController();
  final TextEditingController _enderecoPessoalController = TextEditingController();
  
  // Controllers para segurança
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  
  // Controllers para valores
  final TextEditingController _valorPresencialController = TextEditingController();
  final TextEditingController _valorOnlineController = TextEditingController();
  
  // Dados do médico
  String _nomeMedico = '';
  String _nomeCompleto = '';
  String _especialidade = '';
  String _subEspecialidade = '';
  String _cidade = '';
  String _estado = '';
  String _dataNascimento = '';
  String _genero = '';
  String _fotoUrl = '';
  File? _imagemSelecionada;
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  final Color primaryColor = const Color(0xFF3FA9C6);
  
  @override
  void initState() {
    super.initState();
    _carregarDadosPerfil();
  }
  
  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailPessoalController.dispose();
    _telefoneController.dispose();
    _emailProfissionalController.dispose();
    _enderecoConsultorioController.dispose();
    _enderecoPessoalController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    _valorPresencialController.dispose();
    _valorOnlineController.dispose();
    super.dispose();
  }
  
  Future<void> _carregarDadosPerfil() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      // Buscar perfil
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();
      
      // Buscar profissional
      final profissional = await supabase
          .from('profissionais')
          .select()
          .eq('perfil_id', perfil['id'])
          .single();
      
      // Preencher dados
      _nomeCompleto = perfil['nome_completo'] ?? '';
      _nomeMedico = perfil['nome_completo']?.split(' ')[0] ?? 'Médico';
      _especialidade = profissional['especialidade'] ?? 'Médico';
      _subEspecialidade = profissional['universidade'] ?? 'Medicina Geral';
      _cidade = perfil['cidade'] ?? '';
      _estado = perfil['estado'] ?? '';
      _dataNascimento = perfil['data_nascimento'] ?? '';
      _genero = perfil['genero'] ?? '';
      _fotoUrl = perfil['metadados']?['foto_url'] ?? '';
      
      _nomeController.text = perfil['nome_completo'] ?? '';
      _cpfController.text = perfil['cpf'] ?? '';
      _emailPessoalController.text = perfil['email'] ?? '';
      _telefoneController.text = perfil['telefone'] ?? '';
      _emailProfissionalController.text = profissional['email'] ?? perfil['email'] ?? '';
      _enderecoConsultorioController.text = perfil['endereco'] ?? '';
      _enderecoPessoalController.text = perfil['endereco'] ?? '';
      
      _valorPresencialController.text = profissional['preco']?.toString() ?? '150';
      _valorOnlineController.text = profissional['preco_online']?.toString() ?? '120';
      
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      _carregarDadosMock();
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  void _carregarDadosMock() {
    _nomeCompleto = 'Dr. Médico';
    _nomeMedico = 'Dr. Médico';
    _especialidade = 'Médico';
    _subEspecialidade = 'Clínico Geral';
    _cidade = 'São Paulo';
    _estado = 'SP';
    
    _nomeController.text = 'Dr. Médico';
    _cpfController.text = '123.456.789-00';
    _emailPessoalController.text = 'medico@email.com';
    _telefoneController.text = '(11) 91234-5678';
    _emailProfissionalController.text = 'dr.medico@consultorio.com';
    _enderecoConsultorioController.text = 'Rua Principal, 123 - Centro, São Paulo - SP';
    _enderecoPessoalController.text = 'Av. das Flores, 456 - Jardins, São Paulo - SP';
    _valorPresencialController.text = '250';
    _valorOnlineController.text = '200';
  }
  
  Future<void> _salvarDadosPessoais() async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');
      
      // Atualizar perfil
      await supabase.from('perfis').update({
        'nome_completo': _nomeController.text,
        'cpf': _cpfController.text,
        'email': _emailPessoalController.text,
        'telefone': _telefoneController.text,
        'endereco': _enderecoPessoalController.text,
        'cidade': _cidade,
        'estado': _estado,
        'data_nascimento': _dataNascimento,
        'genero': _genero,
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('auth_id', user.id);
      
      // Atualizar profissional
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();
      
      await supabase.from('profissionais').update({
        'email': _emailProfissionalController.text,
        'preco': double.tryParse(_valorPresencialController.text),
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('perfil_id', perfil['id']);
      
      _mostrarSnackbar('Dados salvos com sucesso!');
      
    } catch (e) {
      debugPrint('Erro ao salvar: $e');
      _mostrarSnackbar('Erro ao salvar dados. Tente novamente.');
    }
    
    setState(() {
      _isSaving = false;
    });
  }
  
  Future<void> _alterarSenha() async {
    if (_senhaAtualController.text.trim().isEmpty) {
      _mostrarSnackbar('Digite sua senha atual');
      return;
    }

    if (_novaSenhaController.text.trim().isEmpty) {
      _mostrarSnackbar('Digite a nova senha');
      return;
    }

    if (_novaSenhaController.text != _confirmarSenhaController.text) {
      _mostrarSnackbar('As senhas não coincidem');
      return;
    }

    if (_novaSenhaController.text.length < 6) {
      _mostrarSnackbar('A nova senha deve ter pelo menos 6 caracteres');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');
      
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('Email do usuário não encontrado');
      }

      // 1. Verifica se a senha atual está correta
      await supabase.auth.signInWithPassword(
        email: email,
        password: _senhaAtualController.text.trim(),
      );

      // 2. Atualiza senha
      await supabase.auth.updateUser(
        UserAttributes(password: _novaSenhaController.text.trim()),
      );

      // limpa campos
      _senhaAtualController.clear();
      _novaSenhaController.clear();
      _confirmarSenhaController.clear();

      _mostrarSnackbar('Senha alterada com sucesso!');
    } catch (e) {
      debugPrint('Erro ao alterar senha: $e');
      _mostrarSnackbar('Senha atual incorreta ou erro ao alterar senha');
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  Future<void> _salvarValoresConsultas() async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');
      
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();
      
      await supabase.from('profissionais').update({
        'preco': double.tryParse(_valorPresencialController.text),
        'preco_online': double.tryParse(_valorOnlineController.text),
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('perfil_id', perfil['id']);
      
      _mostrarSnackbar('Valores salvos com sucesso!');
      
    } catch (e) {
      debugPrint('Erro ao salvar valores: $e');
      _mostrarSnackbar('Erro ao salvar valores');
    }
    
    setState(() {
      _isSaving = false;
    });
  }
  
  Future<void> _excluirConta() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta permanentemente'),
        content: const Text(
          'ATENÇÃO! A exclusão da conta é permanente e não pode ser desfeita. '
          'Todos os seus dados, agendamentos e histórico médico serão removidos.\n\n'
          'Tem certeza que deseja excluir sua conta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    
    if (confirmado == true) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        final user = supabase.auth.currentUser;
        if (user == null) throw Exception('Usuário não autenticado');
        
        await supabase.auth.signOut();
        _mostrarSnackbar('Conta excluída com sucesso');
        
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
        
      } catch (e) {
        debugPrint('Erro ao excluir conta: $e');
        _mostrarSnackbar('Erro ao excluir conta. Entre em contato com o suporte.');
      }
      
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  Future<void> _selecionarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
    
    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
      });
      
      try {
        final user = supabase.auth.currentUser;
        if (user == null) return;
        
        final fileExtension = imagem.path.split('.').last;
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        
        await supabase.storage
            .from('perfil_fotos')
            .upload(
              fileName,
              _imagemSelecionada!,
              fileOptions: const FileOptions(upsert: true),
            );

        final fotoUrl = supabase.storage.from('perfil_fotos').getPublicUrl(fileName);

        final perfil = await supabase
            .from('perfis')
            .select('metadados')
            .eq('auth_id', user.id)
            .single();

        final metadadosAtuais = Map<String, dynamic>.from(perfil['metadados'] ?? {});
        metadadosAtuais['foto_url'] = fotoUrl;

        await supabase.from('perfis').update({
          'metadados': metadadosAtuais,
        }).eq('auth_id', user.id);
        
        setState(() {
          _fotoUrl = fotoUrl;
        });
        
        _mostrarSnackbar('Foto atualizada com sucesso!');
        
      } catch (e) {
        debugPrint('Erro ao fazer upload: $e');
        _mostrarSnackbar('Erro ao atualizar foto');
      }
    }
  }
  
  void _mostrarSnackbar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _onPageChanged(String page) {
    if (page == 'Dashboard') {
      Navigator.pop(context);
    } else if (page == 'Minha Agenda') {
      Navigator.pop(context);
    } else if (page == 'Teleconsulta') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma consulta para iniciar a teleconsulta'),
          backgroundColor: Color(0xFF3FA9C6),
        ),
      );
    } else if (page == 'Dicas de Saúde') {
      Navigator.pop(context);
    } else if (page == 'Meu Perfil') {
      // Já está na página atual
    } else if (page == 'Sair') {
      _confirmLogout();
    }
  }
  
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _selecionarDataNascimento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    
    if (picked != null) {
      setState(() {
        _dataNascimento = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  void _selecionarGenero() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Selecione o gênero',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.female),
              title: const Text('Feminino'),
              onTap: () {
                setState(() => _genero = 'Feminino');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.male),
              title: const Text('Masculino'),
              onTap: () {
                setState(() => _genero = 'Masculino');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.transgender),
              title: const Text('Prefiro não informar'),
              onTap: () {
                setState(() => _genero = 'Não informado');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
  
  String _getIniciais(String nome) {
    if (nome.trim().isEmpty) return 'M';
    final partes = nome.trim().split(' ');
    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    }
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }
  
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      backgroundColor: const Color(0xfff5f7fa),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          return Stack(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _carregarDadosPerfil,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          top: isMobile ? 120 : 160,
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildFotoSection(),
                            const SizedBox(height: 24),
                            _buildSegurancaSection(),
                            const SizedBox(height: 24),
                            _buildValoresConsultasSection(),
                            const SizedBox(height: 24),
                            _buildDadosPessoaisSection(),
                            const SizedBox(height: 24),
                            _buildExcluirContaSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopNavigationBar(isMobile),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildTopNavigationBar(bool isMobile) {
    final navItems = ['Dashboard', 'Minha Agenda', 'Teleconsulta', 'Dicas de Saúde', 'Meu Perfil'];

    if (isMobile) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: const Icon(Icons.menu, size: 28, color: Color(0xFF3FA9C6)),
            ),
            Image.asset(
              'assets/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.medical_services, size: 50, color: Color(0xFF3FA9C6));
              },
            ),
            const SizedBox(width: 40),
          ],
        ),
      );
    }

    // Desktop layout
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.medical_services, size: 60, color: Color(0xFF3FA9C6));
            },
          ),
          Row(
            children: navItems.map((item) {
              final isActive = _currentPage == item;
              return GestureDetector(
                onTap: () => _onPageChanged(item),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isActive ? primaryColor : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isActive ? 24 : 0,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _confirmLogout(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawer() {
    final navItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard},
      {'title': 'Minha Agenda', 'icon': Icons.calendar_today},
      {'title': 'Teleconsulta', 'icon': Icons.video_call},
      {'title': 'Dicas de Saúde', 'icon': Icons.health_and_safety},
      {'title': 'Meu Perfil', 'icon': Icons.person},
    ];

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.medical_services, size: 80, color: Colors.white);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nomeCompleto.isNotEmpty ? _nomeCompleto : _nomeMedico,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _especialidade,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1),
            Expanded(
              child: ListView(
                children: [
                  ...navItems.map((item) => _buildDrawerItem(
                    item['title'] as String,
                    item['icon'] as IconData,
                    () {
                      Navigator.pop(context);
                      _onPageChanged(item['title'] as String);
                    },
                  )),
                  const Divider(color: Colors.white54, thickness: 1),
                  _buildDrawerItem('Sair', Icons.logout, () {
                    Navigator.pop(context);
                    _confirmLogout();
                  }, isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 18,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      splashColor: Colors.white.withOpacity(0.2),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getIniciais(_nomeCompleto.isNotEmpty ? _nomeCompleto : _nomeMedico),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_nomeCompleto.isNotEmpty ? _nomeCompleto : _nomeMedico).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_especialidade · $_subEspecialidade',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '$_cidade, $_estado',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFotoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FOTO DE PERFIL',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  backgroundImage: _imagemSelecionada != null
                      ? FileImage(_imagemSelecionada!)
                      : (_fotoUrl.isNotEmpty
                          ? NetworkImage(_fotoUrl) as ImageProvider
                          : null),
                  child: _imagemSelecionada == null && _fotoUrl.isEmpty
                      ? Text(
                          _getIniciais(_nomeCompleto.isNotEmpty ? _nomeCompleto : _nomeMedico),
                          style: TextStyle(fontSize: 32, color: primaryColor),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _selecionarFoto,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Editar foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSegurancaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEGURANÇA',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _senhaAtualController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha atual',
              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _novaSenhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Nova senha',
              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmarSenhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirmar nova senha',
              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _alterarSenha,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Alterar senha'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildValoresConsultasSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VALORES DAS CONSULTAS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valorPresencialController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Consulta presencial (R\$)',
              prefixIcon: Icon(Icons.attach_money, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valorOnlineController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Consulta Online (R\$)',
              prefixIcon: Icon(Icons.videocam, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _salvarValoresConsultas,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Salvar valores'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDadosPessoaisSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DADOS PESSOAIS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.person, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cpfController,
            decoration: InputDecoration(
              labelText: 'CPF',
              prefixIcon: Icon(Icons.badge, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailPessoalController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                            labelText: 'E-mail pessoal',
              prefixIcon: Icon(Icons.email, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telefone',
              prefixIcon: Icon(Icons.phone, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailProfissionalController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail profissional',
              prefixIcon: Icon(Icons.business_center, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selecionarDataNascimento,
            child: AbsorbPointer(
              child: TextField(
                controller: TextEditingController(
                  text: _dataNascimento.isNotEmpty
                    ? DateFormat('dd/MM/yyyy').format(
                        DateTime.tryParse(_dataNascimento) ?? DateTime.now(),
                      )
                    : '',
                ),
                decoration: InputDecoration(
                  labelText: 'Data de nascimento',
                  prefixIcon: Icon(Icons.cake, color: primaryColor),
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selecionarGenero,
            child: AbsorbPointer(
              child: TextField(
                controller: TextEditingController(text: _genero),
                decoration: InputDecoration(
                  labelText: 'Gênero',
                  prefixIcon: Icon(Icons.wc, color: primaryColor),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _enderecoConsultorioController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Endereço do consultório',
              prefixIcon: Icon(Icons.medical_services, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _enderecoPessoalController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Endereço residencial',
              prefixIcon: Icon(Icons.home, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _salvarDadosPessoais,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Salvar alterações'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _carregarDadosPerfil();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildExcluirContaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                'ATENÇÃO!',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A exclusão da conta é permanente e não pode ser desfeita. '
            'Todos os seus dados, agendamentos e histórico médico serão removidos.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _excluirConta,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Excluir conta permanentemente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}