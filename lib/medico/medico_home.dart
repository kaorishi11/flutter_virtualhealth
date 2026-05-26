import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicoHomePage extends StatefulWidget {
  const MedicoHomePage({super.key});

  @override
  State<MedicoHomePage> createState() =>
      _MedicoHomePageState();
}

class _MedicoHomePageState
    extends State<MedicoHomePage> {
  final supabase = Supabase.instance.client;

  int consultasHoje = 0;
  int totalPacientes = 0;
  int consultasConcluidas = 0;

  List<dynamic> consultas = [];

  String nomeMedico = 'Médico';

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      final user =
          supabase.auth.currentUser;

      if (user == null) return;

      // Perfil do médico
      final perfil = await supabase
          .from('perfis')
          .select()
          .eq('auth_id', user.id)
          .single();

      nomeMedico =
          perfil['nome_completo'] ??
              'Médico';

      // Busca profissional
      final profissional =
          await supabase
              .from('profissionais')
              .select()
              .eq(
                'perfil_id',
                perfil['id'],
              )
              .single();

      final profissionalId =
          profissional['id'];

      final hoje = DateTime.now()
          .toIso8601String()
          .split('T')[0];

      // Consultas de hoje
      final consultasHojeResponse =
          await supabase
              .from('consultas')
              .select()
              .eq(
                'profissional_id',
                profissionalId,
              )
              .eq(
                'data_agendada',
                hoje,
              );

      // Concluídas
      final concluidas =
          await supabase
              .from('consultas')
              .select()
              .eq(
                'profissional_id',
                profissionalId,
              )
              .eq(
                'status',
                'concluida',
              );

      // Lista consultas recentes
      final recentes =
          await supabase
              .from('consultas')
              .select('''
                id,
                status,
                data_agendada,
                horario_agendado,
                perfis!consultas_paciente_id_fkey(
                  nome_completo
                )
              ''')
              .eq(
                'profissional_id',
                profissionalId,
              )
              .order(
                'data_agendada',
                ascending: true,
              )
              .limit(10);

      setState(() {
        consultasHoje =
            consultasHojeResponse.length;

        consultasConcluidas =
            concluidas.length;

        totalPacientes =
            recentes.length;

        consultas = recentes;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;

      case 'concluida':
        return Colors.green;

      case 'cancelada':
        return Colors.red;

      case 'confirmada':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _drawer(),
      backgroundColor:
          const Color(0xfff5f7fa),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF3FA9C6),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 35,
            ),
            const SizedBox(width: 10),
            const Text(
              'Área Médica',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: carregarDados,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, Dr(a). $nomeMedico 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                  height: 8),

              Text(
                'Confira suas consultas de hoje.',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(
                  height: 24),

              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio:
                    1.25,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _card(
                    'Consultas Hoje',
                    consultasHoje
                        .toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                  _card(
                    'Pacientes',
                    totalPacientes
                        .toString(),
                    Icons.people,
                    Colors.teal,
                  ),
                  _card(
                    'Concluídas',
                    consultasConcluidas
                        .toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),

              const SizedBox(
                  height: 30),

              const Text(
                'Próximas consultas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                  height: 15),

              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    consultas.length,
                itemBuilder:
                    (context, index) {
                  final consulta =
                      consultas[index];

                  final paciente =
                      consulta['perfis']
                              ?[
                              'nome_completo'] ??
                          'Paciente';

                  final status =
                      consulta['status'];

                  final horario =
                      consulta[
                              'horario_agendado'] ??
                          '--:--';

                  return Card(
                    elevation: 2,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                    child: ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      title:
                          Text(paciente),
                      subtitle: Text(
                        '$horario • $status',
                      ),
                      trailing:
                          Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              12,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              statusColor(
                                  status),
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                        child: Text(
                          status,
                          style:
                              const TextStyle(
                            color: Colors
                                .white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
    String titulo,
    String valor,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Icon(
            icon,
            color: color,
            size: 38,
          ),
          Text(
            valor,
            style:
                const TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          Text(titulo),
        ],
      ),
    );
  }

  Drawer _drawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFF3FA9C6),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: const [
                Icon(
                  Icons.medical_services,
                  color:
                      Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  'Painel Médico',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const ListTile(
            leading:
                Icon(Icons.home),
            title:
                Text('Dashboard'),
          ),

          const ListTile(
            leading:
                Icon(Icons.calendar_today),
            title:
                Text('Consultas'),
          ),

          const ListTile(
            leading:
                Icon(Icons.people),
            title:
                Text('Pacientes'),
          ),

          const ListTile(
            leading:
                Icon(Icons.logout),
            title: Text('Sair'),
          ),
        ],
      ),
    );
  }
}