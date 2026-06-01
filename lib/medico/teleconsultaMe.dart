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

  // ==================== PALETA DE CORES VIRTUAL HEALTH ====================
  static const Color primaryTeal = Color(0xFF14B8A6);      // Primary
  static const Color deepOcean = Color(0xFF0D2C33);        // Deep Ocean
  static const Color actionTeal = Color(0xFF0F766E);       // Action Teal
  static const Color backgroundWhite = Color(0xFFF8FAFC);  // Background
  static const Color cardWhite = Color(0xFFFFFFFF);        // Card / Surface
  static const Color secondaryTealSoft = Color(0xFFEDF7F6); // Secondary
  static const Color mutedText = Color(0xFF6B7280);        // Muted
  static const Color borderLight = Color(0x3314B8A6);      // Teal claro 20%
  // ========================================================================

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
          "subject": "Teleconsulta Médica - ${widget.pacienteNome}",
          "ios.switchKit.enabled": true,
          "prejoinPageEnabled": false,
          "meetingPasswordEnabled": false,
          "toolbox.alwaysVisible": false,
          "branding.image": "https://virtualhealth.com.br/logo.png",
        },
        featureFlags: {
          "unsaferoomwarning.enabled": false,
          "invite.enabled": false,
          "welcomepage.enabled": false,
          "chat.enabled": true,
          "livestreaming.enabled": false,
          "calendar.enabled": false,
          "closecaptions.enabled": false,
          "help.enabled": false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: widget.pacienteNome,
          email: "paciente@virtualhealth.com.br",
          avatar: "https://ui-avatars.com/api/?background=14B8A6&color=fff&name=${widget.pacienteNome.replaceAll(' ', '+')}",
        ),
      );

      await jitsiMeet.join(options);
    } catch (e) {
      debugPrint('Erro ao iniciar chamada: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar chamada: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: primaryTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    jitsiMeet.hangUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'TELEMEDICINA',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: deepOcean,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildAvatarSection(),
                const SizedBox(height: 24),
                _buildPatientInfo(),
                const SizedBox(height: 32),
                _buildFeaturesCard(),
                const SizedBox(height: 40),
                _buildStartButton(),
              ],
            ),
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

  Widget _buildAvatarSection() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryTeal, actionTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryTeal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: primaryTeal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Column(
      children: [
        Text(
          widget.pacienteNome,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: deepOcean,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: secondaryTealSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Consulta #${widget.consultaId}',
            style: TextStyle(
              color: primaryTeal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 14, color: mutedText),
            const SizedBox(width: 4),
            Text(
              'Em tempo real • Seguro • Privado',
              style: TextStyle(fontSize: 12, color: mutedText),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.videocam,
            title: 'Vídeo em tempo real',
            subtitle: 'Alta qualidade e baixa latência',
          ),
          const SizedBox(height: 16),
          Divider(color: borderLight, height: 1),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.mic,
            title: 'Áudio habilitado',
            subtitle: 'Microfone ativo para comunicação',
          ),
          const SizedBox(height: 16),
          Divider(color: borderLight, height: 1),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.lock,
            title: 'Sala privada',
            subtitle: 'Sala exclusiva e segura para sua consulta',
          ),
          const SizedBox(height: 16),
          Divider(color: borderLight, height: 1),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.chat,
            title: 'Chat integrado',
            subtitle: 'Compartilhe mensagens durante a consulta',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: secondaryTealSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: primaryTeal, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: deepOcean,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : iniciarChamada,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withOpacity(0.2);
              }
              return null;
            },
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(Icons.video_call, size: 22),
            const SizedBox(width: 10),
            Text(
              isLoading ? 'INICIANDO...' : 'INICIAR VIDEOCHAMADA',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}