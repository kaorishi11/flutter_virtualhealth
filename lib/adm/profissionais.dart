// lib/adm/admin_profissionais.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProfissionaisPage extends StatefulWidget {
  const AdminProfissionaisPage({super.key});

  @override
  State<AdminProfissionaisPage> createState() => _AdminProfissionaisPageState();
}

class _AdminProfissionaisPageState extends State<AdminProfissionaisPage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Profissionais';
  
  List<Map<String, dynamic>> profissionais = [];
  bool isLoading = true;
  String filtroStatus = 'todos';
  String busca = '';

  @override
  void initState() {
    super.initState();
    carregarProfissionais();
  }

  Future<void> carregarProfissionais() async {
    setState(() => isLoading = true);
    try {
      var query = supabase.from('profissionais').select('''
        id,
        especialidade,
        crm,
        status,
        preco,
        avaliacao,
        universidade,
        ano_formacao,
        perfis!profissionais_perfil_id_fkey (
          id,
          nome_completo,
          email,
          telefone,
          cep,
          endereco,
          cidade,
          estado,
          genero,
          data_nascimento,
          criado_em
        ),
        clinicas!profissionais_clinica_id_fkey (
          id,
          nome
        )
      ''');

      if (filtroStatus != 'todos') {
        query = query.eq('status', filtroStatus);
      }

      final response = await query;
      setState(() {
        profissionais = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get profissionaisFiltrados {
    if (busca.isEmpty) return profissionais;
    return profissionais.where((prof) {
      final perfil = prof['perfis'] as Map<String, dynamic>?;
      final nome = perfil?['nome_completo']?.toLowerCase() ?? '';
      final email = perfil?['email']?.toLowerCase() ?? '';
      final especialidade = prof['especialidade']?.toLowerCase() ?? '';
      final termo = busca.toLowerCase();
      return nome.contains(termo) || email.contains(termo) || especialidade.contains(termo);
    }).toList();
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    try {
      await supabase
          .from('profissionais')
          .update({
            'status': novoStatus,
            'atualizado_em': DateTime.now().toIso8601String()
          })
          .eq('id', id);
      await carregarProfissionais();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status atualizado para ${_getStatusText(novoStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> excluirProfissional(String id, String nome) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir Profissional'),
        content: Text(
          'Tem certeza que deseja excluir o profissional "$nome"?\n\nEsta ação não pode ser desfeita.',
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
        await supabase.from('profissionais').delete().eq('id', id);
        await carregarProfissionais();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profissional excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir profissional: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> editarProfissional(Map<String, dynamic> profissional) async {
    final perfil = profissional['perfis'] as Map<String, dynamic>?;
    
    final nomeController = TextEditingController(text: perfil?['nome_completo'] ?? '');
    final emailController = TextEditingController(text: perfil?['email'] ?? '');
    final telefoneController = TextEditingController(text: perfil?['telefone'] ?? '');
    final especialidadeController = TextEditingController(text: profissional['especialidade'] ?? '');
    final crmController = TextEditingController(text: profissional['crm'] ?? '');
    final universidadeController = TextEditingController(text: profissional['universidade'] ?? '');
    final anoFormacaoController = TextEditingController(text: profissional['ano_formacao']?.toString() ?? '');
    final precoController = TextEditingController(text: profissional['preco']?.toString() ?? '');
    
    String? statusSelecionado = profissional['status'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Editar Profissional: ${perfil?['nome_completo']}'),
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
              TextField(
                controller: especialidadeController,
                decoration: const InputDecoration(
                  labelText: 'Especialidade',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: crmController,
                decoration: const InputDecoration(
                  labelText: 'CRM',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: universidadeController,
                decoration: const InputDecoration(
                  labelText: 'Universidade',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: anoFormacaoController,
                decoration: const InputDecoration(
                  labelText: 'Ano de Formação',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço da Consulta',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: statusSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                  DropdownMenuItem(value: 'aceito', child: Text('Aprovado')),
                  DropdownMenuItem(value: 'negado', child: Text('Negado')),
                ],
                onChanged: (value) {
                  statusSelecionado = value;
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
        // Atualizar perfil
        await supabase.from('perfis').update({
          'nome_completo': nomeController.text.trim(),
          'email': emailController.text.trim(),
          'telefone': telefoneController.text.trim(),
          'atualizado_em': DateTime.now().toIso8601String(),
        }).eq('id', perfil?['id']);

        // Atualizar profissional
        await supabase.from('profissionais').update({
          'especialidade': especialidadeController.text.trim(),
          'crm': crmController.text.trim(),
          'universidade': universidadeController.text.trim(),
          'ano_formacao': int.tryParse(anoFormacaoController.text.trim()),
          'preco': double.tryParse(precoController.text.replaceAll(',', '.')),
          'status': statusSelecionado,
          'atualizado_em': DateTime.now().toIso8601String(),
        }).eq('id', profissional['id']);

        await carregarProfissionais();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profissional atualizado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar profissional: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'aceito':
        return Colors.green;
      case 'negado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'aceito':
        return 'Aprovado';
      case 'negado':
        return 'Negado';
      default:
        return status;
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
      Navigator.pushNamed(context, '/admin-usuarios');
    } 
    else if (page == 'Profissionais') {
      // já está na página
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
                              hintText: 'Buscar por nome, email ou especialidade...',
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
                                  selected: filtroStatus == 'todos',
                                  onSelected: (_) {
                                    setState(() => filtroStatus = 'todos');
                                    carregarProfissionais();
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Pendentes'),
                                  selected: filtroStatus == 'pendente',
                                  onSelected: (_) {
                                    setState(() => filtroStatus = 'pendente');
                                    carregarProfissionais();
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Aprovados'),
                                  selected: filtroStatus == 'aceito',
                                  onSelected: (_) {
                                    setState(() => filtroStatus = 'aceito');
                                    carregarProfissionais();
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Negados'),
                                  selected: filtroStatus == 'negado',
                                  onSelected: (_) {
                                    setState(() => filtroStatus = 'negado');
                                    carregarProfissionais();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Lista de profissionais
                          Expanded(
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : profissionaisFiltrados.isEmpty
                                    ? const Center(child: Text('Nenhum profissional encontrado'))
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: profissionaisFiltrados.length,
                                        itemBuilder: (context, index) {
                                          final prof = profissionaisFiltrados[index];
                                          final perfil = prof['perfis'] as Map<String, dynamic>?;
                                          final status = prof['status'] ?? 'pendente';

                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: _getStatusColor(status),
                                                    child: const Icon(Icons.medical_services, color: Colors.white),
                                                  ),
                                                  title: Text(
                                                    perfil?['nome_completo'] ?? 'Nome não informado',
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(prof['especialidade'] ?? 'Especialidade não informada'),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: _getStatusColor(status).withValues(alpha: 0.2),
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Text(
                                                              _getStatusText(status),
                                                              style: TextStyle(
                                                                color: _getStatusColor(status),
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
                                                        onPressed: () => editarProfissional(prof),
                                                        tooltip: 'Editar',
                                                      ),
                                                      // Botão Excluir
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => excluirProfissional(
                                                          prof['id'], 
                                                          perfil?['nome_completo'] ?? 'este profissional'
                                                        ),
                                                        tooltip: 'Excluir',
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    _showDetalhesProfissional(prof);
                                                  },
                                                ),
                                                // Botões de ação (Aprovar/Negar)
                                                if (status == 'pendente')
                                                  Padding(
                                                    padding: const EdgeInsets.all(12),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton.icon(
                                                            icon: const Icon(Icons.check, size: 18),
                                                            label: const Text('Aprovar'),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.green,
                                                              foregroundColor: Colors.white,
                                                            ),
                                                            onPressed: () => atualizarStatus(prof['id'], 'aceito'),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: ElevatedButton.icon(
                                                            icon: const Icon(Icons.close, size: 18),
                                                            label: const Text('Negar'),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.red,
                                                              foregroundColor: Colors.white,
                                                            ),
                                                            onPressed: () => atualizarStatus(prof['id'], 'negado'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (status == 'aceito')
                                                  Padding(
                                                    padding: const EdgeInsets.all(12),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: OutlinedButton.icon(
                                                        icon: const Icon(Icons.block),
                                                        label: const Text('Desabilitar profissional'),
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor: Colors.red,
                                                        ),
                                                        onPressed: () => atualizarStatus(prof['id'], 'negado'),
                                                      ),
                                                    ),
                                                  ),
                                                if (status == 'negado')
                                                  Padding(
                                                    padding: const EdgeInsets.all(12),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: OutlinedButton.icon(
                                                        icon: const Icon(Icons.refresh),
                                                        label: const Text('Reconsiderar'),
                                                        onPressed: () => atualizarStatus(prof['id'], 'pendente'),
                                                      ),
                                                    ),
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
                    // Adicionar lógica de logout aqui
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

  void _showDetalhesProfissional(Map<String, dynamic> profissional) {
    final perfil = profissional['perfis'] as Map<String, dynamic>?;
    final clinica = profissional['clinicas'] as Map<String, dynamic>?;
    final status = profissional['status'] ?? 'pendente';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getStatusColor(status),
              child: const Icon(Icons.medical_services, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(perfil?['nome_completo'] ?? 'Profissional')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoLinha('Email', perfil?['email']),
              const Divider(),
              _infoLinha('Telefone', perfil?['telefone']),
              const Divider(),
              _infoLinha('Especialidade', profissional['especialidade']),
              const Divider(),
              _infoLinha('CRM', profissional['crm']),
              const Divider(),
              _infoLinha('Universidade', profissional['universidade']),
              const Divider(),
              _infoLinha('Ano de Formação', profissional['ano_formacao']?.toString()),
              const Divider(),
              _infoLinha('Clínica', clinica?['nome']),
              const Divider(),
              _infoLinha('Preço', profissional['preco'] != null ? 'R\$ ${profissional['preco']}' : 'Não definido'),
              const Divider(),
              _infoLinha('Avaliação', profissional['avaliacao'] != null ? '${profissional['avaliacao']} ⭐' : 'Sem avaliações'),
              const Divider(),
              _infoLinha('Status', _getStatusText(status)),
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

  Widget _infoLinha(String titulo, String? valor) {
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