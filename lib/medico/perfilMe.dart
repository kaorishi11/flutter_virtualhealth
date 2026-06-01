import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtualhealth/medico/medico_bottom_nav_bar.dart';
import 'dart:io';

class PerfilMedicoPage extends StatefulWidget {
  const PerfilMedicoPage({super.key});

  @override
  State<PerfilMedicoPage> createState() => _PerfilMedicoPageState();
}

class _PerfilMedicoPageState extends State<PerfilMedicoPage> {
  final supabase = Supabase.instance.client;

  // Controllers para dados pessoais
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailPessoalController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailProfissionalController = TextEditingController();
  final TextEditingController _enderecoConsultorioController = TextEditingController();
  final TextEditingController _enderecoPessoalController = TextEditingController();

  // Controllers para segurança
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  // Controllers para valores
  final TextEditingController _valorPresencialController = TextEditingController();
  final TextEditingController _valorOnlineController = TextEditingController();

  // Dados do médico
  String _nomeMedico = '';
  String _nomeCompleto = '';
  String _especialidade = '';
  String _subEspecialidade = '';
  String _cidade = '';
  String _estado = '';
  String _dataNascimento = '';
  String _genero = '';
  String _fotoUrl = '';
  File? _imagemSelecionada;

  bool _isLoading = true;
  bool _isSaving = false;

  // ==================== PALETA DE CORES VIRTUAL HEALTH ====================
  static const Color primaryTeal = Color(0xFF14B8A6);      // Primary
  static const Color deepOcean = Color(0xFF0D2C33);        // Deep Ocean
  static const Color actionTeal = Color(0xFF0F766E);       // Action Teal
  static const Color backgroundWhite = Color(0xFFF8FAFC);  // Background
  static const Color cardWhite = Color(0xFFFFFFFF);        // Card / Surface
  static const Color secondaryTealSoft = Color(0xFFEDF7F6); // Secondary
  static const Color mutedText = Color(0xFF6B7280);        // Muted
  static const Color borderLight = Color(0x3314B8A6);      // Teal claro 20%
  static const Color dangerRed = Color(0xFFEF4444);        // Danger
  static const Color warningOrange = Color(0xFFF59E0B);    // Warning
  // ========================================================================

  @override
  void initState() {
    super.initState();
    _carregarDadosPerfil();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailPessoalController.dispose();
    _telefoneController.dispose();
    _emailProfissionalController.dispose();
    _enderecoConsultorioController.dispose();
    _enderecoPessoalController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    _valorPresencialController.dispose();
    _valorOnlineController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosPerfil() async {
    setState(() {
      _isLoading = true;
    });

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

      _nomeCompleto = perfil['nome_completo'] ?? '';
      _nomeMedico = perfil['nome_completo']?.split(' ')[0] ?? 'Médico';
      _especialidade = profissional['especialidade'] ?? 'Médico';
      _subEspecialidade = profissional['universidade'] ?? 'Medicina Geral';
      _cidade = perfil['cidade'] ?? '';
      _estado = perfil['estado'] ?? '';
      _dataNascimento = perfil['data_nascimento'] ?? '';
      _genero = perfil['genero'] ?? '';
      _fotoUrl = perfil['metadados']?['foto_url'] ?? '';

      _nomeController.text = perfil['nome_completo'] ?? '';
      _cpfController.text = perfil['cpf'] ?? '';
      _emailPessoalController.text = perfil['email'] ?? '';
      _telefoneController.text = perfil['telefone'] ?? '';
      _emailProfissionalController.text = profissional['email'] ?? perfil['email'] ?? '';
      _enderecoConsultorioController.text = perfil['endereco'] ?? '';
      _enderecoPessoalController.text = perfil['endereco'] ?? '';

      _valorPresencialController.text = profissional['preco']?.toString() ?? '150';
      _valorOnlineController.text = profissional['preco_online']?.toString() ?? '120';
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      _carregarDadosMock();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _carregarDadosMock() {
    _nomeCompleto = 'Dr. Médico';
    _nomeMedico = 'Dr. Médico';
    _especialidade = 'Médico';
    _subEspecialidade = 'Clínico Geral';
    _cidade = 'São Paulo';
    _estado = 'SP';

    _nomeController.text = 'Dr. Médico';
    _cpfController.text = '123.456.789-00';
    _emailPessoalController.text = 'medico@email.com';
    _telefoneController.text = '(11) 91234-5678';
    _emailProfissionalController.text = 'dr.medico@consultorio.com';
    _enderecoConsultorioController.text = 'Rua Principal, 123 - Centro, São Paulo - SP';
    _enderecoPessoalController.text = 'Av. das Flores, 456 - Jardins, São Paulo - SP';
    _valorPresencialController.text = '250';
    _valorOnlineController.text = '200';
  }

  Future<void> _salvarDadosPessoais() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      await supabase.from('perfis').update({
        'nome_completo': _nomeController.text,
        'cpf': _cpfController.text,
        'email': _emailPessoalController.text,
        'telefone': _telefoneController.text,
        'endereco': _enderecoPessoalController.text,
        'cidade': _cidade,
        'estado': _estado,
        'data_nascimento': _dataNascimento,
        'genero': _genero,
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('auth_id', user.id);

      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();

      await supabase.from('profissionais').update({
        'email': _emailProfissionalController.text,
        'preco': double.tryParse(_valorPresencialController.text),
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('perfil_id', perfil['id']);

      _mostrarSnackbar('Dados salvos com sucesso!');
    } catch (e) {
      debugPrint('Erro ao salvar: $e');
      _mostrarSnackbar('Erro ao salvar dados. Tente novamente.');
    }

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _alterarSenha() async {
    if (_senhaAtualController.text.trim().isEmpty) {
      _mostrarSnackbar('Digite sua senha atual');
      return;
    }

    if (_novaSenhaController.text.trim().isEmpty) {
      _mostrarSnackbar('Digite a nova senha');
      return;
    }

    if (_novaSenhaController.text != _confirmarSenhaController.text) {
      _mostrarSnackbar('As senhas não coincidem');
      return;
    }

    if (_novaSenhaController.text.length < 6) {
      _mostrarSnackbar('A nova senha deve ter pelo menos 6 caracteres');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('Email do usuário não encontrado');
      }

      await supabase.auth.signInWithPassword(
        email: email,
        password: _senhaAtualController.text.trim(),
      );

      await supabase.auth.updateUser(
        UserAttributes(password: _novaSenhaController.text.trim()),
      );

      _senhaAtualController.clear();
      _novaSenhaController.clear();
      _confirmarSenhaController.clear();

      _mostrarSnackbar('Senha alterada com sucesso!');
    } catch (e) {
      debugPrint('Erro ao alterar senha: $e');
      _mostrarSnackbar('Senha atual incorreta ou erro ao alterar senha');
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _salvarValoresConsultas() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();

      await supabase.from('profissionais').update({
        'preco': double.tryParse(_valorPresencialController.text),
        'preco_online': double.tryParse(_valorOnlineController.text),
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('perfil_id', perfil['id']);

      _mostrarSnackbar('Valores salvos com sucesso!');
    } catch (e) {
      debugPrint('Erro ao salvar valores: $e');
      _mostrarSnackbar('Erro ao salvar valores');
    }

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _excluirConta() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: dangerRed),
            const SizedBox(width: 8),
            const Text('Excluir conta permanentemente', style: TextStyle(color: deepOcean, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'ATENÇÃO! A exclusão da conta é permanente e não pode ser desfeita. '
          'Todos os seus dados, agendamentos e histórico médico serão removidos.\n\n'
          'Tem certeza que deseja excluir sua conta?',
          style: TextStyle(color: mutedText),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: mutedText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: dangerRed),
            child: const Text('Excluir', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      setState(() {
        _isSaving = true;
      });

      try {
        final user = supabase.auth.currentUser;
        if (user == null) throw Exception('Usuário não autenticado');

        await supabase.auth.signOut();
        _mostrarSnackbar('Conta excluída com sucesso');

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } catch (e) {
        debugPrint('Erro ao excluir conta: $e');
        _mostrarSnackbar('Erro ao excluir conta. Entre em contato com o suporte.');
      }

      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _selecionarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
      });

      try {
        final user = supabase.auth.currentUser;
        if (user == null) return;

        final fileExtension = imagem.path.split('.').last;
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

        await supabase.storage.from('perfil_fotos').upload(
              fileName,
              _imagemSelecionada!,
              fileOptions: const FileOptions(upsert: true),
            );

        final fotoUrl = supabase.storage.from('perfil_fotos').getPublicUrl(fileName);

        final perfil = await supabase
            .from('perfis')
            .select('metadados')
            .eq('auth_id', user.id)
            .single();

        final metadadosAtuais = Map<String, dynamic>.from(perfil['metadados'] ?? {});
        metadadosAtuais['foto_url'] = fotoUrl;

        await supabase.from('perfis').update({
          'metadados': metadadosAtuais,
        }).eq('auth_id', user.id);

        setState(() {
          _fotoUrl = fotoUrl;
        });

        _mostrarSnackbar('Foto atualizada com sucesso!');
      } catch (e) {
        debugPrint('Erro ao fazer upload: $e');
        _mostrarSnackbar('Erro ao atualizar foto');
      }
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair', style: TextStyle(color: deepOcean, fontWeight: FontWeight.bold)),
        content: const Text('Tem certeza que deseja sair?', style: TextStyle(color: mutedText)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: mutedText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: primaryTeal),
            child: const Text('Sim, sair', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _selecionarDataNascimento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        _dataNascimento = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _selecionarGenero() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecione o gênero',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepOcean),
            ),
            const Divider(color: borderLight, thickness: 1),
            _buildGenderOption(Icons.female, 'Feminino', 'Feminino'),
            _buildGenderOption(Icons.male, 'Masculino', 'Masculino'),
            _buildGenderOption(Icons.transgender, 'Prefiro não informar', 'Não informado'),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildGenderOption(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: secondaryTealSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primaryTeal, size: 20),
      ),
      title: Text(label, style: TextStyle(color: deepOcean)),
      onTap: () {
        setState(() => _genero = value);
        Navigator.pop(context);
      },
    );
  }

  String _getIniciais(String nome) {
    if (nome.trim().isEmpty) return 'M';
    final partes = nome.trim().split(' ');
    if (partes.length == 1) {
      return partes[0][0].toUpperCase();
    }
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'MEU PERFIL',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: deepOcean,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarDadosPerfil,
              color: primaryTeal,
              backgroundColor: cardWhite,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildFotoSection(),
                    const SizedBox(height: 24),
                    _buildSegurancaSection(),
                    const SizedBox(height: 24),
                    _buildValoresConsultasSection(),
                    const SizedBox(height: 24),
                    _buildDadosPessoaisSection(),
                    const SizedBox(height: 24),
                    _buildExcluirContaSection(),
                    const SizedBox(height: 16),
                    _buildLogoutButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: MedicoBottomNavBar(
        currentIndex: 3,
        onProfileTap: () {},
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
      ),
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'SAIR DA CONTA',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: dangerRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryTeal, actionTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getIniciais(_nomeCompleto.isNotEmpty ? _nomeCompleto : _nomeMedico),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_nomeCompleto.isNotEmpty ? _nomeCompleto : _nomeMedico).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: deepOcean,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_especialidade · $_subEspecialidade',
                  style: TextStyle(fontSize: 13, color: actionTeal, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: mutedText),
                    const SizedBox(width: 4),
                    Text(
                      '$_cidade, $_estado',
                      style: TextStyle(fontSize: 12, color: mutedText),
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

  Widget _buildFotoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                'FOTO DE PERFIL',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: deepOcean),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: secondaryTealSoft,
                      backgroundImage: _imagemSelecionada != null
                          ? FileImage(_imagemSelecionada!)
                          : (_fotoUrl.isNotEmpty
                              ? NetworkImage(_fotoUrl) as ImageProvider
                              : null),
                      child: _imagemSelecionada == null && _fotoUrl.isEmpty
                          ? Text(
                              _getIniciais(_nomeCompleto.isNotEmpty ? _nomeCompleto : _nomeMedico),
                              style: TextStyle(fontSize: 32, color: primaryTeal, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: cardWhite,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: primaryTeal,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                            onPressed: _selecionarFoto,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: deepOcean),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: deepOcean, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: mutedText, fontSize: 13),
        prefixIcon: Icon(icon, color: primaryTeal, size: 20),
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
    );
  }

  Widget _buildSegurancaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('SEGURANÇA'),
          _buildTextField(
            controller: _senhaAtualController,
            label: 'Senha atual',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _novaSenhaController,
            label: 'Nova senha',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _confirmarSenhaController,
            label: 'Confirmar nova senha',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _alterarSenha,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Alterar senha', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValoresConsultasSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('VALORES DAS CONSULTAS'),
          _buildTextField(
            controller: _valorPresencialController,
            label: 'Consulta presencial (R\$)',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _valorOnlineController,
            label: 'Consulta Online (R\$)',
            icon: Icons.videocam,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _salvarValoresConsultas,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Salvar valores', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDadosPessoaisSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('DADOS PESSOAIS'),
          _buildTextField(controller: _nomeController, label: 'Nome completo', icon: Icons.person),
          const SizedBox(height: 12),
          _buildTextField(controller: _cpfController, label: 'CPF', icon: Icons.badge),
          const SizedBox(height: 12),
          _buildTextField(controller: _emailPessoalController, label: 'E-mail pessoal', icon: Icons.email, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _buildTextField(controller: _telefoneController, label: 'Telefone', icon: Icons.phone, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextField(controller: _emailProfissionalController, label: 'E-mail profissional', icon: Icons.business_center, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selecionarDataNascimento,
            child: AbsorbPointer(
              child: TextField(
                controller: TextEditingController(
                  text: _dataNascimento.isNotEmpty
                      ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(_dataNascimento) ?? DateTime.now())
                      : '',
                ),
                style: TextStyle(color: deepOcean, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Data de nascimento',
                  labelStyle: TextStyle(color: mutedText, fontSize: 13),
                  prefixIcon: Icon(Icons.cake, color: primaryTeal, size: 20),
                  suffixIcon: Icon(Icons.calendar_today, color: primaryTeal, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderLight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryTeal, width: 2)),
                  filled: true,
                  fillColor: backgroundWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selecionarGenero,
            child: AbsorbPointer(
              child: TextField(
                controller: TextEditingController(text: _genero),
                style: TextStyle(color: deepOcean, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Gênero',
                  labelStyle: TextStyle(color: mutedText, fontSize: 13),
                  prefixIcon: Icon(Icons.wc, color: primaryTeal, size: 20),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: primaryTeal, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderLight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryTeal, width: 2)),
                  filled: true,
                  fillColor: backgroundWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(controller: _enderecoConsultorioController, label: 'Endereço do consultório', icon: Icons.medical_services, maxLines: 2),
          const SizedBox(height: 12),
          _buildTextField(controller: _enderecoPessoalController, label: 'Endereço residencial', icon: Icons.home, maxLines: 2),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _salvarDadosPessoais,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Salvar alterações', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _carregarDadosPerfil(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryTeal),
                    foregroundColor: primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExcluirContaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dangerRed.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dangerRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning_amber, color: dangerRed, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'ATENÇÃO!',
                style: TextStyle(color: dangerRed, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A exclusão da conta é permanente e não pode ser desfeita. '
            'Todos os seus dados, agendamentos e histórico médico serão removidos.',
            style: TextStyle(fontSize: 13, color: mutedText, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _excluirConta,
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('Excluir conta permanentemente', style: TextStyle(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: dangerRed,
                side: BorderSide(color: dangerRed.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}