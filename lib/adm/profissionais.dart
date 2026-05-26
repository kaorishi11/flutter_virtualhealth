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
  List<Map<String, dynamic>> profissionais = [];
  bool isLoading = true;
  String filtroStatus = 'todos';

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
          telefone
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
            content: Text('Status atualizado para $novoStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Color getStatusColor(String status) {
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

  String getStatusText(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Profissionais de Saúde'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarProfissionais,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
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
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : profissionais.isEmpty
                    ? const Center(child: Text('Nenhum profissional encontrado'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: profissionais.length,
                        itemBuilder: (context, index) {
                          final prof = profissionais[index];
                          final perfil = prof['perfis'] as Map<String, dynamic>?;
                          final clinica = prof['clinicas'] as Map<String, dynamic>?;
                          final status = prof['status'] ?? 'pendente';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: getStatusColor(status),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(status).withOpacity(0.2),
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
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _infoLinha('Email', perfil?['email']),
                                      const SizedBox(height: 8),
                                      _infoLinha('Telefone', perfil?['telefone']),
                                      const SizedBox(height: 8),
                                      _infoLinha('CRM', prof['crm']),
                                      const SizedBox(height: 8),
                                      _infoLinha('Universidade', prof['universidade']),
                                      const SizedBox(height: 8),
                                      _infoLinha('Ano de Formação', prof['ano_formacao']?.toString()),
                                      const SizedBox(height: 8),
                                      _infoLinha('Clínica', clinica?['nome']),
                                      const SizedBox(height: 8),
                                      _infoLinha('Preço', prof['preco'] != null ? 'R\$ ${prof['preco']}' : 'Não definido'),
                                      const SizedBox(height: 8),
                                      _infoLinha('Avaliação', prof['avaliacao'] != null ? '${prof['avaliacao']} ⭐' : 'Sem avaliações'),
                                      const SizedBox(height: 16),
                                      if (status == 'pendente')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.check),
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
                                                icon: const Icon(Icons.close),
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
                                      if (status == 'aceito')
                                        SizedBox(
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
                                      if (status == 'negado')
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Reconsiderar'),
                                            onPressed: () => atualizarStatus(prof['id'], 'pendente'),
                                          ),
                                        ),
                                    ],
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
    );
  }

  Widget _infoLinha(String titulo, String? valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(valor ?? 'Não informado'),
        ),
      ],
    );
  }
}