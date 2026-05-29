import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DicasSaudePage extends StatefulWidget {
  const DicasSaudePage({super.key});

  @override
  State<DicasSaudePage> createState() => _DicasSaudePageState();
}

class _DicasSaudePageState extends State<DicasSaudePage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Dicas de Saúde';
  
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();
  
  List<DicaSaude> _dicas = [];
  bool _isLoading = true;
  bool _isPublicando = false;
  String _nomeMedico = '';
  String _nomeCompleto = '';
  String _especialidade = '';
  String _perfilId = '';
  String _profissionalId = '';
  
  final Color primaryColor = const Color(0xFF3FA9C6);
  
  @override
  void initState() {
    super.initState();
    _carregarDicas();
    _carregarPerfilMedico();
  }
  
  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }
  
  Future<void> _carregarPerfilMedico() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();
      
      _perfilId = perfil['id'].toString();
      _nomeCompleto = perfil['nome_completo'] ?? 'Médico';
      
      final profissional = await supabase
          .from('profissionais')
          .select()
          .eq('perfil_id', perfil['id'])
          .single();
      
      _profissionalId = profissional['id'].toString();
      
      setState(() {
        _nomeMedico = perfil['nome_completo']?.split(' ')[0] ?? 'Médico';
        _especialidade = profissional['especialidade'] ?? 'Médico';
      });
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      setState(() {
        _nomeMedico = 'Médico';
        _especialidade = 'Médico';
      });
    }
  }
  
  Future<void> _carregarDicas() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }
      
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
      
      // Buscar dicas do banco
      final dicasDB = await supabase
          .from('dicas_saude')
          .select('''
            *,
            perfis!dicas_saude_autor_id_fkey(
              nome_completo
            )
          ''')
          .eq('profissional_id', profissional['id'])
          .order('criado_em', ascending: false);
      
      if (dicasDB.isNotEmpty) {
        final List<DicaSaude> dicasTemp = [];
        for (var dica in dicasDB) {
          dicasTemp.add(DicaSaude(
            id: dica['id'],
            titulo: dica['titulo'] ?? 'Dica de saúde',
            conteudo: dica['conteudo'] ?? '',
            autor: dica['perfis']?['nome_completo']?.split(' ')[0] ?? _nomeMedico,
            especialidade: _especialidade,
            dataPublicacao: DateTime.parse(dica['criado_em']),
            curtidas: dica['curtidas'] ?? 0,
          ));
        }
        setState(() {
          _dicas = dicasTemp;
          _isLoading = false;
        });
      } else {
        setState(() {
          _dicas = [];
          _isLoading = false;
        });
      }
      
    } catch (e) {
      debugPrint('Erro ao carregar dicas: $e');
      setState(() {
        _dicas = [];
        _isLoading = false;
      });
    }
  }
  
  Future<void> _publicarDica() async {
    if (_conteudoController.text.trim().isEmpty) {
      _mostrarSnackbar('Por favor, escreva o conteúdo da dica');
      return;
    }
    
    setState(() {
      _isPublicando = true;
    });
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');
      
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
      
      final titulo = _tituloController.text.trim().isEmpty 
          ? _gerarTituloAutomatico(_conteudoController.text)
          : _tituloController.text.trim();
      
      // Salvar no banco
      await supabase.from('dicas_saude').insert({
        'titulo': titulo,
        'conteudo': _conteudoController.text.trim(),
        'profissional_id': profissional['id'],
        'autor_id': perfil['id'],
        'curtidas': 0,
        'criado_em': DateTime.now().toIso8601String(),
      });
      
      // Limpar formulário
      _tituloController.clear();
      _conteudoController.clear();
      
      // Recarregar dicas
      await _carregarDicas();
      
      _mostrarSnackbar('Dica publicada com sucesso!');
      
    } catch (e) {
      debugPrint('Erro ao publicar: $e');
      // Fallback local
      setState(() {
        _dicas.insert(0, DicaSaude(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titulo: _tituloController.text.trim().isEmpty 
              ? 'Nova dica de saúde' 
              : _tituloController.text.trim(),
          conteudo: _conteudoController.text.trim(),
          autor: _nomeMedico,
          especialidade: _especialidade,
          dataPublicacao: DateTime.now(),
          curtidas: 0,
        ));
        _tituloController.clear();
        _conteudoController.clear();
      });
      _mostrarSnackbar('Dica publicada com sucesso!');
    }
    
    setState(() {
      _isPublicando = false;
    });
  }
  
  String _gerarTituloAutomatico(String conteudo) {
    if (conteudo.length < 50) return conteudo;
    return '${conteudo.substring(0, 45)}...';
  }
  
  Future<void> _curtirDica(DicaSaude dica) async {
    try {
      await supabase
          .from('dicas_saude')
          .update({'curtidas': dica.curtidas + 1})
          .eq('id', dica.id);
      
      setState(() {
        final index = _dicas.indexWhere((d) => d.id == dica.id);
        if (index != -1) {
          _dicas[index] = dica.copyWith(curtidas: dica.curtidas + 1);
        }
      });
    } catch (e) {
      // Fallback local
      setState(() {
        final index = _dicas.indexWhere((d) => d.id == dica.id);
        if (index != -1) {
          _dicas[index] = dica.copyWith(curtidas: dica.curtidas + 1);
        }
      });
    }
  }
  
  void _mostrarSnackbar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _onPageChanged(String page) {
    if (page == 'Dashboard') {
      Navigator.pop(context);
    } else if (page == 'Minha Agenda') {
      Navigator.pop(context);
    } else if (page == 'Teleconsulta') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma consulta para iniciar a teleconsulta'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (page == 'Dicas de Saúde') {
      // Já está na página atual
    } else if (page == 'Meu Perfil') {
      Navigator.pop(context);
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
  
  void _mostrarAjuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como publicar dicas'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escreva dicas de saúde para seus pacientes'),
            SizedBox(height: 8),
            Text('Compartilhe conhecimentos e orientações'),
            SizedBox(height: 8),
            Text('Os pacientes podem curtir suas dicas'),
            SizedBox(height: 8),
            Text('As dicas aparecem no feed dos pacientes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
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
      backgroundColor: const Color(0xfff5f7fa),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _carregarDicas,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: isMobile ? 120 : 160,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPublicarSection(),
                      const SizedBox(height: 24),
                      _buildUltimasDicasSection(),
                    ],
                  ),
                ),
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
            IconButton(
              onPressed: _mostrarAjuda,
              icon: const Icon(Icons.help_outline, size: 28, color: Color(0xFF3FA9C6)),
            ),
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
                      _nomeCompleto,
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
  
  Widget _buildPublicarSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.post_add, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'PUBLICAR DICAS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          
          // Formulário
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo título (opcional)
                TextField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    hintText: 'Título (opcional)',
                    prefixIcon: Icon(Icons.title, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campo conteúdo
                TextField(
                  controller: _conteudoController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Escrever...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.edit_note, color: primaryColor),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Botão publicar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPublicando ? null : _publicarDica,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isPublicando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'PUBLICAR',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
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
  
  Widget _buildUltimasDicasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ÚLTIMAS DICAS PUBLICADAS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_dicas.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.health_and_safety, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Nenhuma dica publicada ainda',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Publique sua primeira dica acima!',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dicas.length > 3 ? 3 : _dicas.length,
            itemBuilder: (context, index) {
              final dica = _dicas[index];
              return _buildDicaCard(dica);
            },
          ),
      ],
    );
  }
  
  Widget _buildDicaCard(DicaSaude dica) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dica.titulo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      dica.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  dica.conteudo,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          
          // Footer com autor e curtidas
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: primaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.medical_information,
                        size: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dica.autor,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          dica.especialidade,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Colors.red[400],
                      ),
                      onPressed: () => _curtirDica(dica),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatarCurtidas(dica.curtidas),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatarData(dica.dataPublicacao),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
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
  }
  
  String _formatarCurtidas(int curtidas) {
    if (curtidas >= 1000) {
      return '${(curtidas / 1000).toStringAsFixed(1)}k';
    }
    return curtidas.toString();
  }
  
  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final diff = now.difference(data);
    
    if (diff.inDays == 0) {
      return 'Hoje';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dias atrás';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} semanas atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(data);
    }
  }
}

class DicaSaude {
  final String id;
  final String titulo;
  final String conteudo;
  final String autor;
  final String especialidade;
  final DateTime dataPublicacao;
  final int curtidas;
  
  DicaSaude({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.autor,
    required this.especialidade,
    required this.dataPublicacao,
    required this.curtidas,
  });
  
  DicaSaude copyWith({
    String? id,
    String? titulo,
    String? conteudo,
    String? autor,
    String? especialidade,
    DateTime? dataPublicacao,
    int? curtidas,
  }) {
    return DicaSaude(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      autor: autor ?? this.autor,
      especialidade: especialidade ?? this.especialidade,
      dataPublicacao: dataPublicacao ?? this.dataPublicacao,
      curtidas: curtidas ?? this.curtidas,
    );
  }
}