import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:virtualhealth/medico/medico_bottom_nav_bar.dart';

class TeleconsultaPage extends StatefulWidget {
  final String consultaId;
  final String pacienteNome;
  final String pacienteId;

  const TeleconsultaPage({
    super.key,
    required this.consultaId,
    required this.pacienteNome,
    required this.pacienteId,
  });

  @override
  State<TeleconsultaPage> createState() => _TeleconsultaPageState();
}

class _TeleconsultaPageState extends State<TeleconsultaPage> {
  final JitsiMeet jitsiMeet = JitsiMeet();

  bool isLoading = false;

  Future<void> iniciarChamada() async {
    setState(() {
      isLoading = true;
    });

    try {
      final roomName = 'consulta_${widget.consultaId}';

      var options = JitsiMeetConferenceOptions(
        room: roomName,
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "subject": "Teleconsulta Médica",
        },
        featureFlags: {
          "unsaferoomwarning.enabled": false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: widget.pacienteNome,
        ),
      );

      await jitsiMeet.join(options);
    } catch (e) {
      debugPrint('Erro ao iniciar chamada: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar chamada: $e'),
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    jitsiMeet.hangUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3FA9C6),
        elevation: 0,
        title: Text(
          'Teleconsulta - ${widget.pacienteNome}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFF3FA9C6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.video_call,
                  size: 70,
                  color: Color(0xFF3FA9C6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.pacienteNome,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Consulta #${widget.consultaId}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.videocam, color: Color(0xFF3FA9C6)),
                        SizedBox(width: 8),
                        Text('Vídeo em tempo real'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.mic, color: Color(0xFF3FA9C6)),
                        SizedBox(width: 8),
                        Text('Áudio habilitado'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.lock, color: Color(0xFF3FA9C6)),
                        SizedBox(width: 8),
                        Text('Sala privada da consulta'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : iniciarChamada,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.video_call),
                  label: Text(
                    isLoading ? 'Iniciando...' : 'Iniciar Videochamada',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3FA9C6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MedicoBottomNavBar(
        currentIndex: 1,
        onProfileTap: () {
          Navigator.pushNamed(context, '/medico/perfil');
        },
      ),
    );
  }
}
