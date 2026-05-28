// lib/adm/admin_consultas.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminConsultasPage extends StatefulWidget {
  const AdminConsultasPage({super.key});

  @override
  State<AdminConsultasPage> createState() => _AdminConsultasPageState();
}

class _AdminConsultasPageState extends State<AdminConsultasPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> consultas = [];
  bool isLoading = true;
  String filtroStatus = 'todos';
  DateTime? dataSelecionada;

  @override
  void initState() {
    super.initState();
    carregarConsultas();
  }

  Future<void> carregarConsultas() async {
  setState(() => isLoading = true);

  try {
    final response = await supabase
        .from('consultas')
        .select('*');

    List<Map<String, dynamic>> consultasData =
        List<Map<String, dynamic>>.from(response);

    // ordenar manualmente
    consultasData.sort((a, b) {
      final dataA =
          DateTime.tryParse(a['data_agendada'].toString()) ??
              DateTime(2000);

      final dataB =
          DateTime.tryParse(b['data_agendada'].toString()) ??
              DateTime(2000);

      return dataB.compareTo(dataA);
    });

    // filtro status
    if (filtroStatus != 'todos') {
      consultasData = consultasData.where((consulta) {
        return consulta['status'] == filtroStatus;
      }).toList();
    }

    // filtro data
    if (dataSelecionada != null) {
      final dataFormatada =
          dataSelecionada!
              .toIso8601String()
              .split('T')[0];

      consultasData = consultasData.where((consulta) {
        return consulta['data_agendada']
            .toString()
            .startsWith(dataFormatada);
      }).toList();
    }

    List<Map<String, dynamic>> consultasCompletas = [];

    for (var consulta in consultasData) {
      Map<String, dynamic> consultaCompleta =
          Map.from(consulta);

      // paciente
      if (consulta['paciente_id'] != null) {
        final paciente = await supabase
            .from('perfis')
            .select(
                'id, nome_completo, email')
            .eq(
                'id',
                consulta['paciente_id'])
            .maybeSingle();

        consultaCompleta['paciente'] =
            paciente;
      }

      // profissional
      if (consulta['profissional_id'] !=
          null) {
        final profissional =
            await supabase
                .from('profissionais')
                .select(
                    'id, especialidade, crm, perfil_id')
                .eq(
                    'id',
                    consulta[
                        'profissional_id'])
                .maybeSingle();

        if (profissional != null &&
            profissional['perfil_id'] !=
                null) {
          final perfilProfissional =
              await supabase
                  .from('perfis')
                  .select(
                      'nome_completo')
                  .eq(
                      'id',
                      profissional[
                          'perfil_id'])
                  .maybeSingle();

          profissional['perfil'] =
              perfilProfissional;
        }

        consultaCompleta['profissional'] =
            profissional;
      }

      // clínica
      if (consulta['clinica_id'] != null) {
        final clinica =
            await supabase
                .from('clinicas')
                .select('id, nome')
                .eq(
                    'id',
                    consulta[
                        'clinica_id'])
                .maybeSingle();

        consultaCompleta['clinica'] =
            clinica;
      }

      consultasCompletas
          .add(consultaCompleta);
    }

    setState(() {
      consultas = consultasCompletas;
      isLoading = false;
    });
  } catch (e) {
    debugPrint(
        'Erro ao carregar consultas: $e');

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
              'Erro ao carregar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> atualizarStatusConsulta(String id, String novoStatus) async {
    try {
      await supabase
          .from('consultas')
          .update({
            'status': novoStatus,
            'atualizado_em': DateTime.now().toIso8601String()
          })
          .eq('id', id);
      await carregarConsultas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consulta atualizada para $novoStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'agendada':
        return Colors.blue;
      case 'confirmada':
        return Colors.teal;
      case 'concluida':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'agendada':
        return 'Agendada';
      case 'confirmada':
        return 'Confirmada';
      case 'concluida':
        return 'Concluída';
      case 'cancelada':
        return 'Cancelada';
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
        title: const Text('Gerenciar Consultas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarConsultas,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Filtros de status
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: filtroStatus == 'todos',
                        onSelected: (_) {
                          setState(() => filtroStatus = 'todos');
                          carregarConsultas();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Pendentes'),
                        selected: filtroStatus == 'pendente',
                        onSelected: (_) {
                          setState(() => filtroStatus = 'pendente');
                          carregarConsultas();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Agendadas'),
                        selected: filtroStatus == 'agendada',
                        onSelected: (_) {
                          setState(() => filtroStatus = 'agendada');
                          carregarConsultas();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Confirmadas'),
                        selected: filtroStatus == 'confirmada',
                        onSelected: (_) {
                          setState(() => filtroStatus = 'confirmada');
                          carregarConsultas();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Concluídas'),
                        selected: filtroStatus == 'concluida',
                        onSelected: (_) {
                          setState(() => filtroStatus = 'concluida');
                          carregarConsultas();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Canceladas'),
                        selected: filtroStatus == 'cancelada',
                        onSelected: (_) {
                          setState(() => filtroStatus = 'cancelada');
                          carregarConsultas();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Filtro por data
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          dataSelecionada == null
                              ? 'Filtrar por data'
                              : 'Data: ${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          setState(() {
                            dataSelecionada = date;
                          });
                          carregarConsultas();
                        },
                      ),
                    ),
                    if (dataSelecionada != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            dataSelecionada = null;
                          });
                          carregarConsultas();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : consultas.isEmpty
                    ? const Center(child: Text('Nenhuma consulta encontrada'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: consultas.length,
                        itemBuilder: (context, index) {
                          final consulta = consultas[index];
                          final paciente = consulta['paciente'] as Map<String, dynamic>?;
                          final profissional = consulta['profissional'] as Map<String, dynamic>?;
                          final profissionalPerfil = profissional?['perfil'] as Map<String, dynamic>?;
                          final clinica = consulta['clinica'] as Map<String, dynamic>?;
                          final status = consulta['status'] ?? 'pendente';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: getStatusColor(status),
                                child: const Icon(Icons.calendar_month,
                                    color: Colors.white),
                              ),
                              title: Text(
                                paciente?['nome_completo'] ?? 'Paciente não informado',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profissionalPerfil?['nome_completo'] ??
                                        'Médico não informado',
                                  ),
                                  const SizedBox(height: 4),
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
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _infoLinha('Data',
                                          consulta['data_agendada']),
                                      const SizedBox(height: 8),
                                      _infoLinha('Horário',
                                          consulta['horario_agendado']),
                                      const SizedBox(height: 8),
                                      _infoLinha('Modo', consulta['modo']),
                                      const SizedBox(height: 8),
                                      _infoLinha('Clínica', clinica?['nome']),
                                      const SizedBox(height: 8),
                                      _infoLinha(
                                          'Preço',
                                          consulta['preco'] != null
                                              ? 'R\$ ${consulta['preco']}'
                                              : 'Não informado'),
                                      const SizedBox(height: 8),
                                      if (consulta['observacoes'] != null && consulta['observacoes'].toString().isNotEmpty)
                                        _infoLinha('Observações',
                                            consulta['observacoes']),
                                      if (consulta['link_teleconsulta'] != null && consulta['link_teleconsulta'].toString().isNotEmpty)
                                        _infoLinha('Link Teleconsulta',
                                            consulta['link_teleconsulta']),
                                      const SizedBox(height: 16),
                                      if (status == 'pendente')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.check_circle),
                                                label: const Text('Agendar'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => atualizarStatusConsulta(
                                                    consulta['id'], 'agendada'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.cancel),
                                                label: const Text('Cancelar'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => atualizarStatusConsulta(
                                                    consulta['id'], 'cancelada'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (status == 'agendada')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.check),
                                                label: const Text('Confirmar'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => atualizarStatusConsulta(
                                                    consulta['id'], 'confirmada'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                icon: const Icon(Icons.cancel),
                                                label: const Text('Cancelar'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                onPressed: () => atualizarStatusConsulta(
                                                    consulta['id'], 'cancelada'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (status == 'confirmada')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.done_all),
                                                label: const Text('Concluir'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () => atualizarStatusConsulta(
                                                    consulta['id'], 'concluida'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                icon: const Icon(Icons.cancel),
                                                label: const Text('Cancelar'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                onPressed: () => atualizarStatusConsulta(
                                                    consulta['id'], 'cancelada'),
                                              ),
                                            ),
                                          ],
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
          width: 100,
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