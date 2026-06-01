import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:virtualhealth/medico/medico_bottom_nav_bar.dart';

class DicasSaudePage extends StatefulWidget {
  const DicasSaudePage({super.key});

  @override
  State<DicasSaudePage> createState() => _DicasSaudePageState();
}

class _DicasSaudePageState extends State<DicasSaudePage> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  // ==================== PALETA DE CORES VIRTUAL HEALTH ====================
  static const Color primaryTeal = Color(0xFF14B8A6);      // Primary
  static const Color deepOcean = Color(0xFF0D2C33);        // Deep Ocean
  static const Color actionTeal = Color(0xFF0F766E);       // Action Teal
  static const Color backgroundWhite = Color(0xFFF8FAFC);  // Background
  static const Color cardWhite = Color(0xFFFFFFFF);        // Card / Surface
  static const Color secondaryTealSoft = Color(0xFFEDF7F6); // Secondary
  static const Color mutedText = Color(0xFF6B7280);        // Muted (cinza-esverdeado)
  static const Color borderLight = Color(0x3314B8A6);      // Teal claro 20% opacidade
  static const Color likeRed = Color(0xFFEF4444);          // Cor para curtidas
  static const Color statusSuccess = Color(0xFF10B981);    // Verde para sucesso
  // ========================================================================

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

      await supabase.from('dicas_saude').insert({
        'titulo': titulo,
        'conteudo': _conteudoController.text.trim(),
        'profissional_id': profissional['id'],
        'autor_id': perfil['id'],
        'curtidas': 0,
        'criado_em': DateTime.now().toIso8601String(),
      });

      _tituloController.clear();
      _conteudoController.clear();

      await _carregarDicas();

      _mostrarSnackbar('Dica publicada com sucesso!');
    } catch (e) {
      debugPrint('Erro ao publicar: $e');
      _mostrarSnackbar('Erro ao publicar dica. Tente novamente.');
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
          .update({'curtidas': dica.curtidas + 1}).eq('id', dica.id);

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
        content: Text(mensagem, style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _mostrarAjuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: primaryTeal, size: 28),
            const SizedBox(width: 12),
            const Text('Como publicar dicas', style: TextStyle(color: deepOcean, fontWeight: FontWeight.bold)),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(Icons.edit, 'Escreva dicas de saúde para seus pacientes'),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.share, 'Compartilhe conhecimentos e orientações'),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.favorite, 'Os pacientes podem curtir suas dicas'),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.feed, 'As dicas aparecem no feed dos pacientes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Entendi', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: secondaryTealSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: primaryTeal),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: mutedText, fontSize: 14))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'DICAS DE SAÚDE',
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            letterSpacing: 0.5,
            fontSize: 18,
          ),
        ),
        backgroundColor: deepOcean,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _mostrarAjuda,
            tooltip: 'Ajuda',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarDicas,
        color: primaryTeal,
        backgroundColor: cardWhite,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
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
      bottomNavigationBar: MedicoBottomNavBar(
        currentIndex: 2,
        onProfileTap: () {
          Navigator.pushNamed(context, '/medico/perfil');
        },
      ),
    );
  }

  Widget _buildPublicarSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: secondaryTealSoft,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.post_add, color: primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'PUBLICAR DICA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: deepOcean,
                  ),
                ),
              ],
            ),
          ),
          
          // Formulário
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo Título
                TextField(
                  controller: _tituloController,
                  style: TextStyle(color: deepOcean, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Título (opcional)',
                    hintStyle: TextStyle(color: mutedText, fontSize: 14),
                    prefixIcon: Icon(Icons.title, color: primaryTeal, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryTeal, width: 2),
                    ),
                    filled: true,
                    fillColor: backgroundWhite,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campo Conteúdo
                TextField(
                  controller: _conteudoController,
                  maxLines: 4,
                  style: TextStyle(color: deepOcean, fontSize: 14, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Escreva sua dica de saúde...',
                    hintStyle: TextStyle(color: mutedText, fontSize: 14),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.edit_note, color: primaryTeal, size: 20),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryTeal, width: 2),
                    ),
                    filled: true,
                    fillColor: backgroundWhite,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Botão Publicar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPublicando ? null : _publicarDica,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                              fontSize: 14,
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
        // Título da seção
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ÚLTIMAS DICAS PUBLICADAS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: deepOcean,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Conteúdo da seção
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
              ),
            ),
          )
        else if (_dicas.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderLight, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: secondaryTealSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.health_and_safety, size: 48, color: primaryTeal.withOpacity(0.5)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma dica publicada ainda',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500, 
                    color: deepOcean,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Publique sua primeira dica acima!',
                  style: TextStyle(fontSize: 13, color: mutedText),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dicas.length > 3 ? 3 : _dicas.length,
            itemBuilder: (context, index) {
              final dica = _dicas[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildDicaCard(dica),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDicaCard(DicaSaude dica) {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conteúdo da dica
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dica.titulo.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: secondaryTealSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dica.titulo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryTeal,
                      ),
                    ),
                  ),
                if (dica.titulo.isNotEmpty) const SizedBox(height: 12),
                Text(
                  dica.conteudo,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: deepOcean,
                  ),
                ),
              ],
            ),
          ),
          
          // Footer do card
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              color: secondaryTealSoft.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Informações do autor
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryTeal.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medical_information,
                        size: 14,
                        color: primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dica.autor,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: deepOcean,
                          ),
                        ),
                        Text(
                          dica.especialidade,
                          style: TextStyle(
                            fontSize: 10,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Curtidas e data
                Row(
                  children: [
                    // Botão de curtir
                    InkWell(
                      onTap: () => _curtirDica(dica),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: likeRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: likeRed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatarCurtidas(dica.curtidas),
                              style: TextStyle(
                                fontSize: 11,
                                color: likeRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Data
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: mutedText.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: mutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatarData(dica.dataPublicacao),
                            style: TextStyle(
                              fontSize: 10,
                              color: mutedText,
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
      return '${diff.inDays}d';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}sem';
    } else {
      return DateFormat('dd/MM/yy').format(data);
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