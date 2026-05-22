import 'package:flutter/material.dart';
import 'package:virtualhealth/services/auth_service.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  
  const HomePage({super.key, this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.userData != null) {
      setState(() {
        _userData = widget.userData;
        _isLoading = false;
      });
    } else {
      final data = await _auth.getPerfilUsuario();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.usuarioAtual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Health'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de boas-vindas
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[800]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.health_and_safety,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Olá, ${_userData?['nome_completo']?.split(' ')[0] ?? 'Usuário'}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userData?['funcao'] == 'medico' 
                                ? 'Bem-vindo ao painel do médico'
                                : 'Bem-vindo ao painel do paciente',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informações do usuário
                  const Text(
                    'Informações da conta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.person, 'Nome', _userData?['nome_completo'] ?? ''),
                          const Divider(),
                          _buildInfoRow(Icons.email, 'E-mail', user?.email ?? ''),
                          const Divider(),
                          _buildInfoRow(
                            Icons.badge, 
                            'Tipo', 
                            _userData?['funcao'] == 'medico' ? 'Médico' : 'Paciente',
                          ),
                          if (_userData?['funcao'] == 'medico') ...[
                            const Divider(),
                            _buildInfoRow(Icons.medical_services, 'Especialidade', _userData?['especialidade'] ?? ''),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}