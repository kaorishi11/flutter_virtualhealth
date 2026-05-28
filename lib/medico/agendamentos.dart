import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class MinhaAgendaPage extends StatefulWidget {
  const MinhaAgendaPage({super.key});

  @override
  State<MinhaAgendaPage> createState() => _MinhaAgendaPageState();
}

class _MinhaAgendaPageState extends State<MinhaAgendaPage> {
  final supabase = Supabase.instance.client;
  
  DateTime _dataSelecionada = DateTime.now();
  String _filtroTipo = 'Todos'; // Todos, Online, Presencial
  String _filtroStatus = 'Todos'; // Todos, Confirmado, Pendente, Concluído
  
  List<Agendamento> _agendamentos = [];
  List<Agendamento> _agendamentosFiltrados = [];
  
  bool _isLoading = true;
  String _nomeMedico = '';
  String _especialidade = '';
  
  // Cores do tema
  final Color primaryColor = const Color(0xFF3FA9C6);
  
  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }
  
  Future<void> _carregarAgendamentos() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      // Buscar perfil do médico
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();
      
      _nomeMedico = perfil['nome_completo'] ?? 'Médico';
      
      // Buscar profissional
      final profissional = await supabase
          .from('profissionais')
          .select()
          .eq('perfil_id', perfil['id'])
          .single();
      
      _especialidade = profissional['especialidade'] ?? 'Médico';
      final profissionalId = profissional['id'];
      
      // Formatar data para busca
      final dataStr = DateFormat('yyyy-MM-dd').format(_dataSelecionada);
      
      // Buscar agendamentos do dia
      final consultas = await supabase
          .from('consultas')
          .select('''
            id,
            status,
            data_agendada,
            horario_agendado,
            modo,
            observacoes,
            preco,
            perfis!consultas_paciente_id_fkey(
              id,
              nome_completo,
              telefone,
              email
            )
          ''')
          .eq('profissional_id', profissionalId)
          .eq('data_agendada', dataStr)
          .order('horario_agendado', ascending: true);
      
      // Converter para lista de Agendamento
      final List<Agendamento> agendamentosTemp = [];
      for (var consulta in consultas) {
        final paciente = consulta['perfis'];
        agendamentosTemp.add(Agendamento(
          id: consulta['id'],
          pacienteNome: paciente['nome_completo'] ?? 'Paciente',
          pacienteId: paciente['id'],
          horario: _parseHorario(consulta['horario_agendado'] ?? '08:00'),
          duracao: 30, // minutos
          tipo: consulta['modo'] ?? 'presencial',
          status: consulta['status'] ?? 'pendente',
          descricao: consulta['observacoes'] ?? 'Consulta',
          isPrimeiraConsulta: consulta['observacoes']?.contains('primeira') ?? false,
        ));
      }
      
      
      setState(() {
        _agendamentos = agendamentosTemp;
        _aplicarFiltros();
        _isLoading = false;
      });
      
    } catch (e) {
      debugPrint('Erro ao carregar agendamentos: $e');
      // Usar dados mock em caso de erro
      setState(() {
        _agendamentos = [];
        _aplicarFiltros();
        _isLoading = false;
      });
    }
  }
  
  List<Agendamento> _getMockAgendamentos() {
    return [
      Agendamento(
        id: '1',
        pacienteNome: 'Maria Helena',
        horario: TimeOfDay(hour: 8, minute: 0),
        duracao: 30,
        tipo: 'online',
        status: 'confirmada',
        descricao: 'Revisão de lentes',
        isPrimeiraConsulta: true,
      ),
      Agendamento(
        id: '2',
        pacienteNome: 'Gabriel Jorge',
        horario: TimeOfDay(hour: 10, minute: 20),
        duracao: 30,
        tipo: 'presencial',
        status: 'confirmada',
        descricao: 'Check-up visual',
        isPrimeiraConsulta: false,
      ),
      Agendamento(
        id: '3',
        pacienteNome: 'Ana Carolina',
        horario: TimeOfDay(hour: 11, minute: 40),
        duracao: 30,
        tipo: 'online',
        status: 'pendente',
        descricao: 'Acompanhamento',
        isPrimeiraConsulta: false,
      ),
      Agendamento(
        id: '4',
        pacienteNome: 'Roberto Silva',
        horario: TimeOfDay(hour: 14, minute: 0),
        duracao: 30,
        tipo: 'presencial',
        status: 'confirmada',
        descricao: 'Retorno',
        isPrimeiraConsulta: false,
      ),
      Agendamento(
        id: '5',
        pacienteNome: 'Fernanda Lima',
        horario: TimeOfDay(hour: 15, minute: 30),
        duracao: 30,
        tipo: 'online',
        status: 'concluida',
        descricao: 'Resultado de exames',
        isPrimeiraConsulta: false,
      ),
    ];
  }
  
  TimeOfDay _parseHorario(String horarioStr) {
    final partes = horarioStr.split(':');
    if (partes.length >= 2) {
      return TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
    }
    return TimeOfDay(hour: 8, minute: 0);
  }
  
  void _aplicarFiltros() {
    setState(() {
      _agendamentosFiltrados = _agendamentos.where((agendamento) {
        // Filtro por tipo
        if (_filtroTipo != 'Todos') {
          final tipoMatch = _filtroTipo.toLowerCase() == agendamento.tipo.toLowerCase();
          if (!tipoMatch) return false;
        }
        
        // Filtro por status
        if (_filtroStatus != 'Todos') {
          final statusMatch = _filtroStatus.toLowerCase() == agendamento.status.toLowerCase();
          if (!statusMatch) return false;
        }
        
        return true;
      }).toList();
      
      // Ordenar por horário
      _agendamentosFiltrados.sort((a, b) {
        return a.horario.hour.compareTo(b.horario.hour);
      });
    });
  }
  
  void _mudarData(int days) {
    setState(() {
      _dataSelecionada = _dataSelecionada.add(Duration(days: days));
      _carregarAgendamentos();
    });
  }
  
  String _formatarData() {
    return DateFormat("EEEE, d 'de' MMMM", 'pt_BR')
        .format(_dataSelecionada)
        .toUpperCase();
  }
  
  String _formatarHorario(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'concluida':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return 'Confirmado';
      case 'pendente':
        return 'Pendente';
      case 'concluida':
        return 'Concluído';
      case 'cancelada':
        return 'Cancelado';
      default:
        return status;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildAgendaList(),
          ),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'MINHA AGENDA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () => _showFilterDialog(),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Data e navegação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 32),
                onPressed: () => _mudarData(-1),
                color: primaryColor,
              ),
              Column(
                children: [
                  Text(
                    _formatarData(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy', 'pt_BR').format(_dataSelecionada),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 32),
                onPressed: () => _mudarData(1),
                color: primaryColor,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Resumo do dia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${_agendamentosFiltrados.length} consultas agendadas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filtro de tipo
            _buildFilterChip('Todos', _filtroTipo == 'Todos', () {
              setState(() {
                _filtroTipo = 'Todos';
                _aplicarFiltros();
              });
            }),
            _buildFilterChip('Online', _filtroTipo == 'online', () {
              setState(() {
                _filtroTipo = 'online';
                _aplicarFiltros();
              });
            }),
            _buildFilterChip('Presencial', _filtroTipo == 'presencial', () {
              setState(() {
                _filtroTipo = 'presencial';
                _aplicarFiltros();
              });
            }),
            
            const SizedBox(width: 16),
            
            // Separador
            Container(width: 1, height: 30, color: Colors.grey[300]),
            
            const SizedBox(width: 16),
            
            // Filtro de status
            _buildFilterChip('Todos Status', _filtroStatus == 'Todos', () {
              setState(() {
                _filtroStatus = 'Todos';
                _aplicarFiltros();
              });
            }),
            _buildFilterChip('Confirmado', _filtroStatus == 'confirmada', () {
              setState(() {
                _filtroStatus = 'confirmada';
                _aplicarFiltros();
              });
            }),
            _buildFilterChip('Pendente', _filtroStatus == 'pendente', () {
              setState(() {
                _filtroStatus = 'pendente';
                _aplicarFiltros();
              });
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[100],
        selectedColor: primaryColor.withOpacity(0.2),
        checkmarkColor: primaryColor,
        labelStyle: TextStyle(
          color: selected ? primaryColor : Colors.grey[700],
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
      ),
    );
  }
  
  Widget _buildAgendaList() {
    if (_agendamentosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma consulta encontrada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente mudar os filtros ou a data',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _agendamentosFiltrados.length,
      itemBuilder: (context, index) {
        final agendamento = _agendamentosFiltrados[index];
        return _buildAgendaCard(agendamento);
      },
    );
  }
  
  Widget _buildAgendaCard(Agendamento agendamento) {
    final isOnline = agendamento.tipo.toLowerCase() == 'online';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Horário e status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      _formatarHorario(agendamento.horario),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${agendamento.duracao} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(agendamento.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(agendamento.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(agendamento.status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getIniciais(agendamento.pacienteNome),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agendamento.pacienteNome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agendamento.descricao,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (agendamento.isPrimeiraConsulta)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '1ª consulta',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (agendamento.isPrimeiraConsulta) const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOnline 
                                  ? Colors.purple.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOnline ? Icons.videocam : Icons.location_on,
                                  size: 10,
                                  color: isOnline ? Colors.purple : Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOnline ? 'Online' : 'Presencial',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isOnline ? Colors.purple : Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Botão de ação
                if (agendamento.status.toLowerCase() == 'confirmada')
                  ElevatedButton(
                    onPressed: () {
                      _iniciarConsulta(agendamento);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isOnline ? 'Entrar' : 'Iniciar',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar consultas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tipo de consulta',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Todos', 'Online', 'Presencial'].map((tipo) {
                      return FilterChip(
                        label: Text(tipo),
                        selected: _filtroTipo == (tipo == 'Todos' ? 'Todos' : tipo.toLowerCase()),
                        onSelected: (_) {
                          setState(() {
                            _filtroTipo = tipo == 'Todos' ? 'Todos' : tipo.toLowerCase();
                            _aplicarFiltros();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Todos', 'Confirmado', 'Pendente', 'Concluído'].map((status) {
                      String statusValue = status == 'Todos' 
                          ? 'Todos' 
                          : status.toLowerCase();
                      return FilterChip(
                        label: Text(status),
                        selected: _filtroStatus == statusValue,
                        onSelected: (_) {
                          setState(() {
                            _filtroStatus = statusValue;
                            _aplicarFiltros();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _filtroTipo = 'Todos';
                          _filtroStatus = 'Todos';
                          _aplicarFiltros();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Limpar filtros'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _iniciarConsulta(Agendamento agendamento) {
    if (agendamento.tipo.toLowerCase() == 'online') {
      // Navegar para tela de teleconsulta
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Iniciar Teleconsulta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam, size: 48, color: Color(0xFF3FA9C6)),
              const SizedBox(height: 16),
              Text('Conectando com ${agendamento.pacienteNome}...'),
            ],
          ),
        ),
      );
    } else {
      // Consulta presencial
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Iniciar Consulta'),
          content: Text('Iniciar consulta presencial com ${agendamento.pacienteNome}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navegar para tela de consulta
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Iniciar'),
            ),
          ],
        ),
      );
    }
  }
  
  String _getIniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.isEmpty) return 'P';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }
}

class Agendamento {
  final String id;
  final String pacienteNome;
  final String pacienteId;
  final TimeOfDay horario;
  final int duracao;
  final String tipo; // online, presencial
  final String status; // confirmada, pendente, concluida, cancelada
  final String descricao;
  final bool isPrimeiraConsulta;
  
  Agendamento({
    required this.id,
    required this.pacienteNome,
    this.pacienteId = '',
    required this.horario,
    this.duracao = 30,
    required this.tipo,
    required this.status,
    required this.descricao,
    this.isPrimeiraConsulta = false,
  });
}