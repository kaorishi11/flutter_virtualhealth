import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ClinicasPage extends StatefulWidget {
  const ClinicasPage({super.key});

  @override
  State<ClinicasPage> createState() => _ClinicasPageState();
}

class _ClinicasPageState extends State<ClinicasPage> {

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

      // LOCALIZAÇÃO 1
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

      // LOCALIZAÇÃO 2
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

      // LOCALIZAÇÃO 3
      'lat': -23.1005,
      'lng': -45.7075,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= HEADER =================

            Stack(
              children: [

                Container(
                  height: 330,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/banner_medico.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Container(
                  height: 330,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.white.withOpacity(0.65),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 60,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      RichText(
                        text: const TextSpan(
                          children: [

                            TextSpan(
                              text: 'CONHEÇA TODAS AS\n',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0057A5),
                                height: 1,
                              ),
                            ),

                            TextSpan(
                              text: 'CLÍNICAS ',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0057A5),
                              ),
                            ),

                            TextSpan(
                              text: 'PRESENCIAIS',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const SizedBox(
                        width: 520,
                        child: Text(
                          'Encontre especialistas próximos a você e agende sua consulta.',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFF0057A5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ================= TITULO =================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Clínicas e especialistas para você',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: 520,
                    height: 3,
                    color: const Color(0xFF1194F6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ================= FILTROS =================

            Padding(
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
                          hintText:
                              'Procure clínicas ou especialistas...',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Container(
                    width: 190,
                    height: 55,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15),
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
            ),

            const SizedBox(height: 50),

            // ================= LISTA =================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: _medicos
                    .map((medico) => _buildCard(medico))
                    .toList(),
              ),
            ),

            const SizedBox(height: 50),

            // ================= FOOTER =================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 60,
                vertical: 45,
              ),
              color: const Color(0xFF148A96),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: const [

                      Text(
                        'Serviços',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        '✓ Teleconsulta 24h',
                        style: TextStyle(color: Colors.white),
                      ),

                      SizedBox(height: 12),

                      Text(
                        '✓ Agendamento online',
                        style: TextStyle(color: Colors.white),
                      ),

                      SizedBox(height: 12),

                      Text(
                        '✓ Especialidades',
                        style: TextStyle(color: Colors.white),
                      ),

                      SizedBox(height: 12),

                      Text(
                        '✓ Perguntas frequentes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: const [

                      Text(
                        'Virtual Health',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        'Seu médico virtual 24h',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: const [

                      Text(
                        'Contato',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        '📍 Endereço: Sesi Caçapava SP',
                        style: TextStyle(color: Colors.white),
                      ),

                      SizedBox(height: 12),

                      Text(
                        '📞 Telefone: (12) 9966-9732',
                        style: TextStyle(color: Colors.white),
                      ),

                      SizedBox(height: 12),

                      Text(
                        '✉️ virtualhealthassistencia@gmail.com',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================

  Widget _buildCard(Map<String, dynamic> medico) {
    return Container(
      margin: const EdgeInsets.only(bottom: 35),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= ESQUERDA =================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                        'assets/images/doctor.jpg',
                      ),
                    ),

                    const SizedBox(width: 18),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [

                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 18,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              '(${medico['avaliacao']} · ${medico['totalAvaliacoes']} avaliações)',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
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

                    _buttonBlue('Endereço'),

                    const SizedBox(width: 12),

                    _buttonOutline('Teleconsulta'),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF148A96),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        medico['endereco'],
                        style:
                            const TextStyle(fontSize: 18),
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
                      backgroundColor:
                          const Color(0xFF148A96),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
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

          // ================= MAPA INDIVIDUAL =================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  'Localização',
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),

                const SizedBox(height: 15),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(14),
                  child: SizedBox(
                    height: 250,

                    // CADA CARD TEM SEU MAPA
                    child: FlutterMap(
                      options: MapOptions(

                        // LOCALIZAÇÃO ÚNICA
                        initialCenter: LatLng(
                          medico['lat'],
                          medico['lng'],
                        ),

                        initialZoom: 15,
                      ),

                      children: [

                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                          userAgentPackageName:
                              'com.example.app',
                        ),

                        // MARCADOR INDIVIDUAL
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

  Widget _buttonBlue(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF148A96),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buttonOutline(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF148A96),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF148A96),
          fontSize: 18,
        ),
      ),
    );
  }
}