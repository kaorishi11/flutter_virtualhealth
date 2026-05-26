// lib/adm/admin_mensagens.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMensagensPage extends StatefulWidget {
  const AdminMensagensPage({super.key});

  @override
  State<AdminMensagensPage> createState() => _AdminMensagensPageState();
}

class _AdminMensagensPageState extends State<AdminMensagensPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> mensagens = [];
  bool isLoading = true;
  String filtroStatus = 'todos';

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
      perfis!mensagens_usuario_id_fkey (
        id,
        nome_completo,
        email
      )
    ''');

    List<Map<String, dynamic>> mensagensData =
        List<Map<String, dynamic>>.from(response);

    // ordenar manualmente
    mensagensData.sort((a, b) {
      final dataA =
          DateTime.tryParse(a['criado_em'].toString()) ??
              DateTime(2000);

      final dataB =
          DateTime.tryParse(b['criado_em'].toString()) ??
              DateTime(2000);

      return dataB.compareTo(dataA);
    });

    // filtro status
    if (filtroStatus != 'todos') {
      mensagensData = mensagensData.where((msg) {
        return msg['status'] == filtroStatus;
      }).toList();
    }

    setState(() {
      mensagens = mensagensData;
      isLoading = false;
    });
  } catch (e) {
    debugPrint(
      'Erro ao carregar mensagens: $e',
    );

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar mensagens: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
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
            content: Text('Mensagem marcada como $novoStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> excluirMensagem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta mensagem?'),
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
        await supabase.from('mensagens').delete().eq('id', id);
        await carregarMensagens();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mensagem excluída'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'visto':
        return Colors.green;
      case 'excluida':
        return Colors.red;
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
      case 'excluida':
        return 'Excluída';
      default:
        return status;
    }
  }

  String formatarData(String? dataIso) {
    if (dataIso == null) return 'Data não informada';
    try {
      final data = DateTime.parse(dataIso).toLocal();
      return '${data.day}/${data.month}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dataIso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Mensagens de Contato'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarMensagens,
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
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : mensagens.isEmpty
                    ? const Center(child: Text('Nenhuma mensagem encontrada'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: mensagens.length,
                        itemBuilder: (context, index) {
                          final msg = mensagens[index];
                          final perfil = msg['perfis'] as Map<String, dynamic>?;
                          final status = msg['status'] ?? 'pendente';
                          final isPendente = status == 'pendente';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: isPendente
                                    ? Border.all(color: Colors.orange, width: 1)
                                    : null,
                              ),
                              child: ExpansionTile(
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
                                        msg['nome_remetente'] ?? perfil?['nome_completo'] ?? 'Anônimo',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isPendente)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'NOVA',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                  msg['email_remetente'] ?? perfil?['email'] ?? 'Sem email',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
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
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _infoLinha('Enviado em', formatarData(msg['criado_em'])),
                                        if (perfil != null) ...[
                                          const SizedBox(height: 8),
                                          _infoLinha('Usuário vinculado', perfil['nome_completo']),
                                          const SizedBox(height: 4),
                                          _infoLinha('Email do usuário', perfil['email']),
                                        ],
                                        const SizedBox(height: 16),
                                        if (status == 'pendente')
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(Icons.done_all),
                                              label: const Text('Marcar como visto'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () => atualizarStatus(msg['id'], 'visto'),
                                            ),
                                          ),
                                        if (status == 'visto')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  icon: const Icon(Icons.archive),
                                                  label: const Text('Arquivar'),
                                                  onPressed: () => atualizarStatus(msg['id'], 'excluida'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  icon: const Icon(Icons.delete),
                                                  label: const Text('Excluir'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  onPressed: () => excluirMensagem(msg['id']),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (status == 'excluida')
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.delete, color: Colors.red, size: 16),
                                                SizedBox(width: 8),
                                                Text('Esta mensagem foi arquivada', style: TextStyle(color: Colors.red)),
                                              ],
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
    );
  }

  Widget _infoLinha(String titulo, String valor) {
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
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}