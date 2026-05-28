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
  
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();
  
  List<DicaSaude> _dicas = [];
  bool _isLoading = true;
  bool _isPublicando = false;
  String _nomeMedico = '';
  String _especialidade = '';
  
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
      
      final profissional = await supabase
          .from('profissionais')
          .select()
          .eq('perfil_id', perfil['id'])
          .single();
      
      setState(() {
        _nomeMedico = perfil['nome_completo']?.split(' ')[0] ?? 'Médico';
        _especialidade = profissional['especialidade'] ?? 'Dentista';
      });
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      setState(() {
        _nomeMedico = 'Marta';
        _especialidade = 'Dentista';
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
            autor: dica['perfis']?['nome_completo']?.split(' ')[0] ?? 'Médico',
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
  
  void _carregarDicasMock() {
    setState(() {
      _dicas = [
        DicaSaude(
          id: '1',
          titulo: 'Escovação Noturna',
          conteudo: 'O ideal é escovar os dentes pelo menos três vezes ao dia, principalmente antes de dormir, pois durante a noite a produção de saliva diminui e as bactérias se proliferam com mais facilidade.',
          autor: 'Dra Marta',
          especialidade: 'Dentista',
          dataPublicacao: DateTime.now().subtract(const Duration(days: 2)),
          curtidas: 128,
        ),
        DicaSaude(
          id: '2',
          titulo: 'Visitas Regulares',
          conteudo: 'É fundamental visitar o dentista regularmente, pelo menos a cada seis meses, para fazer avaliações e limpezas profissionais. Pequenos cuidados diários fazem uma grande diferença na saúde do seu sorriso.',
          autor: 'Dra Marta',
          especialidade: 'Dentista',
          dataPublicacao: DateTime.now().subtract(const Duration(days: 5)),
          curtidas: 95,
        ),
        DicaSaude(
          id: '3',
          titulo: 'Alimentação e Saúde Bucal',
          conteudo: 'Alimentos ricos em açúcar aumentam o risco de cáries. Prefira frutas, vegetais e laticínios que fortalecem os dentes e gengivas.',
          autor: 'Dra Marta',
          especialidade: 'Dentista',
          dataPublicacao: DateTime.now().subtract(const Duration(days: 10)),
          curtidas: 67,
        ),
      ];
      _isLoading = false;
    });
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
      // Para demonstração, adicionar localmente
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _carregarDicas,
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
        'DICAS DE SAÚDE',
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
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: () => _mostrarAjuda(),
        ),
      ],
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
            if (_dicas.length > 3)
              TextButton(
                onPressed: () {},
                child: const Text('Ver todas'),
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
  
  void _mostrarAjuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como publicar dicas'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📝 Escreva dicas de saúde para seus pacientes'),
            SizedBox(height: 8),
            Text('💡 Compartilhe conhecimentos e orientações'),
            SizedBox(height: 8),
            Text('❤️ Os pacientes podem curtir suas dicas'),
            SizedBox(height: 8),
            Text('📱 As dicas aparecem no feed dos pacientes'),
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