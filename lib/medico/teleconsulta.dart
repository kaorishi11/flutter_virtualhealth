import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final supabase = Supabase.instance.client;
  bool isInCall = false;
  
  // Simulação de WebRTC (você precisará implementar com um serviço real)
  // Sugestão: usar Agora.io, Jitsi Meet, ou Zoom SDK

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teleconsulta com ${widget.pacienteNome}'),
        backgroundColor: const Color(0xFF3FA9C6),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_call, size: 80, color: Color(0xFF3FA9C6)),
            const SizedBox(height: 20),
            Text(
              'Consulta ID: ${widget.consultaId}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Paciente: ${widget.pacienteNome}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isInCall = !isInCall;
                });
                // Aqui você implementaria a lógica real de videochamada
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isInCall 
                      ? 'Iniciando videochamada...' 
                      : 'Encerrando videochamada...'),
                  ),
                );
              },
              icon: Icon(isInCall ? Icons.call_end : Icons.video_call),
              label: Text(isInCall ? 'Encerrar chamada' : 'Iniciar chamada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isInCall ? Colors.red : const Color(0xFF3FA9C6),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}