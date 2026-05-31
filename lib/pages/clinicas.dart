import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ClinicasPage extends StatefulWidget {
  const ClinicasPage({super.key});

  @override
  State<ClinicasPage> createState() => _ClinicasPageState();
}

class _ClinicasPageState extends State<ClinicasPage> {
  final AuthService _auth = AuthService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userName;
  String? _userFuncao;
  Map<String, dynamic>? _userProfile;

  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];

  Doctor? _selectedDoctor;
  bool _modalOpen = false;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _checkAuthState();
    _fetchDoctors();
    _searchController.addListener(_filterDoctors);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDoctors);
    _searchController.dispose();
    super.dispose();
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

  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final List<Doctor> mockDoctors = [
        Doctor(
          id: '1',
          name: 'Dra. Marta Silva',
          specialty: 'Dentista',
          rating: 4.9,
          totalReviews: 38,
          address: 'Clínica Sul - Santa Casa São José dos Campos',
          price: 90.00,
          lat: -23.1896,
          lng: -45.8841,
          imageUrl: 'assets/images/doctor.jpg',
          experience: '12 anos de experiência',
          crm: '123456-SP',
        ),
        Doctor(
          id: '2',
          name: 'Dr. Andrey Santos',
          specialty: 'Oftalmologista',
          rating: 4.9,
          totalReviews: 38,
          address: 'Av. Andrômeda - Jardim Satélite',
          price: 60.00,
          lat: -23.2237,
          lng: -45.9009,
          imageUrl: 'assets/images/doctor.jpg',
          experience: '8 anos de experiência',
          crm: '789012-SP',
        ),
        Doctor(
          id: '3',
          name: 'Dra. Sheila Costa',
          specialty: 'Ginecologista',
          rating: 4.9,
          totalReviews: 38,
          address: 'R. Cel. João Dias Guimarães - Centro',
          price: 60.00,
          lat: -23.1005,
          lng: -45.7075,
          imageUrl: 'assets/images/doctor.jpg',
          experience: '15 anos de experiência',
          crm: '345678-SP',
        ),
      ];

      if (mounted) {
        setState(() {
          _doctors = mockDoctors;
          _filteredDoctors = List.from(mockDoctors);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar médicos: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    if (mounted) {
      setState(() {
        _filteredDoctors = _doctors.where((doctor) {
          return doctor.name.toLowerCase().contains(query) ||
              doctor.specialty.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _openBookingModal(Doctor doctor) {
    setState(() {
      _selectedDoctor = doctor;
      _modalOpen = true;
    });
  }

  void _closeBookingModal() {
    setState(() {
      _modalOpen = false;
      _selectedDoctor = null;
    });
  }

  Future<void> _submitBooking(
      DateTime date, TimeOfDay time, String type) async {
    print('Agendando: ${_selectedDoctor?.name} - $date - $time - $type');
    _closeBookingModal();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consulta agendada com ${_selectedDoctor?.name}!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
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
                const SizedBox(height: 15),
                Text(
                  _userProfile?['nome_completo'] ?? 'Usuário',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  (_userProfile?['funcao'] ?? 'paciente') == 'paciente'
                      ? 'Paciente'
                      : 'Médico',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline,
                      color: Color(0xFF1565C0)),
                  title: const Text('Editar perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/perfil');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month,
                      color: Color(0xFF1565C0)),
                  title: const Text('Meus agendamentos'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/agendamentos');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('Sair', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 40),
                _buildTitle(isMobile),
                const SizedBox(height: 24),
                _buildSearchBar(isMobile),
                const SizedBox(height: 32),
                _buildDoctorsList(isMobile),
                const SizedBox(height: 50),
                _buildFooter(isMobile),
              ],
            ),
          ),
          if (_modalOpen && _selectedDoctor != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeBookingModal,
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: BookingModalWidget(
                        doctor: _selectedDoctor!,
                        onClose: _closeBookingModal,
                        onSubmit: _submitBooking,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
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

  Widget _buildHeader(bool isMobile) {
    return Container(
      height: isMobile ? 280 : 400,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/doutorclinica.png'),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) =>
              print('Erro ao carregar imagem: $exception'),
        ),
        color: const Color(0xFF0D47A1),
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
              horizontal: isMobile ? 20 : 50, vertical: isMobile ? 20 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMobile
                    ? 'CONHEÇA TODAS AS\nCLÍNICAS'
                    : 'CONHEÇA TODAS AS\nCLÍNICAS',
                style: TextStyle(
                    fontSize: isMobile ? 32 : 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1),
              ),
              Text(
                'PRESENCIAIS',
                style: TextStyle(
                    fontSize: isMobile ? 28 : 52,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4FC3F7),
                    height: 1.1),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Container(
                width: isMobile ? double.infinity : 500,
                child: Text(
                  'Encontre especialistas próximos a você e agende sua consulta.',
                  style: TextStyle(
                      fontSize: isMobile ? 16 : 22, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clínicas e especialistas para você',
            style: TextStyle(
                fontSize: isMobile ? 24 : 42, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 10),
          Container(
              width: isMobile ? 200 : 520,
              height: 3,
              color: const Color(0xFF1194F6)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 50),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Procure clínicas ou especialistas...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF3FA9C6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsList(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Color(0xFF3FA9C6)),
        ),
      );
    }

    if (_filteredDoctors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum especialista encontrado para sua busca.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 50),
      child: Column(
        children: _filteredDoctors
            .map((doctor) => _buildDoctorCard(doctor, isMobile))
            .toList(),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 35),
      padding: EdgeInsets.all(isMobile ? 15 : 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: isMobile ? _buildMobileCard(doctor) : _buildDesktopCard(doctor),
    );
  }

  Widget _buildMobileCard(Doctor doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(doctor.imageUrl),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(doctor.specialty, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 5),
                      Text('(${doctor.rating} · ${doctor.totalReviews})',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
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
            _buildButtonBlue('Endereço', true),
            const SizedBox(width: 10),
            _buildButtonOutline('Teleconsulta', true),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF148A96), size: 20),
            const SizedBox(width: 10),
            Expanded(
                child:
                    Text(doctor.address, style: const TextStyle(fontSize: 14))),
          ],
        ),
        const SizedBox(height: 15),
        Text('Consulta: R\$${doctor.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF148A96),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _openBookingModal(doctor),
            child: const Text('Agendar Consulta',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Localização', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 15),
        _buildMap(doctor.lat, doctor.lng, 200),
      ],
    );
  }

  Widget _buildDesktopCard(Doctor doctor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(doctor.imageUrl),
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      Text(doctor.specialty,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.orange, size: 18),
                          const SizedBox(width: 5),
                          Text(
                              '(${doctor.rating} · ${doctor.totalReviews} avaliações)',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  _buildButtonBlue('Endereço', false),
                  const SizedBox(width: 12),
                  _buildButtonOutline('Teleconsulta', false),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF148A96)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(doctor.address,
                          style: const TextStyle(fontSize: 18))),
                ],
              ),
              const SizedBox(height: 20),
              Text('Consulta: R\$${doctor.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              SizedBox(
                width: 260,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF148A96),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _openBookingModal(doctor),
                  child: const Text('Agendar Consulta',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
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
              const Text('Localização', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 15),
              _buildMap(doctor.lat, doctor.lng, 250),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap(double lat, double lng, double height) {
    if (lat == 0 || lng == 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Localização não disponível',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
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
                  point: LatLng(lat, lng),
                  width: 50,
                  height: 50,
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 35),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonBlue(String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 15 : 20, vertical: isMobile ? 10 : 14),
      decoration: BoxDecoration(
          color: const Color(0xFF148A96),
          borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 18)),
    );
  }

  Widget _buildButtonOutline(String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 15 : 20, vertical: isMobile ? 10 : 14),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF148A96)),
          borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: TextStyle(
              color: const Color(0xFF148A96), fontSize: isMobile ? 14 : 18)),
    );
  }

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
              offset: const Offset(0, -5))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Column(
          children: [
            Center(
              child: Image.asset('assets/logo.png',
                  width: isMobile ? 150 : 200,
                  height: isMobile ? 150 : 200,
                  fit: BoxFit.contain),
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
                    height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            if (isMobile) ...[
              _buildFooterLinks('Serviços', [
                'Teleconsultas 24h',
                'Agendamento online',
                'Especialidades',
                'Exames',
                'Prontuário digital'
              ]),
              const SizedBox(height: 30),
              _buildFooterLinks('Institucional', [
                'Sobre nós',
                'Carreiras',
                'Blog',
                'Imprensa',
                'Seja parceiro'
              ]),
              const SizedBox(height: 30),
              _buildFooterLinks('Suporte', [
                'Central de ajuda',
                'FAQ',
                'Contato',
                'Termos de uso',
                'Privacidade'
              ]),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFooterLinks('Serviços', [
                    'Teleconsultas 24h',
                    'Agendamento online',
                    'Especialidades',
                    'Exames',
                    'Prontuário digital'
                  ]),
                  _buildFooterLinks('Institucional', [
                    'Sobre nós',
                    'Carreiras',
                    'Blog',
                    'Imprensa',
                    'Seja parceiro'
                  ]),
                  _buildFooterLinks('Suporte', [
                    'Central de ajuda',
                    'FAQ',
                    'Contato',
                    'Termos de uso',
                    'Privacidade'
                  ]),
                ],
              ),
            ],
            const SizedBox(height: 40),
            Divider(color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 24),
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
            Text('© 2026 Virtual Health - Todos os direitos reservados',
                style: TextStyle(
                    color: Colors.white54, fontSize: isMobile ? 10 : 12)),
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
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildFooterLinks(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  if (link == 'Contato')
                    Navigator.pushNamed(context, '/contato');
                  else if (link == 'Termos de uso')
                    Navigator.pushNamed(context, '/termos-uso');
                  else if (link == 'Privacidade')
                    Navigator.pushNamed(context, '/privacidade');
                  else if (link == 'Teleconsultas 24h')
                    Navigator.pushNamed(context, '/teleconsulta');
                  else if (link == 'Agendamento online')
                    Navigator.pushNamed(context, '/clinicas');
                },
                child: Text(link,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
              ),
            )),
      ],
    );
  }
}

// Modelo do Doutor
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int totalReviews;
  final String address;
  final double price;
  final double lat;
  final double lng;
  final String imageUrl;
  final String experience;
  final String crm;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.totalReviews,
    required this.address,
    required this.price,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.experience,
    required this.crm,
  });
}

// Widget do Modal de Agendamento
class BookingModalWidget extends StatefulWidget {
  final Doctor doctor;
  final VoidCallback onClose;
  final Function(DateTime, TimeOfDay, String) onSubmit;

  const BookingModalWidget({
    super.key,
    required this.doctor,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<BookingModalWidget> createState() => _BookingModalWidgetState();
}

class _BookingModalWidgetState extends State<BookingModalWidget> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'Presencial';
  final List<String> _types = ['Presencial', 'Teleconsulta'];

  // Usar o context do modal em vez do context global
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context:
          context, // Este é o contexto do modal, que está dentro do MaterialApp
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context, // Este é o contexto do modal
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF3FA9C6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Agendar Consulta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(widget.doctor.imageUrl),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doctor.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.doctor.specialty,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'R\$ ${widget.doctor.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF148A96),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Tipo de consulta
                    const Text(
                      'Tipo de Consulta',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _types.map((type) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(type),
                              selected: _selectedType == type,
                              onSelected: (selected) {
                                if (mounted) {
                                  setState(() => _selectedType = type);
                                }
                              },
                              backgroundColor: Colors.grey[100],
                              selectedColor:
                                  const Color(0xFF3FA9C6).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF3FA9C6),
                              labelStyle: TextStyle(
                                color: _selectedType == type
                                    ? const Color(0xFF3FA9C6)
                                    : Colors.grey[700],
                                fontWeight: _selectedType == type
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Data
                    const Text('Data',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today,
                                color: Color(0xFF3FA9C6)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Horário
                    const Text('Horário',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.access_time,
                                color: Color(0xFF3FA9C6)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onClose,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => widget.onSubmit(
                                _selectedDate, _selectedTime, _selectedType),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3FA9C6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Confirmar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
