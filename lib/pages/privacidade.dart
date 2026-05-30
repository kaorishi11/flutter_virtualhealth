import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/auth_service.dart';

class PrivacidadePage extends StatefulWidget {
  const PrivacidadePage({super.key});

  @override
  State<PrivacidadePage> createState() => _PrivacidadePageState();
}

class _PrivacidadePageState extends State<PrivacidadePage> {
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
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
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
                child: const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Política de Privacidade',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 38,
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
          _buildLGPDBadge(isMobile),
          const SizedBox(height: 24),
          _buildSection(
            numero: '1',
            titulo: 'Quem Somos',
            icone: Icons.business_rounded,
            cor: const Color(0xFF2E7D32),
            conteudo:
                'A Virtual Health é uma plataforma digital de saúde que conecta pacientes a profissionais de saúde e clínicas parceiras. Somos responsáveis pelo tratamento dos seus dados pessoais conforme definido nesta Política de Privacidade.\n\nSomos comprometidos com a transparência e a proteção de seus dados, em conformidade com a Lei Geral de Proteção de Dados (LGPD — Lei nº 13.709/2018).',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '2',
            titulo: 'Dados que Coletamos',
            icone: Icons.data_usage_rounded,
            cor: const Color(0xFF1565C0),
            conteudo:
                'Coletamos os seguintes tipos de dados:\n\n📋 Dados de Cadastro:\n• Nome completo, e-mail, CPF e data de nascimento\n• Telefone e endereço\n• Informações de login e senha (criptografada)\n\n🏥 Dados de Saúde:\n• Histórico de consultas e prontuários\n• Receitas e atestados emitidos\n• Informações fornecidas durante as consultas\n\n📱 Dados de Uso:\n• Endereço IP e dispositivo de acesso\n• Logs de acesso e navegação na plataforma\n• Preferências e configurações do usuário',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '3',
            titulo: 'Como Usamos seus Dados',
            icone: Icons.settings_rounded,
            cor: const Color(0xFF6A1B9A),
            conteudo:
                'Utilizamos seus dados exclusivamente para:\n\n• Prestação dos serviços contratados\n• Identificação e autenticação do usuário\n• Agendamento e realização de consultas\n• Geração de prontuários e documentos médicos\n• Comunicações sobre seus atendimentos\n• Melhoria contínua dos nossos serviços\n• Cumprimento de obrigações legais e regulatórias\n\nNão vendemos, compartilhamos ou alugamos seus dados pessoais para terceiros sem seu consentimento.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '4',
            titulo: 'Base Legal para Tratamento',
            icone: Icons.balance_rounded,
            cor: const Color(0xFFE65100),
            conteudo:
                'Tratamos seus dados com base nas seguintes hipóteses legais da LGPD:\n\n• Consentimento (Art. 7º, I): Para e-mails de marketing e comunicações opcionais\n• Execução de contrato (Art. 7º, V): Para prestação dos serviços contratados\n• Cumprimento de obrigação legal (Art. 7º, II): Para retenção de registros médicos exigidos por lei\n• Legítimo interesse (Art. 7º, IX): Para melhoria dos serviços e segurança da plataforma\n• Tutela da saúde (Art. 11, II, f): Para dados sensíveis de saúde',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '5',
            titulo: 'Compartilhamento de Dados',
            icone: Icons.share_rounded,
            cor: const Color(0xFFC62828),
            conteudo:
                'Seus dados podem ser compartilhados apenas com:\n\n🩺 Profissionais de saúde: Para realização das consultas agendadas\n🏥 Clínicas parceiras: Apenas dados necessários para o atendimento\n☁️ Provedores de tecnologia: Supabase (banco de dados), hospedagem em nuvem segura\n⚖️ Autoridades competentes: Quando exigido por lei ou ordem judicial\n\nTodos os nossos parceiros seguem padrões de segurança e privacidade equivalentes aos nossos.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '6',
            titulo: 'Segurança dos Dados',
            icone: Icons.lock_rounded,
            cor: const Color(0xFF00695C),
            conteudo:
                'Implementamos medidas técnicas e organizacionais robustas para proteger seus dados:\n\n🔐 Criptografia de ponta a ponta em todas as comunicações (SSL/TLS)\n🔑 Senhas armazenadas com hash seguro (bcrypt)\n🛡️ Autenticação via tokens JWT com expiração automática\n📊 Monitoramento contínuo de acessos suspeitos\n🔒 Controle de acesso baseado em funções (RBAC)\n💾 Backups regulares e seguros dos dados\n\nEm caso de violação de dados, você será notificado em até 72 horas, conforme exige a LGPD.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '7',
            titulo: 'Seus Direitos (LGPD)',
            icone: Icons.verified_user_rounded,
            cor: const Color(0xFF283593),
            conteudo:
                'Conforme a LGPD, você possui os seguintes direitos:\n\n✅ Confirmação: Saber se tratamos seus dados\n📋 Acesso: Obter cópia dos dados que mantemos sobre você\n✏️ Correção: Solicitar correção de dados incompletos ou incorretos\n🗑️ Eliminação: Solicitar exclusão dos seus dados (sujeito a exceções legais)\n📤 Portabilidade: Receber seus dados em formato estruturado\n🚫 Oposição: Opor-se ao tratamento baseado em legítimo interesse\n⏸️ Limitação: Solicitar limitação do tratamento em determinadas situações\n\nPara exercer seus direitos, entre em contato: privacidade@virtualhealth.com.br',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '8',
            titulo: 'Retenção de Dados',
            icone: Icons.schedule_rounded,
            cor: const Color(0xFF4527A0),
            conteudo:
                'Mantemos seus dados pelos seguintes períodos:\n\n• Dados de conta ativa: Enquanto sua conta estiver ativa\n• Prontuários médicos: 20 anos após a última consulta (obrigação legal - CFM)\n• Dados de faturamento: 5 anos (obrigação fiscal)\n• Logs de acesso: 6 meses\n• Dados de marketing: Até você retirar o consentimento\n\nApós os períodos de retenção, os dados são eliminados de forma segura.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '9',
            titulo: 'Cookies e Rastreamento',
            icone: Icons.cookie_rounded,
            cor: const Color(0xFF37474F),
            conteudo:
                'Utilizamos cookies e tecnologias similares para:\n\n🔐 Cookies essenciais: Necessários para o funcionamento da plataforma (não podem ser desativados)\n📊 Cookies analíticos: Para entender como você usa nossa plataforma (podem ser desativados)\n🎯 Cookies de preferências: Para lembrar suas configurações\n\nVocê pode gerenciar cookies nas configurações do seu navegador. Desativar cookies essenciais pode impedir o funcionamento adequado da plataforma.',
            isMobile: isMobile,
          ),
          _buildSection(
            numero: '10',
            titulo: 'Contato e DPO',
            icone: Icons.contact_mail_rounded,
            cor: const Color(0xFF00838F),
            conteudo:
                'Nossa Encarregada de Proteção de Dados (DPO) está disponível para suas dúvidas:\n\n📧 E-mail: privacidade@virtualhealth.com.br\n📞 Telefone: (18) 3000-0000\n⏰ Horário: Segunda a sexta, das 8h às 18h\n\nVocê também pode registrar reclamações junto à Autoridade Nacional de Proteção de Dados (ANPD): www.gov.br/anpd',
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          _buildLGPDCommitment(isMobile),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLGPDBadge(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'LGPD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Esta política está em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018) e demais normas aplicáveis.',
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: const Color(0xFF1B5E20),
                height: 1.4,
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

  Widget _buildLGPDCommitment(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_rounded,
              color: Color(0xFF2E7D32), size: 36),
          const SizedBox(height: 12),
          Text(
            'Nosso Compromisso com sua Privacidade',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Na Virtual Health, sua privacidade não é apenas uma obrigação legal — é um valor central da nossa missão. Tratamos seus dados com o máximo respeito, transparência e segurança.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: const Color(0xFF2E7D32).withOpacity(0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/contato'),
            icon: const Icon(Icons.contact_support_rounded, size: 18),
            label: const Text('Fale com nosso DPO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
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
