// lib/adm/admin_usuarios.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Usuários';
  
  List<Map<String, dynamic>> usuarios = [];
  bool isLoading = true;
  String filtroFuncao = 'todos';
  String busca = '';

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    setState(() => isLoading = true);
    try {
      var query = supabase.from('perfis').select('''
        id,
        nome_completo,
        email,
        funcao,
        cpf,
        telefone,
        ativo,
        criado_em,
        cep,
        genero,
        data_nascimento,
        endereco,
        cidade,
        estado,
        metadados
      ''');

      if (filtroFuncao != 'todos') {
        query = query.eq('funcao', filtroFuncao);
      }

      final response = await query;
      setState(() {
        usuarios = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get usuariosFiltrados {
    if (busca.isEmpty) return usuarios;
    return usuarios.where((user) {
      final nome = user['nome_completo']?.toLowerCase() ?? '';
      final email = user['email']?.toLowerCase() ?? '';
      final termo = busca.toLowerCase();
      return nome.contains(termo) || email.contains(termo);
    }).toList();
  }

  Future<void> alternarStatusUsuario(String id, bool ativoAtual) async {
    try {
      await supabase
          .from('perfis')
          .update({'ativo': !ativoAtual, 'atualizado_em': DateTime.now().toIso8601String()})
          .eq('id', id);
      await carregarUsuarios();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!ativoAtual ? 'Usuário ativado' : 'Usuário desativado'),
            backgroundColor: !ativoAtual ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> excluirUsuario(String id, String nome) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir Usuário'),
        content: Text(
          'Tem certeza que deseja excluir o usuário "$nome"?\n\nEsta ação não pode ser desfeita.',
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

    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        await supabase.from('perfis').delete().eq('id', id);
        await carregarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir usuário: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> editarUsuario(Map<String, dynamic> user) async {
    final nomeController = TextEditingController(text: user['nome_completo']);
    final emailController = TextEditingController(text: user['email']);
    final telefoneController = TextEditingController(text: user['telefone'] ?? '');
    final cepController = TextEditingController(text: user['cep'] ?? '');
    final enderecoController = TextEditingController(text: user['endereco'] ?? '');
    final cidadeController = TextEditingController(text: user['cidade'] ?? '');
    final estadoController = TextEditingController(text: user['estado'] ?? '');
    
    String? funcaoSelecionada = user['funcao'];
    String? generoSelecionado = user['genero'];
    DateTime? dataNascimento = user['data_nascimento'] != null 
        ? DateTime.parse(user['data_nascimento']) 
        : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Editar Usuário: ${user['nome_completo']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                enabled: false, // Email não pode ser alterado
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: funcaoSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Função',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'paciente', child: Text('Paciente')),
                  DropdownMenuItem(value: 'medico', child: Text('Médico')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (value) {
                  funcaoSelecionada = value;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: generoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                ],
                onChanged: (value) {
                  generoSelecionado = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cepController,
                decoration: const InputDecoration(
                  labelText: 'CEP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cidadeController,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: estadoController,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Data de Nascimento'),
                subtitle: Text(
                  dataNascimento != null
                      ? '${dataNascimento!.day}/${dataNascimento!.month}/${dataNascimento!.year}'
                      : 'Não informada',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dataNascimento ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    dataNascimento = picked;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => isLoading = true);
      try {
        final updates = {
          'nome_completo': nomeController.text.trim(),
          'telefone': telefoneController.text.trim(),
          'funcao': funcaoSelecionada,
          'genero': generoSelecionado,
          'cep': cepController.text.trim(),
          'endereco': enderecoController.text.trim(),
          'cidade': cidadeController.text.trim(),
          'estado': estadoController.text.trim(),
          'data_nascimento': dataNascimento?.toIso8601String(),
          'atualizado_em': DateTime.now().toIso8601String(),
        };

        await supabase.from('perfis').update(updates).eq('id', user['id']);
        await carregarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário atualizado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar usuário: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => isLoading = false);
      }
    }
  }

  Color getFuncaoColor(String funcao) {
    switch (funcao) {
      case 'admin':
        return Colors.red;
      case 'medico':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  void _navigateToPage(String page) {
  setState(() {
    _currentPage = page;
  });

  if (page == 'Dashboard') {
    Navigator.pop(context);
  } 
  else if (page == 'Usuários') {
    // já está na página
  } 
  else if (page == 'Profissionais') {
    Navigator.pushNamed(context, '/admin-profissionais');
  } 
  else if (page == 'Consultas') {
    Navigator.pushNamed(context, '/admin-consultas');
  } 
  else if (page == 'Clínicas') {
    Navigator.pushNamed(context, '/admin-clinicas');
  } 
  else if (page == 'Mensagens') {
    Navigator.pushNamed(context, '/admin-mensagens');
  }
}

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      backgroundColor: const Color(0xfff4f6f8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: isMobile ? 120 : 180),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Barra de busca
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar por nome ou email...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              setState(() => busca = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          // Filtros
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('Todos'),
                                  selected: filtroFuncao == 'todos',
                                  onSelected: (_) {
                                    setState(() => filtroFuncao = 'todos');
                                    carregarUsuarios();
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Pacientes'),
                                  selected: filtroFuncao == 'paciente',
                                  onSelected: (_) {
                                    setState(() => filtroFuncao = 'paciente');
                                    carregarUsuarios();
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Médicos'),
                                  selected: filtroFuncao == 'medico',
                                  onSelected: (_) {
                                    setState(() => filtroFuncao = 'medico');
                                    carregarUsuarios();
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Administradores'),
                                  selected: filtroFuncao == 'admin',
                                  onSelected: (_) {
                                    setState(() => filtroFuncao = 'admin');
                                    carregarUsuarios();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Lista de usuários
                          Expanded(
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : usuariosFiltrados.isEmpty
                                    ? const Center(child: Text('Nenhum usuário encontrado'))
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: usuariosFiltrados.length,
                                        itemBuilder: (context, index) {
                                          final user = usuariosFiltrados[index];
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: getFuncaoColor(user['funcao']),
                                                    child: Text(
                                                      user['nome_completo']?[0]?.toUpperCase() ?? '?',
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    user['nome_completo'] ?? 'Sem nome',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(user['email'] ?? 'Sem email'),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: getFuncaoColor(user['funcao'])
                                                                  .withValues(alpha: 0.2),
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Text(
                                                              user['funcao'] ?? 'paciente',
                                                              style: TextStyle(
                                                                color: getFuncaoColor(user['funcao']),
                                                                fontSize: 11,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          if (user['ativo'] == false)
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: Colors.red.withValues(alpha: 0.2),
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              child: const Text(
                                                                'Inativo',
                                                                style: TextStyle(
                                                                  color: Colors.red,
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      // Botão Editar
                                                      IconButton(
                                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                                        onPressed: () => editarUsuario(user),
                                                        tooltip: 'Editar',
                                                      ),
                                                      // Botão Excluir
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => excluirUsuario(user['id'], user['nome_completo'] ?? ''),
                                                        tooltip: 'Excluir',
                                                      ),
                                                      // Switch de ativo/inativo
                                                      Switch(
                                                        value: user['ativo'] ?? true,
                                                        onChanged: (_) => alternarStatusUsuario(
                                                          user['id'],
                                                          user['ativo'] ?? true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    _showDetalhesUsuario(user);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
    final navItems = ['Dashboard', 'Usuários', 'Profissionais', 'Consultas', 'Clínicas', 'Mensagens'];

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
              icon: const Icon(Icons.menu, size: 28, color: Colors.teal),
            ),
            Image.asset(
              'assets/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.medical_services, size: 50, color: Colors.teal);
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              'assets/logo.png',
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.medical_services, size: 60, color: Colors.teal);
              },
            ),
          ),
          Row(
            children: navItems.map((item) {
              final isActive = _currentPage == item;
              return GestureDetector(
                onTap: () => _navigateToPage(item),
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
                          color: isActive ? Colors.teal : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isActive ? 24 : 0,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal, Colors.tealAccent],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.medical_services, size: 80, color: Colors.white);
                  },
                ),
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem('Dashboard', Icons.dashboard, () {
                    Navigator.pop(context);
                    _navigateToPage('Dashboard');
                  }),
                  _buildDrawerItem('Usuários', Icons.people, () {
                    Navigator.pop(context);
                    _navigateToPage('Usuários');
                  }),
                  _buildDrawerItem('Profissionais', Icons.medical_services, () {
                    Navigator.pop(context);
                    _navigateToPage('Profissionais');
                  }),
                  _buildDrawerItem('Consultas', Icons.calendar_today, () {
                    Navigator.pop(context);
                    _navigateToPage('Consultas');
                  }),
                  _buildDrawerItem('Clínicas', Icons.business, () {
                    Navigator.pop(context);
                    _navigateToPage('Clínicas');
                  }),
                  _buildDrawerItem('Mensagens', Icons.mail, () {
                    Navigator.pop(context);
                    _navigateToPage('Mensagens');
                  }),
                  const Divider(color: Colors.white54, thickness: 1),
                  _buildDrawerItem('Sair', Icons.logout, () {
                    Navigator.pop(context);
                    _navigateToPage('Sair');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      splashColor: Colors.white.withOpacity(0.2),
    );
  }

  void _showDetalhesUsuario(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: getFuncaoColor(user['funcao']),
              child: Text(
                user['nome_completo']?[0]?.toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(user['nome_completo'] ?? 'Usuário')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detalheLinha('Email', user['email']),
              const Divider(),
              _detalheLinha('Função', user['funcao']),
              const Divider(),
              _detalheLinha('CPF', user['cpf'] ?? 'Não informado'),
              const Divider(),
              _detalheLinha('Telefone', user['telefone'] ?? 'Não informado'),
              const Divider(),
              _detalheLinha('CEP', user['cep'] ?? 'Não informado'),
              const Divider(),
              _detalheLinha('Endereço', user['endereco'] ?? 'Não informado'),
              const Divider(),
              _detalheLinha('Cidade', user['cidade'] ?? 'Não informado'),
              const Divider(),
              _detalheLinha('Estado', user['estado'] ?? 'Não informado'),
              const Divider(),
              _detalheLinha('Gênero', user['genero'] ?? 'Não informado'),
              const Divider(),
              _detalheLinha(
                  'Data Nascimento',
                  user['data_nascimento'] != null
                      ? DateTime.parse(user['data_nascimento']).toLocal().toString().split(' ')[0]
                      : 'Não informado'),
              const Divider(),
              _detalheLinha(
                  'Cadastrado em',
                  user['criado_em'] != null
                      ? DateTime.parse(user['criado_em'])
                          .toLocal()
                          .toString()
                          .split('.')[0]
                      : 'N/A'),
              const Divider(),
              _detalheLinha(
                  'Status', user['ativo'] == true ? 'Ativo' : 'Inativo'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _detalheLinha(String titulo, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(valor ?? 'Não informado'),
          ),
        ],
      ),
    );
  }
}