import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notificacoes = [];
  bool isLoading = true;
  String perfilId = ''; // Mudado de String? para String com valor vazio

  @override
  void initState() {
    super.initState();
    carregarPerfilId();
  }

  Future<void> carregarPerfilId() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final perfil = await supabase
          .from('perfis')
          .select('id')
          .eq('auth_id', user.id)
          .single();

      perfilId = perfil['id'].toString(); // Convertendo para String
      await carregarNotificacoes();
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> carregarNotificacoes() async {
    if (perfilId.isEmpty) { // Verifica se está vazio
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('notificacoes')
          .select()
          .eq('usuario_id', perfilId)
          .order('criado_em', ascending: false);

      setState(() {
        notificacoes = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar notificações: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> marcarComoLida(String notificacaoId) async {
    try {
      await supabase
          .from('notificacoes')
          .update({'lida': true, 'atualizado_em': DateTime.now().toIso8601String()})
          .eq('id', notificacaoId);

      setState(() {
        final index = notificacoes.indexWhere((n) => n['id'] == notificacaoId);
        if (index != -1) {
          notificacoes[index]['lida'] = true;
        }
      });
    } catch (e) {
      debugPrint('Erro ao marcar como lida: $e');
    }
  }

  Future<void> marcarTodasComoLidas() async {
    if (perfilId.isEmpty) return;

    try {
      await supabase
          .from('notificacoes')
          .update({'lida': true, 'atualizado_em': DateTime.now().toIso8601String()})
          .eq('usuario_id', perfilId)
          .eq('lida', false);

      setState(() {
        for (var notificacao in notificacoes) {
          notificacao['lida'] = true;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todas notificações marcadas como lidas')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao marcar todas como lidas: $e');
    }
  }

  Future<void> excluirNotificacao(String notificacaoId) async {
    try {
      await supabase.from('notificacoes').delete().eq('id', notificacaoId);

      setState(() {
        notificacoes.removeWhere((n) => n['id'] == notificacaoId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificação excluída')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao excluir notificação: $e');
    }
  }

  IconData getIconPorTipo(String tipo) {
    switch (tipo) {
      case 'consulta':
        return Icons.calendar_today;
      case 'teleconsulta':
        return Icons.video_call;
      case 'lembrete':
        return Icons.notifications_active;
      case 'sistema':
        return Icons.settings;
      default:
        return Icons.notifications_none;
    }
  }

  Color getCorPorTipo(String tipo) {
    switch (tipo) {
      case 'consulta':
        return Colors.blue;
      case 'teleconsulta':
        return Colors.purple;
      case 'lembrete':
        return Colors.orange;
      case 'sistema':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }

  String formatarData(String dataISO) {
    final date = DateTime.parse(dataISO).toLocal();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje às ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Ontem às ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat("EEEE 'às' HH:mm", 'pt_BR').format(date);
    } else {
      return DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: false,
        elevation: 0,
        actions: [
          if (notificacoes.any((n) => n['lida'] == false))
            TextButton.icon(
              onPressed: marcarTodasComoLidas,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Marcar todas'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3FA9C6),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma notificação',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Suas notificações aparecerão aqui',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: carregarNotificacoes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notificacoes.length,
                    itemBuilder: (context, index) {
                      final notificacao = notificacoes[index];
                      final isLida = notificacao['lida'] == true;
                      final tipo = notificacao['tipo'] ?? 'outro';
                      final titulo = notificacao['titulo'] ?? 'Sem título';
                      final mensagem = notificacao['mensagem'] ?? '';
                      final data = notificacao['criado_em'] as String;
                      final id = notificacao['id'];

                      return Dismissible(
                        key: Key(id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => excluirNotificacao(id),
                        child: GestureDetector(
                          onTap: () => marcarComoLida(id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isLida ? Colors.white : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: !isLida
                                  ? Border.all(color: const Color(0xFF3FA9C6), width: 1)
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: getCorPorTipo(tipo).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    getIconPorTipo(tipo),
                                    color: getCorPorTipo(tipo),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              titulo,
                                              style: TextStyle(
                                                fontWeight: isLida ? FontWeight.normal : FontWeight.bold,
                                                fontSize: 16,
                                                color: isLida ? Colors.grey[700] : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (!isLida)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF3FA9C6),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mensagem,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isLida ? Colors.grey[600] : Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formatarData(data),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}