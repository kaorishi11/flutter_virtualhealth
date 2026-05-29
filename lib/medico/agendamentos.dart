import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dicas.dart';
import 'perfil.dart';
import 'teleconsulta.dart';

class MinhaAgendaPage extends StatefulWidget {
  const MinhaAgendaPage({super.key});

  @override
  State<MinhaAgendaPage> createState() => _MinhaAgendaPageState();
}

class _MinhaAgendaPageState extends State<MinhaAgendaPage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Minha Agenda';
  
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
    _carregarDadosMedico();
  }
  
  Future<void> _carregarDadosMedico() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();
      
      final profissional = await supabase
          .from('profissionais')
          .select()
          .eq('perfil_id', perfil['id'])
          .single();
      
      setState(() {
        _nomeMedico = perfil['nome_completo'] ?? 'Médico';
        _especialidade = profissional['especialidade'] ?? 'Médico';
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados do médico: $e');
    }
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
      
      // Buscar profissional
      final profissional = await supabase
          .from('profissionais')
          .select()
          .eq('perfil_id', perfil['id'])
          .single();
      
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
          duracao: 30,
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
      setState(() {
        _agendamentos = [];
        _aplicarFiltros();
        _isLoading = false;
      });
    }
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
  
  void _onPageChanged(String page) {
    if (page == 'Dashboard') {
      Navigator.pop(context);
    } else if (page == 'Minha Agenda') {
      // Já está na página atual
    } else if (page == 'Teleconsulta') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma consulta para iniciar a teleconsulta'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (page == 'Dicas de Saúde') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DicasSaudePage()),
      );
    } else if (page == 'Meu Perfil') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerfilMedicoPage()),
      );
    } else if (page == 'Sair') {
      _confirmLogout();
    }
  }
  
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
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
  
  void _iniciarConsulta(Agendamento agendamento) {
    if (agendamento.tipo.toLowerCase() == 'online') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TeleconsultaPage(
            consultaId: agendamento.id,
            pacienteNome: agendamento.pacienteNome,
            pacienteId: agendamento.pacienteId,
          ),
        ),
      );
    } else {
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
  
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer() : null,
      backgroundColor: const Color(0xfff5f7fa),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          return Stack(
            children: [
              Column(
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
    final navItems = ['Dashboard', 'Minha Agenda', 'Teleconsulta', 'Dicas de Saúde', 'Meu Perfil'];

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
              icon: const Icon(Icons.menu, size: 28, color: Color(0xFF3FA9C6)),
            ),
            Image.asset(
              'assets/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.medical_services, size: 50, color: Color(0xFF3FA9C6));
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
          Image.asset(
            'assets/logo.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.medical_services, size: 60, color: Color(0xFF3FA9C6));
            },
          ),
          Row(
            children: navItems.map((item) {
              final isActive = _currentPage == item;
              return GestureDetector(
                onTap: () => _onPageChanged(item),
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
                          color: isActive ? primaryColor : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isActive ? 24 : 0,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _confirmLogout(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawer() {
    final navItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard},
      {'title': 'Minha Agenda', 'icon': Icons.calendar_today},
      {'title': 'Teleconsulta', 'icon': Icons.video_call},
      {'title': 'Dicas de Saúde', 'icon': Icons.health_and_safety},
      {'title': 'Meu Perfil', 'icon': Icons.person},
    ];

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.medical_services, size: 80, color: Colors.white);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nomeMedico,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _especialidade,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1),
            Expanded(
              child: ListView(
                children: [
                  ...navItems.map((item) => _buildDrawerItem(
                    item['title'] as String,
                    item['icon'] as IconData,
                    () {
                      Navigator.pop(context);
                      _onPageChanged(item['title'] as String);
                    },
                  )),
                  const Divider(color: Colors.white54, thickness: 1),
                  _buildDrawerItem('Sair', Icons.logout, () {
                    Navigator.pop(context);
                    _onPageChanged('Sair');
                  }, isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 18,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      splashColor: Colors.white.withOpacity(0.2),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width < 800 ? 100 : 160),
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
}

class Agendamento {
  final String id;
  final String pacienteNome;
  final String pacienteId;
  final TimeOfDay horario;
  final int duracao;
  final String tipo;
  final String status;
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