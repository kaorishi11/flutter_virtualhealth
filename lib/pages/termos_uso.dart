import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/auth_service.dart';

class TermosUsoPage extends StatefulWidget {
  const TermosUsoPage({super.key});

  @override
  State<TermosUsoPage> createState() => _TermosUsoPageState();
}

class _TermosUsoPageState extends State<TermosUsoPage> {
  final AuthService _auth = AuthService();
  bool _isLoggedIn = false;
  String? _userName;
  String? _userFuncao;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    if (!mounted) return;
    try {
      final isLoggedIn = _auth.isLoggedIn;
      if (isLoggedIn) {
        final profile = await _auth.getPerfilUsuario();
        if (profile != null && mounted) {
          setState(() {
            _isLoggedIn = true;
            _userProfile = profile;
            _userName = profile['nome_completo']?.split(' ')[0] ?? 'Usuário';
            _userFuncao = profile['funcao'] ?? 'paciente';
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
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _auth.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(isMobile),
            _buildContent(isMobile),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: -1,
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
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 48 : 64,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Voltar',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.gavel_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Termos de Uso',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Última atualização: 01 de junho de 2026',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 80,
        vertical: isMobile ? 24 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntroCard(isMobile),
          const SizedBox(height: 24),
          _buildSection(
            numero: '1',
            titulo: 'Aceitação dos Termos',
            icone: Icons.handshake_rounded,
            cor: const Color(0xFF1565C0),
            conteudo:
                'Ao acessar ou usar a plataforma Virtual Health, você concorda com estes Termos de Uso e com a nossa Política de Privacidade. Se você não concordar com qualquer parte destes termos, não utilize nossos serviços.\n\nEstes termos constituem um acordo legal vinculante entre você ("Usuário") e a Virtual Health ("Empresa", "nós" ou "nosso").',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '2',
            titulo: 'Descrição dos Serviços',
            icone: Icons.medical_services_rounded,
            cor: const Color(0xFF00897B),
            conteudo:
                'A Virtual Health é uma plataforma digital de saúde que oferece:\n\n• Agendamento de consultas médicas presenciais e online\n• Teleconsultas com médicos especialistas\n• Busca e catálogo de clínicas parceiras\n• Chatbot com inteligência artificial para orientações de saúde\n• Prontuário digital do paciente\n• Emissão de receitas e atestados digitais válidos\n\nOs serviços são destinados exclusivamente a maiores de 18 anos ou menores devidamente representados por responsável legal.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '3',
            titulo: 'Cadastro e Conta',
            icone: Icons.person_add_rounded,
            cor: const Color(0xFF6A1B9A),
            conteudo:
                'Para utilizar todos os recursos da plataforma, é necessário criar uma conta fornecendo informações verdadeiras, precisas e completas.\n\nVocê é responsável por:\n• Manter a confidencialidade da sua senha\n• Todas as atividades que ocorram em sua conta\n• Notificar imediatamente caso suspeite de uso não autorizado\n\nA Virtual Health reserva-se o direito de suspender ou encerrar contas que violem estes termos.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '4',
            titulo: 'Uso Adequado da Plataforma',
            icone: Icons.rule_rounded,
            cor: const Color(0xFFE65100),
            conteudo:
                'É expressamente proibido:\n\n• Usar a plataforma para fins ilegais ou fraudulentos\n• Fornecer informações médicas falsas\n• Tentar acessar dados de outros usuários\n• Reproduzir, distribuir ou modificar o conteúdo sem autorização\n• Usar a plataforma para spam ou comunicações não solicitadas\n• Realizar engenharia reversa do software\n\nO descumprimento resultará no cancelamento imediato da conta e eventuais medidas legais.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '5',
            titulo: 'Responsabilidade Médica',
            icone: Icons.health_and_safety_rounded,
            cor: const Color(0xFFC62828),
            conteudo:
                'Importante: A Virtual Health é uma plataforma de intermediação. As consultas, diagnósticos e prescrições são de responsabilidade exclusiva dos profissionais de saúde registrados.\n\nA Virtual Health não é responsável por:\n• Diagnósticos realizados pelos médicos\n• Qualidade individual do atendimento\n• Reações adversas a medicamentos prescritos\n\nEm caso de emergência médica, ligue imediatamente para o SAMU (192) ou procure a UPA/UBS mais próxima.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '6',
            titulo: 'Pagamentos e Reembolsos',
            icone: Icons.payments_rounded,
            cor: const Color(0xFF00695C),
            conteudo:
                'Os pagamentos pelos serviços são processados de forma segura. Todas as transações são criptografadas.\n\nPolítica de cancelamento:\n• Cancelamentos com mais de 24h de antecedência: reembolso total\n• Cancelamentos entre 2h e 24h: reembolso de 50%\n• Cancelamentos com menos de 2h ou não comparecimento: sem reembolso\n\nProblemas técnicos comprovados que impossibilitem a consulta darão direito a reagendamento sem custos adicionais.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '7',
            titulo: 'Propriedade Intelectual',
            icone: Icons.copyright_rounded,
            cor: const Color(0xFF283593),
            conteudo:
                'Todo o conteúdo da plataforma Virtual Health — incluindo textos, imagens, logotipos, interfaces, código-fonte e funcionalidades — é protegido por direitos autorais e leis de propriedade intelectual.\n\nÉ vedada qualquer reprodução, total ou parcial, sem autorização prévia e por escrito da Virtual Health.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '8',
            titulo: 'Alterações nos Termos',
            icone: Icons.edit_document,
            cor: const Color(0xFF4527A0),
            conteudo:
                'A Virtual Health pode atualizar estes Termos de Uso periodicamente. Alterações significativas serão notificadas por e-mail ou através de aviso na plataforma com pelo menos 15 dias de antecedência.\n\nO uso contínuo da plataforma após as alterações implica na aceitação dos novos termos.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '9',
            titulo: 'Foro e Legislação',
            icone: Icons.balance_rounded,
            cor: const Color(0xFF37474F),
            conteudo:
                'Estes Termos de Uso são regidos pelas leis da República Federativa do Brasil. Quaisquer disputas serão submetidas ao foro da comarca de Presidente Prudente - SP, com renúncia de qualquer outro, por mais privilegiado que seja.\n\nPara dúvidas sobre estes termos, entre em contato através da nossa página de contato ou pelo e-mail: suporte@virtualhealth.com.br',
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          _buildContactFooter(isMobile),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildIntroCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF1565C0), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Por favor, leia atentamente estes Termos de Uso antes de utilizar a plataforma Virtual Health. Ao se cadastrar ou usar nossos serviços, você concorda integralmente com as condições descritas abaixo.',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF1565C0),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String numero,
    required String titulo,
    required IconData icone,
    required Color cor,
    required String conteudo,
    required bool isMobile,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 6,
        ),
        childrenPadding: EdgeInsets.only(
          left: isMobile ? 16 : 24,
          right: isMobile ? 16 : 24,
          bottom: 20,
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              numero,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(icone, color: cor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                  color: const Color(0xFF1A237E),
                ),
              ),
            ),
          ],
        ),
        iconColor: cor,
        collapsedIconColor: Colors.grey,
        initiallyExpanded: numero == '1',
        children: [
          Text(
            conteudo,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Column(
        children: [
          const Icon(Icons.mail_outline_rounded,
              color: Color(0xFF1565C0), size: 32),
          const SizedBox(height: 12),
          Text(
            'Dúvidas sobre os Termos de Uso?',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entre em contato com nossa equipe jurídica pelo e-mail:\nsuporte@virtualhealth.com.br',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: const Color(0xFF1565C0).withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/contato'),
            icon: const Icon(Icons.contact_support_rounded, size: 18),
            label: const Text('Fale Conosco'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
