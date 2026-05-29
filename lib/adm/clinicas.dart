// lib/adm/admin_clinicas.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminClinicasPage extends StatefulWidget {
  const AdminClinicasPage({super.key});

  @override
  State<AdminClinicasPage> createState() => _AdminClinicasPageState();
}

class _AdminClinicasPageState extends State<AdminClinicasPage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Clínicas';
  
  List<Map<String, dynamic>> clinicas = [];
  bool isLoading = true;
  String busca = '';

  @override
  void initState() {
    super.initState();
    carregarClinicas();
  }

  Future<void> carregarClinicas() async {
    setState(() => isLoading = true);
    try {
      var query = supabase.from('clinicas').select('''
        id,
        nome,
        endereco,
        cidade,
        estado,
        telefone,
        email,
        website,
        latitude,
        longitude,
        criado_em,
        atualizado_em
      ''').order('nome', ascending: true);

      final response = await query;
      setState(() {
        clinicas = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar clínicas: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get clinicasFiltradas {
    if (busca.isEmpty) return clinicas;
    return clinicas.where((clinica) {
      final nome = clinica['nome']?.toLowerCase() ?? '';
      final cidade = clinica['cidade']?.toLowerCase() ?? '';
      final endereco = clinica['endereco']?.toLowerCase() ?? '';
      final termo = busca.toLowerCase();
      return nome.contains(termo) || cidade.contains(termo) || endereco.contains(termo);
    }).toList();
  }

  Future<void> salvarClinica({
    String? id,
    required String nome,
    required String endereco,
    required String cidade,
    required String estado,
    required String telefone,
    required String email,
    String? website,
  }) async {
    try {
      final data = {
        'nome': nome,
        'endereco': endereco,
        'cidade': cidade,
        'estado': estado,
        'telefone': telefone,
        'email': email,
        'website': website ?? '',
        'atualizado_em': DateTime.now().toIso8601String(),
      };

      if (id == null) {
        await supabase.from('clinicas').insert(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clínica criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await supabase.from('clinicas').update(data).eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clínica atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      await carregarClinicas();
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> excluirClinica(String id, String nome) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a clínica "$nome"?\n\n'
          'Esta ação também afetará profissionais vinculados a esta clínica.',
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
      try {
        await supabase.from('clinicas').delete().eq('id', id);
        await carregarClinicas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clínica excluída com sucesso'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void showClinicaDialog({Map<String, dynamic>? clinica}) {
    final isEditing = clinica != null;
    final formKey = GlobalKey<FormState>();

    final nomeController = TextEditingController(text: clinica?['nome']);
    final enderecoController = TextEditingController(text: clinica?['endereco']);
    final cidadeController = TextEditingController(text: clinica?['cidade']);
    final estadoController = TextEditingController(text: clinica?['estado']);
    final telefoneController = TextEditingController(text: clinica?['telefone']);
    final emailController = TextEditingController(text: clinica?['email']);
    final websiteController = TextEditingController(text: clinica?['website']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isEditing ? Icons.edit : Icons.add_business, color: Colors.teal),
            const SizedBox(width: 8),
            Text(isEditing ? 'Editar Clínica' : 'Nova Clínica'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Clínica *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: enderecoController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: cidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Cidade *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: estadoController,
                        decoration: const InputDecoration(
                          labelText: 'UF *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                        maxLength: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo obrigatório';
                    if (!value.contains('@') || !value.contains('.')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                    helperText: 'Ex: https://www.clinica.com.br',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                salvarClinica(
                  id: clinica?['id'],
                  nome: nomeController.text,
                  endereco: enderecoController.text,
                  cidade: cidadeController.text,
                  estado: estadoController.text.toUpperCase(),
                  telefone: telefoneController.text,
                  email: emailController.text,
                  website: websiteController.text.isNotEmpty ? websiteController.text : null,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void showDetalhesClinica(Map<String, dynamic> clinica) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.business, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                clinica['nome'] ?? 'Clínica',
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detalheLinha('Endereço', clinica['endereco']),
              const Divider(),
              _detalheLinha('Cidade/UF', '${clinica['cidade'] ?? ''}/${clinica['estado'] ?? ''}'),
              const Divider(),
              _detalheLinha('Telefone', clinica['telefone']),
              const Divider(),
              _detalheLinha('Email', clinica['email']),
              if (clinica['website'] != null && clinica['website']!.isNotEmpty) ...[
                const Divider(),
                _detalheLinha('Website', clinica['website']),
              ],
              if (clinica['latitude'] != null || clinica['longitude'] != null) ...[
                const Divider(),
                _detalheLinha('Coordenadas', 
                  'Lat: ${clinica['latitude'] ?? 'N/A'}, Lng: ${clinica['longitude'] ?? 'N/A'}'),
              ],
              const Divider(),
              _detalheLinha('Cadastrado em', _formatarData(clinica['criado_em'])),
              if (clinica['atualizado_em'] != null) ...[
                const Divider(),
                _detalheLinha('Atualizado em', _formatarData(clinica['atualizado_em'])),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              showClinicaDialog(clinica: clinica);
            },
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
            child: Text(
              valor ?? 'Não informado',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(String? dataIso) {
    if (dataIso == null) return 'Não informado';
    try {
      final data = DateTime.parse(dataIso).toLocal();
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dataIso;
    }
  }

  void _navigateToPage(String page) {
    if (page == 'Dashboard') {
      Navigator.pop(context);
    }
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      backgroundColor: const Color(0xfff4f6f8),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showClinicaDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: isMobile ? 80 : 100),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Barra de busca
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar por nome, cidade ou endereço...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: busca.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() => busca = '');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() => busca = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          // Lista de clínicas
                          Expanded(
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : clinicasFiltradas.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.business,
                                              size: 64,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              busca.isEmpty
                                                  ? 'Nenhuma clínica cadastrada'
                                                  : 'Nenhuma clínica encontrada para "$busca"',
                                              style: TextStyle(color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(height: 16),
                                            if (busca.isEmpty)
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.add),
                                                label: const Text('Adicionar Clínica'),
                                                onPressed: () => showClinicaDialog(),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.teal,
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: clinicasFiltradas.length,
                                        itemBuilder: (context, index) {
                                          final clinica = clinicasFiltradas[index];
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors.teal.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(
                                                        Icons.business,
                                                        color: Colors.teal,
                                                        size: 28,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      clinica['nome'] ?? 'Sem nome',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.location_on,
                                                                size: 14, color: Colors.grey),
                                                            const SizedBox(width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                '${clinica['cidade'] ?? ''}, ${clinica['estado'] ?? ''}',
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.phone,
                                                                size: 14, color: Colors.grey),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              clinica['telefone'] ?? 'Sem telefone',
                                                              style: const TextStyle(fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(Icons.edit, color: Colors.teal),
                                                          onPressed: () => showClinicaDialog(clinica: clinica),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.delete, color: Colors.red),
                                                          onPressed: () => excluirClinica(
                                                            clinica['id'],
                                                            clinica['nome'] ?? 'esta clínica',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: () => showDetalhesClinica(clinica),
                                                  ),
                                                  // Informações adicionais
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey.shade100,
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                const Icon(Icons.email,
                                                                    size: 14, color: Colors.grey),
                                                                const SizedBox(width: 4),
                                                                Expanded(
                                                                  child: Text(
                                                                    clinica['email'] ?? 'Sem email',
                                                                    style: const TextStyle(fontSize: 11),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        if (clinica['website'] != null && clinica['website']!.isNotEmpty)
                                                          Expanded(
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey.shade100,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const Icon(Icons.language,
                                                                      size: 14, color: Colors.grey),
                                                                  const SizedBox(width: 4),
                                                                  Expanded(
                                                                    child: Text(
                                                                      clinica['website']!,
                                                                      style: const TextStyle(fontSize: 11),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                onTap: () {
                  if (item == 'Dashboard') {
                    Navigator.pop(context);
                  } else if (item == 'Usuários') {
                    Navigator.pop(context);
                  } else if (item == 'Profissionais') {
                    Navigator.pop(context);
                  } else if (item == 'Consultas') {
                    // Navegar para consultas
                  } else if (item == 'Clínicas') {
                    // Já está na página de clínicas
                  } else if (item == 'Mensagens') {
                    // Navegar para mensagens
                  }
                  setState(() {
                    _currentPage = item;
                  });
                },
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
                  }),
                  _buildDrawerItem('Usuários', Icons.people, () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Profissionais', Icons.medical_services, () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Consultas', Icons.calendar_today, () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Clínicas', Icons.business, () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem('Mensagens', Icons.mail, () {
                    Navigator.pop(context);
                  }),
                  const Divider(color: Colors.white54, thickness: 1),
                  _buildDrawerItem('Sair', Icons.logout, () {
                    Navigator.pop(context);
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