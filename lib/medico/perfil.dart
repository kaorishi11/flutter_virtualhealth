import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
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
  
  final Color primaryColor = const Color(0xFF3FA9C6);
  
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
      
      // Buscar perfil
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
      
      // Preencher dados
      _nomeMedico = perfil['nome_completo'] ?? '';
      _especialidade = profissional['especialidade'] ?? 'Dentista';
      _subEspecialidade = profissional['universidade'] ?? 'Odontologia Geral';
      _cidade = perfil['cidade'] ?? 'Caçapava';
      _estado = perfil['estado'] ?? 'SP';
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
    _nomeMedico = 'Marta Santos';
    _especialidade = 'Dentista';
    _subEspecialidade = 'Odontologia Geral';
    _cidade = 'Caçapava';
    _estado = 'SP';
    
    _nomeController.text = 'Marta Santos';
    _cpfController.text = '123.456.789-00';
    _emailPessoalController.text = 'marta.santos@email.com';
    _telefoneController.text = '(12) 34567-8901';
    _emailProfissionalController.text = 'dra.marta@consultorio.com';
    _enderecoConsultorioController.text = 'Rua Principal, 123 - Centro, Caçapava - SP';
    _enderecoPessoalController.text = 'Av. das Flores, 456 - Jardim América, Caçapava - SP';
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
      
      // Atualizar perfil
      await supabase.from('perfis').update({
        'nome_completo': _nomeController.text,
        'cpf': _cpfController.text,
        'telefone': _telefoneController.text,
        'endereco': _enderecoPessoalController.text,
        'cidade': _cidade,
        'estado': _estado,
        'data_nascimento': _dataNascimento,
        'genero': _genero,
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('auth_id', user.id);
      
      // Atualizar profissional
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
      
      // Atualizar senha no Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(password: _novaSenhaController.text)
      );
      
      _senhaAtualController.clear();
      _novaSenhaController.clear();
      _confirmarSenhaController.clear();
      
      _mostrarSnackbar('Senha alterada com sucesso!');
      
    } catch (e) {
      debugPrint('Erro ao alterar senha: $e');
      _mostrarSnackbar('Erro ao alterar senha. Verifique sua senha atual.');
    }
    
    setState(() {
      _isSaving = false;
    });
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
        title: const Text('Excluir conta permanentemente'),
        content: const Text(
          'ATENÇÃO! A exclusão da conta é permanente e não pode ser desfeita. '
          'Todos os seus dados, agendamentos e histórico médico serão removidos.\n\n'
          'Tem certeza que deseja excluir sua conta?',
        ),
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
    
    if (confirmado == true) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        final user = supabase.auth.currentUser;
        if (user == null) throw Exception('Usuário não autenticado');
        
        // Excluir usuário (isso pode exigir funções de admin no Supabase)
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
      
      // Upload da imagem para o Supabase Storage
      try {
        final user = supabase.auth.currentUser;
        if (user == null) return;
        
        final fileExtension = imagem.path.split('.').last;
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        
        await supabase.storage.from('perfil_fotos').upload(fileName, _imagemSelecionada!);
        final fotoUrl = supabase.storage.from('perfil_fotos').getPublicUrl(fileName);
        
        // Atualizar URL no perfil
        await supabase.from('perfis').update({
          'metadados': {'foto_url': fotoUrl}
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
        content: Text(mensagem),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Selecione o gênero',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.female),
              title: const Text('Feminino'),
              onTap: () {
                setState(() => _genero = 'Feminino');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.male),
              title: const Text('Masculino'),
              onTap: () {
                setState(() => _genero = 'Masculino');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.transgender),
              title: const Text('Prefiro não informar'),
              onTap: () {
                setState(() => _genero = 'Não informado');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarDadosPerfil,
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
                    const SizedBox(height: 40),
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
        'PERFIL',
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
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getIniciais(_nomeMedico),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
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
                  _nomeMedico.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_especialidade · $_subEspecialidade',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '$_cidade, $_estado',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Paciente desde 2026',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FOTO DE PERFIL',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  backgroundImage: _imagemSelecionada != null
                      ? FileImage(_imagemSelecionada!)
                      : (_fotoUrl.isNotEmpty
                          ? NetworkImage(_fotoUrl) as ImageProvider
                          : null),
                  child: _imagemSelecionada == null && _fotoUrl.isEmpty
                      ? Text(
                          _getIniciais(_nomeMedico),
                          style: TextStyle(fontSize: 32, color: primaryColor),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _selecionarFoto,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Editar foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
  
  Widget _buildSegurancaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEGURANÇA',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _senhaAtualController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha atual',
              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _novaSenhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Nova senha',
              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmarSenhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirmar nova senha',
              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _alterarSenha,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar alterações'),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VALORES DAS CONSULTAS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valorPresencialController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Consulta presencial (R\$)',
              prefixIcon: Icon(Icons.attach_money, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valorOnlineController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Consulta Online (R\$)',
              prefixIcon: Icon(Icons.videocam, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _salvarValoresConsultas,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DADOS PESSOAIS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.person, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cpfController,
            decoration: InputDecoration(
              labelText: 'CPF',
              prefixIcon: Icon(Icons.badge, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailPessoalController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail pessoal',
              prefixIcon: Icon(Icons.email, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telefone',
              prefixIcon: Icon(Icons.phone, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailProfissionalController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail profissional',
              prefixIcon: Icon(Icons.business_center, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selecionarDataNascimento,
            child: AbsorbPointer(
              child: TextField(
                controller: TextEditingController(
                  text: _dataNascimento.isNotEmpty
                      ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_dataNascimento))
                      : '',
                ),
                decoration: InputDecoration(
                  labelText: 'Aniversário',
                  prefixIcon: Icon(Icons.cake, color: primaryColor),
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Sexo',
                  prefixIcon: Icon(Icons.wc, color: primaryColor),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _enderecoConsultorioController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Ender. do consultório',
              prefixIcon: Icon(Icons.medical_services, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _enderecoPessoalController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Endereço pessoal',
              prefixIcon: Icon(Icons.home, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _salvarDadosPessoais,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar alterações'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _carregarDadosPerfil();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancelar'),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                'ATENÇÃO!',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A exclusão da conta é permanente e não pode ser desfeita. '
            'Todos os seus dados, agendamentos e histórico médico serão removidos.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _excluirConta,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Excluir conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getIniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.isEmpty) return 'M';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }
}