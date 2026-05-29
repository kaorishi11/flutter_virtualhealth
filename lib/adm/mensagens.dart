// lib/adm/admin_mensagens.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_home.dart';
import 'usuarios.dart';
import 'profissionais.dart';
import 'consultas.dart';
import 'clinicas.dart';

class AdminMensagensPage extends StatefulWidget {
  const AdminMensagensPage({super.key});

  @override
  State<AdminMensagensPage> createState() => _AdminMensagensPageState();
}

class _AdminMensagensPageState extends State<AdminMensagensPage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Mensagens';
  
  List<Map<String, dynamic>> mensagens = [];
  bool isLoading = true;
  String filtroStatus = 'todos';
  String busca = '';

  @override
  void initState() {
    super.initState();
    carregarMensagens();
  }

  Future<void> carregarMensagens() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase.from('mensagens').select('''
        id,
        nome_remetente,
        email_remetente,
        mensagem,
        status,
        criado_em,
        atualizado_em,
        usuario_id,
        perfis!mensagens_usuario_id_fkey (
          id,
          nome_completo,
          email
        )
      ''');

      List<Map<String, dynamic>> mensagensData = List<Map<String, dynamic>>.from(response);

      mensagensData.sort((a, b) {
        final dataA = DateTime.tryParse(a['criado_em'].toString()) ?? DateTime(2000);
        final dataB = DateTime.tryParse(b['criado_em'].toString()) ?? DateTime(2000);
        return dataB.compareTo(dataA);
      });

      setState(() {
        mensagens = mensagensData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar mensagens: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar mensagens: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get mensagensFiltradas {
    var resultado = mensagens;
    
    // Filtro por status (apenas pendente e visto)
    if (filtroStatus != 'todos') {
      resultado = resultado.where((msg) => msg['status'] == filtroStatus).toList();
    }
    
    // Filtro por busca
    if (busca.isNotEmpty) {
      final termo = busca.toLowerCase();
      resultado = resultado.where((msg) {
        final nome = msg['nome_remetente']?.toLowerCase() ?? '';
        final email = msg['email_remetente']?.toLowerCase() ?? '';
        final perfil = msg['perfis'] as Map<String, dynamic>?;
        final nomePerfil = perfil?['nome_completo']?.toLowerCase() ?? '';
        return nome.contains(termo) || email.contains(termo) || nomePerfil.contains(termo);
      }).toList();
    }
    
    return resultado;
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    try {
      await supabase
          .from('mensagens')
          .update({
            'status': novoStatus,
            'atualizado_em': DateTime.now().toIso8601String()
          })
          .eq('id', id);
      await carregarMensagens();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mensagem marcada como ${novoStatus == 'visto' ? 'vista' : 'pendente'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> editarMensagem(Map<String, dynamic> mensagem) async {
    final nomeController = TextEditingController(text: mensagem['nome_remetente']);
    final emailController = TextEditingController(text: mensagem['email_remetente'] ?? '');
    final mensagemController = TextEditingController(text: mensagem['mensagem']);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Mensagem'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Remetente',
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
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mensagemController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
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
        await supabase.from('mensagens').update({
          'nome_remetente': nomeController.text.trim(),
          'email_remetente': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
          'mensagem': mensagemController.text.trim(),
          'atualizado_em': DateTime.now().toIso8601String(),
        }).eq('id', mensagem['id']);
        
        await carregarMensagens();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mensagem editada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao editar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> excluirMensagem(String id, String nome) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir Mensagem'),
        content: Text(
          'Tem certeza que deseja excluir a mensagem de "$nome"?\n\nEsta ação não pode ser desfeita.',
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
        await supabase.from('mensagens').delete().eq('id', id);
        await carregarMensagens();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mensagem excluída com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir mensagem: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => isLoading = false);
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'visto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'visto':
        return 'Visto';
      default:
        return status;
    }
  }

  String formatarData(String? dataIso) {
    if (dataIso == null) return 'Data não informada';
    try {
      final data = DateTime.parse(dataIso).toLocal();
      return '${data.day}/${data.month}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dataIso;
    }
  }

  void _navigateToPage(String page) {
    if (page == 'Dashboard') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomePage()),
      );
    } 
    else if (page == 'Usuários') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminUsuariosPage()),
      );
    } 
    else if (page == 'Profissionais') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminProfissionaisPage()),
      );
    } 
    else if (page == 'Consultas') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminConsultasPage()),
      );
    } 
    else if (page == 'Clínicas') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminClinicasPage()),
      );
    } 
    else if (page == 'Mensagens') {
      // já está na página
    }
  }

  void _showDetalhesMensagem(Map<String, dynamic> msg) {
    final perfil = msg['perfis'] as Map<String, dynamic>?;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: getStatusColor(msg['status']),
              child: Icon(
                msg['status'] == 'pendente' ? Icons.mark_email_unread : Icons.mark_email_read,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg['nome_remetente'] ?? perfil?['nome_completo'] ?? 'Mensagem',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detalheLinha('Email', msg['email_remetente'] ?? perfil?['email'] ?? 'Não informado'),
              const Divider(),
              _detalheLinha('Status', getStatusText(msg['status'])),
              const Divider(),
              _detalheLinha('Enviado em', formatarData(msg['criado_em'])),
              if (msg['atualizado_em'] != null && msg['atualizado_em'] != msg['criado_em'])
                _detalheLinha('Editado em', formatarData(msg['atualizado_em'])),
              if (perfil != null) ...[
                const Divider(),
                _detalheLinha('Usuário', perfil['nome_completo']),
                _detalheLinha('Email usuário', perfil['email']),
              ],
              const Divider(),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mensagem:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      msg['mensagem'] ?? 'Sem conteúdo',
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
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
            width: 100,
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
                                  label: const Text('Todas'),
                                  selected: filtroStatus == 'todos',
                                  onSelected: (_) {
                                    setState(() => filtroStatus = 'todos');
                                    carregarMensagens();
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Pendentes'),
                                  selected: filtroStatus == 'pendente',
                                  onSelected: (_) {
                                    setState(() => filtroStatus = 'pendente');
                                    carregarMensagens();
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Vistas'),
                                  selected: filtroStatus == 'visto',
                                  onSelected: (_) {
                                    setState(() => filtroStatus = 'visto');
                                    carregarMensagens();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Lista de mensagens
                          Expanded(
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : mensagensFiltradas.isEmpty
                                    ? const Center(child: Text('Nenhuma mensagem encontrada'))
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: mensagensFiltradas.length,
                                        itemBuilder: (context, index) {
                                          final msg = mensagensFiltradas[index];
                                          final perfil = msg['perfis'] as Map<String, dynamic>?;
                                          final status = msg['status'] ?? 'pendente';
                                          final isPendente = status == 'pendente';
                                          final remetente = msg['nome_remetente'] ?? perfil?['nome_completo'] ?? 'Anônimo';
                                          
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: getStatusColor(status),
                                                    child: Icon(
                                                      isPendente ? Icons.mark_email_unread : Icons.mark_email_read,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          remetente,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      if (isPendente)
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.orange.withValues(alpha: 0.2),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: const Text(
                                                            'NOVA',
                                                            style: TextStyle(
                                                              color: Colors.orange,
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        msg['email_remetente'] ?? perfil?['email'] ?? 'Sem email',
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: getStatusColor(status).withValues(alpha: 0.2),
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Text(
                                                              getStatusText(status),
                                                              style: TextStyle(
                                                                color: getStatusColor(status),
                                                                fontSize: 11,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            formatarData(msg['criado_em']),
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              color: Colors.grey,
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
                                                        onPressed: () => editarMensagem(msg),
                                                        tooltip: 'Editar',
                                                      ),
                                                      // Botão Excluir
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => excluirMensagem(msg['id'], remetente),
                                                        tooltip: 'Excluir',
                                                      ),
                                                      // Botão de marcar como visto
                                                      if (status == 'pendente')
                                                        IconButton(
                                                          icon: const Icon(Icons.done_all, color: Colors.green),
                                                          onPressed: () => atualizarStatus(msg['id'], 'visto'),
                                                          tooltip: 'Marcar como visto',
                                                        ),
                                                      if (status == 'visto')
                                                        IconButton(
                                                          icon: const Icon(Icons.mark_email_unread, color: Colors.orange),
                                                          onPressed: () => atualizarStatus(msg['id'], 'pendente'),
                                                          tooltip: 'Marcar como não lido',
                                                        ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    _showDetalhesMensagem(msg);
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
            onTap: () => _navigateToPage('Dashboard'),
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
                    // Implementar logout
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
}