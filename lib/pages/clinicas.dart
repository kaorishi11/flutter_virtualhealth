import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_service.dart';
import 'home.dart';
import 'login.dart';
import 'cadastro.dart';
import 'contato.dart';
import 'chatbot.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ClinicasPage extends StatefulWidget {
  const ClinicasPage({super.key});

  @override
  State<ClinicasPage> createState() => _ClinicasPageState();
}

class _ClinicasPageState extends State<ClinicasPage> {
  final AuthService _auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _isLoggedIn = false;
  String? _userName;
  String? _userFuncao;
  Map<String, dynamic>? _userProfile;
  
  String _selectedEspecialidade = 'Especialista';
  String _selectedLocalizacao = 'Caçapava, São Paulo - SP';

  final List<String> _especialidades = [
    'Especialista',
    'Dentista',
    'Oftalmologista',
    'Ginecologista',
  ];

  final List<String> _localizacoes = [
    'Caçapava, São Paulo - SP',
    'São José dos Campos - SP',
  ];

  final List<Map<String, dynamic>> _medicos = [
    {
      'nome': 'Dra Marta',
      'especialidade': 'Dentista',
      'avaliacao': 4.9,
      'totalAvaliacoes': 38,
      'endereco': 'Clínica Sul - Santa Casa São José dos Campos',
      'preco': 90.00,
      'lat': -23.1896,
      'lng': -45.8841,
    },
    {
      'nome': 'Dr Andrey',
      'especialidade': 'Oftalmologista',
      'avaliacao': 4.9,
      'totalAvaliacoes': 38,
      'endereco': 'Av. Andrômeda - Jardim Satélite',
      'preco': 60.00,
      'lat': -23.2237,
      'lng': -45.9009,
    },
    {
      'nome': 'Dra Sheila',
      'especialidade': 'Ginecologista',
      'avaliacao': 4.9,
      'totalAvaliacoes': 38,
      'endereco': 'R. Cel. João Dias Guimarães - Centro',
      'preco': 60.00,
      'lat': -23.1005,
      'lng': -45.7075,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final user = _auth.usuarioAtual;
      if (user != null) {
        final profile = await _auth.getPerfilUsuario();
        if (mounted && profile != null) {
          setState(() {
            _isLoggedIn = true;
            _userProfile = profile;
            _userName = profile['nome_completo']?.split(' ')[0] ?? 'Usuário';
            _userFuncao = profile['funcao'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _userName = null;
            _userProfile = null;
            _userFuncao = null;
          });
        }
      }
    } catch (e) {
      print('Erro ao verificar auth: $e');
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userName = null;
        _userProfile = null;
        _userFuncao = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout realizado com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF3FA9C6),
              child: Text(
                _userName != null && _userName!.isNotEmpty 
                    ? _userName![0].toUpperCase() 
                    : 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _userProfile?['nome_completo'] ?? 'Usuário',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _userFuncao == 'paciente' ? 'Paciente' : 'Médico',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFF3FA9C6)),
              title: const Text('Meu Perfil'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Color(0xFF3FA9C6)),
              title: const Text('Minhas Consultas'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Color(0xFF3FA9C6)),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil de ${_userProfile?['nome_completo'] ?? 'Usuário'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onPageChanged(String page) {
    if (page == 'Início') {
      Navigator.pushReplacementNamed(context, '/');
    } else if (page == 'Contato') {
      Navigator.pushNamed(context, '/contato');
    } else if (page == 'Chatbot') {
      Navigator.pushNamed(context, '/chatbot');
    } else if (page == 'Fazer Consulta') {
      if (_isLoggedIn) {
        _showUserMenu();
      } else {
        Navigator.pushNamed(context, '/login');
      }
    } else if (page == 'Cadastro') {
      Navigator.pushNamed(context, '/cadastro');
    } else if (page == 'Perfil') {
      _showUserMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isMobile),
            const SizedBox(height: 40),
            _buildTitle(isMobile),
            const SizedBox(height: 40),
            _buildFilters(isMobile),
            const SizedBox(height: 50),
            _buildMedicosList(isMobile),
            const SizedBox(height: 50),
            _buildFooter(isMobile),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        isLoggedIn: _isLoggedIn,
        onProfileTap: () {
          if (_isLoggedIn) {
            _showUserMenu();
          } else {
            Navigator.pushNamed(context, '/login');
          }
        },
      ),
    );
  }


  // ================= HEADER COM IMAGEM DE FUNDO =================
  Widget _buildHeader(bool isMobile) {
    return Container(
      height: isMobile ? 280 : 400,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/doutorclinica.png'),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            print('Erro ao carregar imagem: $exception');
            // Fallback para cor sólida se a imagem não existir
          },
        ),
        color: const Color(0xFF0D47A1), // Cor de fallback
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF0D47A1).withOpacity(0.85),
              const Color(0xFF1565C0).withOpacity(0.5),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 50,
            vertical: isMobile ? 20 : 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMobile ? 'CONHEÇA TODAS AS\nCLÍNICAS' : 'CONHEÇA TODAS AS\nCLÍNICAS',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'PRESENCIAIS',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 52,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4FC3F7),
                  height: 1.1,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Container(
                width: isMobile ? double.infinity : 500,
                child: Text(
                  'Encontre especialistas próximos a você e agende sua consulta.',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 22,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TITULO =================
  Widget _buildTitle(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clínicas e especialistas para você',
            style: TextStyle(
              fontSize: isMobile ? 24 : 42,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: isMobile ? 200 : 520,
            height: 3,
            color: const Color(0xFF1194F6),
          ),
        ],
      ),
    );
  }

  // ================= FILTROS RESPONSIVOS =================
  Widget _buildFilters(bool isMobile) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Procure clínicas ou especialistas...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedEspecialidade,
                        isExpanded: true,
                        items: _especialidades.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEspecialidade = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLocalizacao,
                        isExpanded: true,
                        items: _localizacoes.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocalizacao = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 4,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Procure clínicas ou especialistas...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 190,
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEspecialidade,
                  items: _especialidades.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEspecialidade = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 300,
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocalizacao,
                  items: _localizacoes.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocalizacao = value!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ================= LISTA DE MÉDICOS RESPONSIVA =================
  Widget _buildMedicosList(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 50),
      child: Column(
        children: _medicos
            .map((medico) => _buildCard(medico, isMobile))
            .toList(),
      ),
    );
  }

  // ================= CARD RESPONSIVO =================
  Widget _buildCard(Map<String, dynamic> medico, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 35),
      padding: EdgeInsets.all(isMobile ? 15 : 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/doctor.jpg'),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medico['nome'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            medico['especialidade'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                '(${medico['avaliacao']} · ${medico['totalAvaliacoes']})',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buttonBlue('Endereço', isMobile),
                    const SizedBox(width: 10),
                    _buttonOutline('Teleconsulta', isMobile),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF148A96), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        medico['endereco'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  'Consulta: R\$${medico['preco']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF148A96),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Agendar Consulta',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Localização',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          medico['lat'],
                          medico['lng'],
                        ),
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                medico['lat'],
                                medico['lng'],
                              ),
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 35,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/images/doctor.jpg'),
                          ),
                          const SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medico['nome'],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                medico['especialidade'],
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 18),
                                  const SizedBox(width: 5),
                                  Text(
                                    '(${medico['avaliacao']} · ${medico['totalAvaliacoes']} avaliações)',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          _buttonBlue('Endereço', isMobile),
                          const SizedBox(width: 12),
                          _buttonOutline('Teleconsulta', isMobile),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF148A96)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              medico['endereco'],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Consulta: R\$${medico['preco']}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 260,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF148A96),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Agendar Consulta',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Localização',
                        style: TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 250,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                medico['lat'],
                                medico['lng'],
                              ),
                              initialZoom: 15,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      medico['lat'],
                                      medico['lng'],
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buttonBlue(String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 15 : 20,
        vertical: isMobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF148A96),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 14 : 18,
        ),
      ),
    );
  }

  Widget _buttonOutline(String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 15 : 20,
        vertical: isMobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF148A96)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF148A96),
          fontSize: isMobile ? 14 : 18,
        ),
      ),
    );
  }

  // ================= FOOTER IGUAL AO DA HOME =================
  Widget _buildFooter(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                width: isMobile ? 150 : 200,
                height: isMobile ? 150 : 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
              child: Text(
                'Cuidando da sua saúde com tecnologia e humanidade. Disponível 24 horas por dia, 7 dias por semana.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile ? 14 : 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (isMobile) ...[
              _buildFooterLinksCentralizado('Serviços', [
                'Teleconsultas 24h',
                'Agendamento online',
                'Especialidades',
                'Exames',
                'Prontuário digital',
              ]),
              const SizedBox(height: 30),
              _buildFooterLinksCentralizado('Institucional', [
                'Sobre nós',
                'Carreiras',
                'Blog',
                'Imprensa',
                'Seja parceiro',
              ]),
              const SizedBox(height: 30),
              _buildFooterLinksCentralizado('Suporte', [
                'Central de ajuda',
                'FAQ',
                'Contato',
                'Termos de uso',
                'Privacidade',
              ]),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterLinksCentralizado('Serviços', [
                    'Teleconsultas 24h',
                    'Agendamento online',
                    'Especialidades',
                    'Exames',
                    'Prontuário digital',
                  ]),
                  _buildFooterLinksCentralizado('Institucional', [
                    'Sobre nós',
                    'Carreiras',
                    'Blog',
                    'Imprensa',
                    'Seja parceiro',
                  ]),
                  _buildFooterLinksCentralizado('Suporte', [
                    'Central de ajuda',
                    'FAQ',
                    'Contato',
                    'Termos de uso',
                    'Privacidade',
                  ]),
                ],
              ),
            ],
            const SizedBox(height: 40),
            Divider(color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 24),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(Icons.facebook),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.phone_android),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.email),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '© 2026 Virtual Health - Todos os direitos reservados',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isMobile ? 10 : 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFooterLinksCentralizado(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {},
                child: Text(
                  link,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
      ],
    );
  }
}