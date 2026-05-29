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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Consultas';
  
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
        final dataA = DateTime.tryParse(a['data_agendada'].toString()) ?? DateTime(2000);
        final dataB = DateTime.tryParse(b['data_agendada'].toString()) ?? DateTime(2000);
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
        final dataFormatada = dataSelecionada!.toIso8601String().split('T')[0];
        consultasData = consultasData.where((consulta) {
          return consulta['data_agendada'].toString().startsWith(dataFormatada);
        }).toList();
      }

      List<Map<String, dynamic>> consultasCompletas = [];

      for (var consulta in consultasData) {
        Map<String, dynamic> consultaCompleta = Map.from(consulta);

        // paciente
        if (consulta['paciente_id'] != null) {
          final paciente = await supabase
              .from('perfis')
              .select('id, nome_completo, email')
              .eq('id', consulta['paciente_id'])
              .maybeSingle();
          consultaCompleta['paciente'] = paciente;
        }

        // profissional
        if (consulta['profissional_id'] != null) {
          final profissional = await supabase
              .from('profissionais')
              .select('id, especialidade, crm, perfil_id')
              .eq('id', consulta['profissional_id'])
              .maybeSingle();

          if (profissional != null && profissional['perfil_id'] != null) {
            final perfilProfissional = await supabase
                .from('perfis')
                .select('nome_completo')
                .eq('id', profissional['perfil_id'])
                .maybeSingle();
            profissional['perfil'] = perfilProfissional;
          }
          consultaCompleta['profissional'] = profissional;
        }

        // clínica
        if (consulta['clinica_id'] != null) {
          final clinica = await supabase
              .from('clinicas')
              .select('id, nome')
              .eq('id', consulta['clinica_id'])
              .maybeSingle();
          consultaCompleta['clinica'] = clinica;
        }

        consultasCompletas.add(consultaCompleta);
      }

      setState(() {
        consultas = consultasCompletas;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar consultas: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar: $e'),
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
            content: Text('Consulta atualizada para ${getStatusText(novoStatus)}'),
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
      Navigator.pushNamed(context, '/admin-profissionais');
    } 
    else if (page == 'Consultas') {
      // já está na página
    } 
    else if (page == 'Clínicas') {
      Navigator.pushNamed(context, '/admin-clinicas');
    } 
    else if (page == 'Mensagens') {
      Navigator.pushNamed(context, '/admin-mensagens');
    }
  }

  String _formatarData(String? dataIso) {
    if (dataIso == null) return 'Não informado';
    try {
      final data = DateTime.parse(dataIso);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    } catch (e) {
      return dataIso;
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
                          const SizedBox(height: 16),
                          // Lista de consultas
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
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: getStatusColor(status),
                                                    child: const Icon(Icons.calendar_month, color: Colors.white),
                                                  ),
                                                  title: Text(
                                                    paciente?['nome_completo'] ?? 'Paciente não informado',
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        profissionalPerfil?['nome_completo'] ?? 'Médico não informado',
                                                        style: const TextStyle(fontSize: 13),
                                                      ),
                                                      Text(
                                                        '${_formatarData(consulta['data_agendada'])} - ${consulta['horario_agendado'] ?? 'Horário não definido'}',
                                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                                                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                                  onTap: () {
                                                    _showDetalhesConsulta(consulta);
                                                  },
                                                ),
                                                // Botões de ação rápidos
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                                  child: Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      if (status == 'pendente')
                                                        _buildStatusButton(
                                                          label: 'Agendar',
                                                          icon: Icons.check_circle,
                                                          color: Colors.blue,
                                                          onPressed: () => atualizarStatusConsulta(consulta['id'], 'agendada'),
                                                        ),
                                                      if (status == 'agendada')
                                                        _buildStatusButton(
                                                          label: 'Confirmar',
                                                          icon: Icons.check,
                                                          color: Colors.green,
                                                          onPressed: () => atualizarStatusConsulta(consulta['id'], 'confirmada'),
                                                        ),
                                                      if (status == 'confirmada')
                                                        _buildStatusButton(
                                                          label: 'Concluir',
                                                          icon: Icons.done_all,
                                                          color: Colors.green,
                                                          onPressed: () => atualizarStatusConsulta(consulta['id'], 'concluida'),
                                                        ),
                                                      if (status != 'concluida' && status != 'cancelada')
                                                        _buildStatusButton(
                                                          label: 'Cancelar',
                                                          icon: Icons.cancel,
                                                          color: Colors.red,
                                                          onPressed: () => atualizarStatusConsulta(consulta['id'], 'cancelada'),
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

  Widget _buildStatusButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 100,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 36),
        ),
        onPressed: onPressed,
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

  void _showDetalhesConsulta(Map<String, dynamic> consulta) {
    final paciente = consulta['paciente'] as Map<String, dynamic>?;
    final profissional = consulta['profissional'] as Map<String, dynamic>?;
    final profissionalPerfil = profissional?['perfil'] as Map<String, dynamic>?;
    final clinica = consulta['clinica'] as Map<String, dynamic>?;
    final status = consulta['status'] ?? 'pendente';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: getStatusColor(status),
              child: const Icon(Icons.calendar_month, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Consulta - ${getStatusText(status)}',
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
              _infoLinha('Paciente', paciente?['nome_completo']),
              const Divider(),
              _infoLinha('Email Paciente', paciente?['email']),
              const Divider(),
              _infoLinha('Médico', profissionalPerfil?['nome_completo']),
              const Divider(),
              _infoLinha('Especialidade', profissional?['especialidade']),
              const Divider(),
              _infoLinha('CRM', profissional?['crm']),
              const Divider(),
              _infoLinha('Clínica', clinica?['nome']),
              const Divider(),
              _infoLinha('Data', _formatarData(consulta['data_agendada'])),
              const Divider(),
              _infoLinha('Horário', consulta['horario_agendado'] ?? 'Não informado'),
              const Divider(),
              _infoLinha('Modo', consulta['modo'] ?? 'Não informado'),
              const Divider(),
              _infoLinha('Preço', consulta['preco'] != null ? 'R\$ ${consulta['preco']}' : 'Não informado'),
              const Divider(),
              _infoLinha('Status Pagamento', consulta['status_pagamento'] ?? 'Não informado'),
              if (consulta['link_teleconsulta'] != null && consulta['link_teleconsulta'].toString().isNotEmpty) ...[
                const Divider(),
                _infoLinha('Link Teleconsulta', consulta['link_teleconsulta']),
              ],
              if (consulta['observacoes'] != null && consulta['observacoes'].toString().isNotEmpty) ...[
                const Divider(),
                _infoLinha('Observações', consulta['observacoes']),
              ],
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