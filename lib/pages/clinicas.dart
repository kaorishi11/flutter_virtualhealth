import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
  String? _selectedAppointmentType;

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
      debugPrint('Erro ao verificar auth: $e');
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
          imageUrl: 'assets/medico.png',
          experience: '12 anos de experiência',
          crm: '123456-SP',
          consultationType: 'presencial',
          clinicName: 'Clínica Sul - Santa Casa São José dos Campos',
          clinicAddress: 'R. Clementina, Av. Assis, R. da Enseada',
          teleconsultaInfo:
              'Duração média: 30 a 50 minutos • Dados protegidos pela LGPD • Acesse pelo celular ou computador',
        ),
        Doctor(
          id: '2',
          name: 'Dr. Andrey Santos',
          specialty: 'Oftalmologista',
          rating: 4.9,
          totalReviews: 38,
          address: 'Teleconsulta',
          price: 60.00,
          lat: -23.2237,
          lng: -45.9009,
          imageUrl: 'assets/medico.png',
          experience: '8 anos de experiência',
          crm: '789012-SP',
          consultationType: 'teleconsulta',
          clinicName: 'Teleconsulta',
          clinicAddress: 'Atendimento online - Disponível 24h',
          teleconsultaInfo:
              'Duração média: 30 a 50 minutos • Dados protegidos pela LGPD • Acesse pelo celular ou computador',
        ),
        Doctor(
          id: '3',
          name: 'Dra. Sheila Costa',
          specialty: 'Ginecologista',
          rating: 4.9,
          totalReviews: 38,
          address: 'R. Cel. João Dias Guimarães - Centro, Caçapava',
          price: 60.00,
          lat: -23.1005,
          lng: -45.7075,
          imageUrl: 'assets/medico.png',
          experience: '15 anos de experiência',
          crm: '345678-SP',
          consultationType: 'presencial',
          clinicName: 'Hospital Policlinico Caçapava',
          clinicAddress: 'R. Cel. João Dias Guimarães - Centro, Caçapava',
          teleconsultaInfo:
              'Duração média: 30 a 50 minutos • Dados protegidos pela LGPD • Acesse pelo celular ou computador',
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
      debugPrint('Erro ao carregar médicos: $e');
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

  void _openBookingModal(Doctor doctor, String type) {
    final appointmentType = type.isEmpty ? 'presencial' : type;
    setState(() {
      _selectedDoctor = doctor;
      _selectedAppointmentType = appointmentType;
      _modalOpen = true;
    });
  }

  void _closeBookingModal() {
    setState(() {
      _modalOpen = false;
      _selectedDoctor = null;
      _selectedAppointmentType = null;
    });
  }

  Future<void> _submitBooking(
      DateTime date, TimeOfDay time, Map<String, dynamic>? paymentData) async {
    debugPrint('Agendando: ${_selectedDoctor?.name} - $date - $time');
    _closeBookingModal();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consulta agendada com ${_selectedDoctor?.name}!'),
          backgroundColor: const Color(0xFF14B8A6),
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
          backgroundColor: Color(0xFF14B8A6),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
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
                  backgroundColor: const Color(0xFF14B8A6),
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
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline,
                      color: Color(0xFF14B8A6)),
                  title: const Text('Editar perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/perfil');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month,
                      color: Color(0xFF14B8A6)),
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
      backgroundColor: const Color(0xFFF8FAFC),
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

              ],
            ),
          ),
          if (_modalOpen &&
              _selectedDoctor != null &&
              _selectedAppointmentType != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeBookingModal,
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: AppointmentModalWidget(
                        doctor: _selectedDoctor!,
                        appointmentType: _selectedAppointmentType!,
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
      height: isMobile ? 400 : 500,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/doutorclinica.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D2C33).withOpacity(0.85),
              const Color(0xFF0D2C33).withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 140,
            vertical: isMobile ? 20 : 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'CONHEÇA TODAS AS',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 48,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'CLÍNICAS E ESPECIALISTAS',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: isMobile ? 80 : 120,
                height: 4,
                color: const Color(0xFF14B8A6),
              ),
              const SizedBox(height: 24),
              Text(
                'Agende consultas com os melhores profissionais\nperto de você, de forma rápida e segura.',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 18,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF14B8A6).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF14B8A6), size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          number,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D2C33),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Especialistas disponíveis',
            style: TextStyle(
              fontSize: isMobile ? 24 : 36,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF0D2C33),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Para cuidar de você e da sua família',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: isMobile ? 80 : 120,
            height: 3,
            color: const Color(0xFF14B8A6),
          ),
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Busque por especialista ou especialidade...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF14B8A6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          child: CircularProgressIndicator(color: Color(0xFF14B8A6)),
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
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isMobile ? _buildMobileCard(doctor) : _buildDesktopCard(doctor),
    );
  }

  Widget _buildMobileCard(Doctor doctor) {
    String selectedType = 'presencial';

    return StatefulBuilder(
      builder: (context, setStateCard) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(doctor.imageUrl),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2C33),
                        ),
                      ),
                      Text(
                        doctor.specialty,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFF14B8A6), size: 16),
                          const SizedBox(width: 5),
                          Text(
                            '${doctor.rating} · ${doctor.totalReviews} avaliações',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
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
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setStateCard(() {
                        selectedType = 'presencial';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedType == 'presencial'
                            ? const Color(0xFF14B8A6)
                            : const Color(0xFFEDF7F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedType == 'presencial'
                              ? const Color(0xFF14B8A6)
                              : const Color(0xFF14B8A6).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: selectedType == 'presencial'
                                ? Colors.white
                                : const Color(0xFF14B8A6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Presencial',
                            style: TextStyle(
                              color: selectedType == 'presencial'
                                  ? Colors.white
                                  : const Color(0xFF14B8A6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setStateCard(() {
                        selectedType = 'teleconsulta';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedType == 'teleconsulta'
                            ? const Color(0xFF14B8A6)
                            : const Color(0xFFEDF7F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedType == 'teleconsulta'
                              ? const Color(0xFF14B8A6)
                              : const Color(0xFF14B8A6).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 16,
                            color: selectedType == 'teleconsulta'
                                ? Colors.white
                                : const Color(0xFF14B8A6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Teleconsulta',
                            style: TextStyle(
                              color: selectedType == 'teleconsulta'
                                  ? Colors.white
                                  : const Color(0xFF14B8A6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedType == 'presencial') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF14B8A6), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doctor.clinicName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D2C33),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Text(
                        doctor.clinicAddress,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Color(0xFF14B8A6), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Próximos horários: HOJE, AMANHÃ, DOMINGO, SEGUNDA',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.videocam,
                        color: Color(0xFF14B8A6), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        doctor.teleconsultaInfo,
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Valor da consulta',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    'R\$ ${doctor.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14B8A6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: () => _openBookingModal(doctor, selectedType),
                child: const Text(
                  'Agendar Consulta',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Localização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            _buildMapForDoctor(doctor, 200),
          ],
        );
      },
    );
  }

  Widget _buildDesktopCard(Doctor doctor) {
    String selectedType = 'presencial';

    return StatefulBuilder(
      builder: (context, setStateCard) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(doctor.imageUrl),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D2C33),
                            ),
                          ),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Color(0xFF14B8A6), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${doctor.rating} · ${doctor.totalReviews} avaliações',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setStateCard(() {
                              selectedType = 'presencial';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: selectedType == 'presencial'
                                  ? const Color(0xFF14B8A6)
                                  : const Color(0xFFEDF7F6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedType == 'presencial'
                                    ? const Color(0xFF14B8A6)
                                    : const Color(0xFF14B8A6).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: selectedType == 'presencial'
                                      ? Colors.white
                                      : const Color(0xFF14B8A6),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Presencial',
                                  style: TextStyle(
                                    color: selectedType == 'presencial'
                                        ? Colors.white
                                        : const Color(0xFF14B8A6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setStateCard(() {
                              selectedType = 'teleconsulta';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: selectedType == 'teleconsulta'
                                  ? const Color(0xFF14B8A6)
                                  : const Color(0xFFEDF7F6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedType == 'teleconsulta'
                                    ? const Color(0xFF14B8A6)
                                    : const Color(0xFF14B8A6).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam,
                                  color: selectedType == 'teleconsulta'
                                      ? Colors.white
                                      : const Color(0xFF14B8A6),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Teleconsulta',
                                  style: TextStyle(
                                    color: selectedType == 'teleconsulta'
                                        ? Colors.white
                                        : const Color(0xFF14B8A6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (selectedType == 'presencial') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF14B8A6)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  doctor.clinicName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0D2C33),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 36),
                            child: Text(
                              doctor.clinicAddress,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Color(0xFF14B8A6)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Próximos horários: HOJE, AMANHÃ, DOMINGO, SEGUNDA',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF7F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.videocam,
                              color: Color(0xFF14B8A6), size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              doctor.teleconsultaInfo,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valor da consulta',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          'R\$ ${doctor.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14B8A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 280,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () => _openBookingModal(doctor, selectedType),
                      child: const Text(
                        'Agendar Consulta',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Localização',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildMapForDoctor(doctor, 280),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapForDoctor(Doctor doctor, double height) {
    if (doctor.lat == 0 || doctor.lng == 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
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

    final mapController = MapController();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(doctor.lat, doctor.lng),
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
                  point: LatLng(doctor.lat, doctor.lng),
                  width: 50,
                  height: 50,
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2C33), Color(0xFF0D2C33)],
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
            Text(
              '© 2026 Virtual Health - Todos os direitos reservados',
              style: TextStyle(
                color: Colors.white54,
                fontSize: isMobile ? 10 : 12,
              ),
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
        child: Icon(icon, color: const Color(0xFF14B8A6), size: 24),
      ),
    );
  }

  Widget _buildFooterLinks(String title, List<String> links) {
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
        ),
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
                child: Text(
                  link,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            )),
      ],
    );
  }
}

// Manter as classes Doctor e AppointmentModalWidget iguais ao original
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
  final String consultationType;
  final String clinicName;
  final String clinicAddress;
  final String teleconsultaInfo;

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
    required this.consultationType,
    required this.clinicName,
    required this.clinicAddress,
    required this.teleconsultaInfo,
  });
}

// AppointmentModalWidget (manter igual ao original)
class AppointmentModalWidget extends StatefulWidget {
  final Doctor doctor;
  final String appointmentType;
  final VoidCallback onClose;
  final Function(DateTime, TimeOfDay, Map<String, dynamic>?) onSubmit;

  const AppointmentModalWidget({
    super.key,
    required this.doctor,
    required this.appointmentType,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<AppointmentModalWidget> createState() => _AppointmentModalWidgetState();
}

class _AppointmentModalWidgetState extends State<AppointmentModalWidget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _currentStep = 0;
  Map<String, dynamic>? _selectedPaymentMethod;
  bool _isProcessingPayment = false;

  final List<TimeOfDay> _availableTimes = [
    const TimeOfDay(hour: 9, minute: 30),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 13, minute: 30),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 17, minute: 0),
    const TimeOfDay(hour: 18, minute: 30),
  ];

  List<DateTime> get _availableDates {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    for (int i = 1; i <= 30; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDoctorInfo(),
                      const SizedBox(height: 24),
                      _buildStepper(),
                      const SizedBox(height: 24),
                      _buildStepContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF14B8A6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.appointmentType == 'teleconsulta'
                    ? 'Agendar Teleconsulta'
                    : 'Agendar Consulta Presencial',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.appointmentType == 'teleconsulta'
                    ? 'Duração média: 30 a 50 minutos'
                    : 'Confirme os dados para agendamento',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Row(
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
                  color: Color(0xFF14B8A6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepCircle(1, 'Data/Hora', _currentStep >= 0),
        Expanded(child: _buildStepLine(_currentStep >= 1)),
        _buildStepCircle(2, 'Confirmação', _currentStep >= 1),
        Expanded(child: _buildStepLine(_currentStep >= 2)),
        _buildStepCircle(3, 'Pagamento', _currentStep >= 2),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF14B8A6) : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF14B8A6) : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? const Color(0xFF14B8A6) : Colors.grey[300],
    );
  }

  Widget _buildStepContent() {
    if (_isProcessingPayment) {
      return _buildPaymentProcessing();
    }

    switch (_currentStep) {
      case 0:
        return _buildDateTimeStep();
      case 1:
        return _buildConfirmationStep();
      case 2:
        return _buildPaymentStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione a Data',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableDates.length,
            itemBuilder: (context, index) {
              final date = _availableDates[index];
              final isSelected = _selectedDate == date;
              final dayName = DateFormat('EEE', 'pt_BR').format(date);
              final day = date.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF14B8A6) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF14B8A6)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF14B8A6).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName.substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Selecione o Horário',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableTimes.map((time) {
            final isSelected = _selectedTime == time;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = time;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF14B8A6) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF14B8A6)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
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
                onPressed: (_selectedDate != null && _selectedTime != null)
                    ? () {
                        setState(() {
                          _currentStep = 1;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF7F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalhes da Consulta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Médico:', widget.doctor.name),
              const SizedBox(height: 12),
              _buildDetailRow('Especialidade:', widget.doctor.specialty),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Tipo:',
                  widget.appointmentType == 'teleconsulta'
                      ? 'Teleconsulta'
                      : 'Presencial'),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Data:',
                  _selectedDate != null
                      ? DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate!)
                      : '-'),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Horário:',
                  _selectedTime != null
                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                      : '-'),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Valor:', 'R\$ ${widget.doctor.price.toStringAsFixed(2)}'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Voltar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 2;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final isPresencial = widget.appointmentType == 'presencial';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Forma de Pagamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (isPresencial) ...[
          _buildPaymentOption(
            'Pagamento Presencial',
            Icons.store,
            'Pague na clínica no dia da consulta',
            value: 'presencial',
          ),
          const SizedBox(height: 12),
        ],
        _buildPaymentOption(
          'PIX',
          Icons.qr_code,
          'Pagamento instantâneo via QR Code',
          value: 'pix',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'Boleto Bancário',
          Icons.description,
          'Vencimento em 3 dias úteis',
          value: 'boleto',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'Cartão de Crédito',
          Icons.credit_card,
          'Parcelamento em até 6x sem juros',
          value: 'cartao',
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Voltar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod != null
                    ? () => _processPayment()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Pagar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String subtitle,
      {required String value}) {
    final isSelected = _selectedPaymentMethod?['value'] == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = {
            'value': value,
            'title': title,
            'subtitle': subtitle,
          };
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF14B8A6).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF14B8A6) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFF14B8A6) : Colors.grey[600],
                size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? const Color(0xFF14B8A6) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF14B8A6)),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessingPayment = false;
    });

    await _showPaymentDetailsModal();
  }

  Future<void> _showPaymentDetailsModal() async {
    final paymentMethod = _selectedPaymentMethod!['value'];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getPaymentIcon(paymentMethod),
                color: const Color(0xFF14B8A6)),
            const SizedBox(width: 12),
            Text(_getPaymentTitle(paymentMethod)),
          ],
        ),
        content: _buildPaymentDetailsContent(paymentMethod),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSubmit(
                  _selectedDate!, _selectedTime!, _selectedPaymentMethod);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF14B8A6),
            ),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsContent(String paymentMethod) {
    switch (paymentMethod) {
      case 'pix':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF7F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner,
                      size: 120, color: Colors.black),
                  const SizedBox(height: 16),
                  const Text(
                    'Escaneie o QR Code abaixo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '00020126360014BR.GOV.BCB.PIX0114+5511999999999520400005303986540.005802BR5922NOME DO RECEBEDOR6009SAO PAULO62070503***6304E2D3',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Valor: R\$ ${widget.doctor.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14B8A6)),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'boleto':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF7F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.description,
                      size: 80, color: Color(0xFF14B8A6)),
                  const SizedBox(height: 16),
                  const Text(
                    'Linha Digitável',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '34191.79008 01271.450004 10821.210008 9 72150000009000',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vencimento: 3 dias úteis',
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Baixar Boleto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'cartao':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF7F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.credit_card,
                      size: 60, color: Color(0xFF14B8A6)),
                  const SizedBox(height: 16),
                  const Text(
                    'Dados do Cartão',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Número do Cartão',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.credit_card,
                          color: Color(0xFF14B8A6)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Validade (MM/AA)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nome no Cartão',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Parcelamento',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: 1,
                    items: [1, 2, 3, 4, 5, 6].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                            '${value}x de R\$ ${(widget.doctor.price / value).toStringAsFixed(2)}'),
                      );
                    }).toList(),
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      default:
        return Container();
    }
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod) {
      case 'pix':
        return Icons.qr_code;
      case 'boleto':
        return Icons.description;
      case 'cartao':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentTitle(String paymentMethod) {
    switch (paymentMethod) {
      case 'pix':
        return 'Pagamento via PIX';
      case 'boleto':
        return 'Boleto Bancário';
      case 'cartao':
        return 'Cartão de Crédito';
      default:
        return 'Pagamento';
    }
  }

  Widget _buildPaymentProcessing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFF14B8A6)),
        const SizedBox(height: 24),
        const Text(
          'Processando pagamento...',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          'Aguarde um momento',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
