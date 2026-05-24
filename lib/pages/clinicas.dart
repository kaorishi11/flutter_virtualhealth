import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClinicasPage extends StatefulWidget {
  const ClinicasPage({super.key});

  @override
  State<ClinicasPage> createState() => _ClinicasPageState();
}

class _ClinicasPageState extends State<ClinicasPage> {
  String _searchQuery = '';
  String _selectedEspecialidade = 'Todas';
  String _selectedLocalizacao = 'Caçapava, São Paulo - SP';
  DateTime _selectedDate = DateTime.now();
  String _selectedHorario = '';
  
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  
  final LatLng _centerLocation = const LatLng(-23.1005, -45.7075);
  
  // Controle de permissão de localização
  bool _isLocationEnabled = false;

  final List<String> _especialidades = [
    'Todas',
    'Dentista',
    'Oftalmologista',
    'Ginecologista',
    'Cardiologista',
    'Pediatra',
    'Dermatologista',
    'Ortopedista',
  ];

  final List<String> _localizacoes = [
    'Caçapava, São Paulo - SP',
    'São José dos Campos, SP',
    'Taubaté, SP',
    'Jacareí, SP',
  ];

  final List<Map<String, dynamic>> _clinicas = [
    {
      'id': 'clinica_sul',
      'nome': 'Clínica Sul - Santa Casa',
      'endereco': 'R. Cândido Gomes, 123 - Caçapava, SP',
      'cidade': 'Caçapava, São Paulo - SP',
      'telefone': '(12) 9966-9732',
      'lat': -23.1005,
      'lng': -45.7075,
      'funcionamento': 'Segunda a Sexta: 08h - 18h',
    },
    {
      'id': 'hospital_policlinico',
      'nome': 'Hospital Policlinico',
      'endereco': 'Av. Assis Chateaubriand, 500 - Caçapava, SP',
      'cidade': 'Caçapava, São Paulo - SP',
      'telefone': '(12) 3625-1234',
      'lat': -23.0980,
      'lng': -45.7100,
      'funcionamento': 'Segunda a Sábado: 07h - 22h',
    },
    {
      'id': 'agencia_saude',
      'nome': 'Agência de Saúde',
      'endereco': 'R. Vilela, 45 - Caçapava, SP',
      'cidade': 'Caçapava, São Paulo - SP',
      'telefone': '(12) 3625-5678',
      'lat': -23.1020,
      'lng': -45.7080,
      'funcionamento': 'Segunda a Sexta: 08h - 17h',
    },
    {
      'id': 'ubs_central',
      'nome': 'Unidade Básica de Saúde Central',
      'endereco': 'R. da Enseada, 89 - Caçapava, SP',
      'cidade': 'Caçapava, São Paulo - SP',
      'telefone': '(12) 3625-9012',
      'lat': -23.1040,
      'lng': -45.7060,
      'funcionamento': 'Segunda a Sexta: 07h - 19h',
    },
    {
      'id': 'hospital_sao_jose',
      'nome': 'Hospital São José',
      'endereco': 'Av. São José, 1000 - São José dos Campos, SP',
      'cidade': 'São José dos Campos, SP',
      'telefone': '(12) 3925-1000',
      'lat': -23.1890,
      'lng': -45.8850,
      'funcionamento': '24 horas',
    },
  ];

  final List<Map<String, dynamic>> _medicos = [
    {
      'nome': 'Dra Marta',
      'especialidade': 'Dentista',
      'clinica': 'Clínica Sul – Santa Casa',
      'clinicaId': 'clinica_sul',
      'preco': 90.00,
      'disponivel': true,
      'teleconsulta': true,
      'endereco': 'R. Cândido Gomes, 123 - Caçapava, SP',
      'lat': -23.1005,
      'lng': -45.7075,
      'avaliacao': 4.8,
    },
    {
      'nome': 'Dr Andrey',
      'especialidade': 'Oftalmologista',
      'clinica': 'Clínica Sul – Santa Casa',
      'clinicaId': 'clinica_sul',
      'preco': 60.00,
      'disponivel': true,
      'teleconsulta': true,
      'endereco': 'R. Cândido Gomes, 123 - Caçapava, SP',
      'lat': -23.1005,
      'lng': -45.7075,
      'avaliacao': 4.9,
    },
    {
      'nome': 'Dra Sheila',
      'especialidade': 'Ginecologista',
      'clinica': 'Hospital Policlinico',
      'clinicaId': 'hospital_policlinico',
      'preco': 60.00,
      'disponivel': false,
      'teleconsulta': true,
      'endereco': 'Av. Assis Chateaubriand, 500 - Caçapava, SP',
      'lat': -23.0980,
      'lng': -45.7100,
      'avaliacao': 4.7,
    },
    {
      'nome': 'Dr Carlos',
      'especialidade': 'Cardiologista',
      'clinica': 'Hospital São José',
      'clinicaId': 'hospital_sao_jose',
      'preco': 120.00,
      'disponivel': true,
      'teleconsulta': false,
      'endereco': 'Av. São José, 1000 - São José dos Campos, SP',
      'lat': -23.1890,
      'lng': -45.8850,
      'avaliacao': 4.9,
    },
    {
      'nome': 'Dra Ana',
      'especialidade': 'Pediatra',
      'clinica': 'Unidade Básica de Saúde Central',
      'clinicaId': 'ubs_central',
      'preco': 80.00,
      'disponivel': true,
      'teleconsulta': true,
      'endereco': 'R. da Enseada, 89 - Caçapava, SP',
      'lat': -23.1040,
      'lng': -45.7060,
      'avaliacao': 4.6,
    },
  ];

  final List<String> _horarios = [
    '08H00',
    '09H30',
    '11H00',
    '13H30',
    '15H00',
    '16H30',
  ];

  @override
  void initState() {
    super.initState();
    _adicionarMarcadores();
  }

  void _adicionarMarcadores() {
    for (var clinica in _clinicas) {
      final marker = Marker(
        markerId: MarkerId(clinica['id']),
        position: LatLng(clinica['lat'], clinica['lng']),
        infoWindow: InfoWindow(
          title: clinica['nome'],
          snippet: '${clinica['endereco']}\n${clinica['funcionamento']}',
          onTap: () {
            _mostrarInfoClinica(clinica);
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      _markers.add(marker);
    }
  }

  void _mostrarInfoClinica(Map<String, dynamic> clinica) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clinica['nome'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      clinica['endereco'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(clinica['telefone'], style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(clinica['funcionamento'], style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _animarMapaParaClinica(clinica);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ver no mapa'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _animarMapaParaClinica(Map<String, dynamic> clinica) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(clinica['lat'], clinica['lng']),
          zoom: 15,
        ),
      ),
    );
  }

  void _mostrarModalAgendamento(Map<String, dynamic> medico) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.calendar_today, color: const Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Agendar consulta com ${medico['nome']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${medico['nome']} - ${medico['especialidade']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '💰 Consulta: R\$ ${medico['preco'].toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            Text(
                              ' ${medico['avaliacao']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        if (medico['teleconsulta'] == true)
                          const Text(
                            '📱 Teleconsulta disponível',
                            style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ESCOLHA A DATA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      onDateChanged: (date) {
                        setStateDialog(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SELECIONE O HORÁRIO',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _horarios.map((horario) {
                      bool isSelected = _selectedHorario == horario;
                      return FilterChip(
                        label: Text(horario),
                        selected: isSelected,
                        onSelected: (selected) {
                          setStateDialog(() {
                            _selectedHorario = selected ? horario : '';
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF2E7D32),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Local: ${medico['endereco']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_selectedHorario.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecione um horário')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  _mostrarConfirmacaoAgendamento(medico);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarConfirmacaoAgendamento(Map<String, dynamic> medico) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 50),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Consulta agendada com sucesso!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Dr(a). ${medico['nome']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} às $_selectedHorario',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Local: ${medico['endereco']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _medicosFiltrados = _medicos.where((medico) {
      if (_selectedEspecialidade != 'Todas' &&
          medico['especialidade'] != _selectedEspecialidade) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !medico['nome'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !medico['especialidade'].toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínicas Virtual Health'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(40),
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              child: Column(
                children: [
                  const Text(
                    'CONHEÇA TODAS AS CLÍNICAS PRESENCIAIS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Encontre especialistas próximos a você e agende sua consulta.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  // Barra de busca e filtros
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Procurar clínicas ou especialistas...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _selectedEspecialidade,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: _especialidades.map((e) {
                                  return DropdownMenuItem(value: e, child: Text(e));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEspecialidade = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: _selectedLocalizacao,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: _localizacoes.map((e) {
                                  return DropdownMenuItem(value: e, child: Text(e));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLocalizacao = value!;
                                  });
                                },
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
            const SizedBox(height: 32),
            // Lista de médicos e mapa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lista de médicos
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clínicas e especialistas para você',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._medicosFiltrados.map((medico) => _buildMedicoCard(medico)),
                        if (_medicosFiltrados.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: Text('Nenhum médico encontrado'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Mapa
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 600,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _centerLocation,
                            zoom: 12,
                          ),
                          markers: _markers,
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          compassEnabled: true,
                          mapToolbarEnabled: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Serviços e contato
            Container(
              padding: const EdgeInsets.all(40),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Serviços',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      _buildServiceItem('Teleconsulta 24h'),
                      _buildServiceItem('Agendamento online'),
                      _buildServiceItem('Especialidades'),
                      _buildServiceItem('Perguntas frequentes'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Virtual Health',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text('Seu médico virtual 24h'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contato',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      _buildContactItem(Icons.location_on, 'Seis Caçapava SP'),
                      _buildContactItem(Icons.phone, '(12) 9966-9732'),
                      _buildContactItem(Icons.email, 'Virtualhealthassistencia@gmail.com'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicoCard(Map<String, dynamic> medico) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                  child: Text(
                    medico['nome'][0],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medico['nome'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        medico['especialidade'],
                        style: const TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ),
                if (medico['teleconsulta'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Teleconsulta',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  '${medico['avaliacao']}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    medico['clinica'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Consulta: R\$ ${medico['preco'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: medico['disponivel'] == true
                      ? () => _mostrarModalAgendamento(medico)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(medico['disponivel'] == true ? 'Agendar Consulta' : 'Disponível após Março'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.arrow_forward_ios, size: 12, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}