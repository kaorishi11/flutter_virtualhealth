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
        criado_em
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Gerenciar Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarUsuarios,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
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
              ],
            ),
          ),
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
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    getFuncaoColor(user['funcao']),
                                child: Text(
                                  user['nome_completo']?[0]?.toUpperCase() ??
                                      '?',
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
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          user['funcao'] ?? 'paciente',
                                          style: TextStyle(
                                            color:
                                                getFuncaoColor(user['funcao']),
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
                                            color: Colors.red.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                              trailing: Switch(
                                value: user['ativo'] ?? true,
                                onChanged: (_) => alternarStatusUsuario(
                                  user['id'],
                                  user['ativo'] ?? true,
                                ),
                              ),
                              onTap: () {
                                _showDetalhesUsuario(user);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
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
}