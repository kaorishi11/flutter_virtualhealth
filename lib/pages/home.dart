import 'package:flutter/material.dart';
import 'package:virtualhealth/services/auth_service.dart';

class VirtualHealthApp extends StatelessWidget {
  const VirtualHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Health',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF81C784),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TopNavigationBar(),
            const HeroSection(),
            const ServicesGrid(),
            const VirtualPlanCard(),
            const TestimonialsSection(),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Virtual Health',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _navItem('Serviços', context),
                const SizedBox(width: 24),
                _navItem('Benefícios', context),
                const SizedBox(width: 24),
                _navItem('Depoimentos', context),
              ],
            ),
          ),
          Row(
            children: [
              _navItem('Área do paciente', context),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Entrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32).withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Você escolhe suas\nconsultas e exames',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A gente escolhe cuidar de você.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Agendar consulta',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Teleconsulta online',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF81C784).withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services,
                  size: 120,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      'Agende sua Consulta',
      'Agende seus Exames',
      'Agende sua Teleconsulta',
      'Agende sua Cirurgia',
      'Agende seu Check-up',
    ];

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text(
            'Nossos Serviços',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.5,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForService(index),
                          size: 40,
                          color: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          services[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForService(int index) {
    const icons = [
      Icons.calendar_today,
      Icons.science,
      Icons.video_call,
      Icons.local_hospital,
      Icons.health_and_safety,
    ];
    return icons[index];
  }
}

class VirtualPlanCard extends StatelessWidget {
  const VirtualPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PLANO VIRTUAL HEALTH',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
  '+economia, +benefícios e +cuidado para você e sua família',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
const SizedBox(height: 16),
const Text(
  'Assine e tenha acesso a todos os benefícios exclusivos da nossa plataforma de saúde digital.',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 16,
    color: Colors.white70,
  ),
),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBenefitItem(Icons.people, 'Inclusão de até 4 pessoas, sem necessidade de vínculo familiar'),
              const SizedBox(width: 40),
              _buildBenefitItem(Icons.discount, 'Até 30% de desconto em exames laboratoriais'),
              const SizedBox(width: 40),
              _buildBenefitItem(Icons.access_time, 'Pronto atendimento online e teleconsulta 24h'),
              const SizedBox(width: 40),
              _buildBenefitItem(Icons.today, 'Agendamento para o mesmo dia pelo app ou site'),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Assinar Agora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final testimonials = [
      {
        'stars': 5,
        'text': '"Recebi um atendimento humanizado pela equipe. Me explicaram cada etapa com atenção e cuidado."',
        'name': 'Ana Paula S.',
        'date': '8 de abril de 2026',
      },
      {
        'stars': 4,
        'text': '"Fui muito bem atendida por toda a equipe desde a recepção. Recomendo a todos!"',
        'name': 'Carla M.',
        'date': '29 de março de 2026',
      },
      {
        'stars': 3,
        'text': '"Profissionais muito educados e atenciosos, sem palavras. Super recomendado o Virtual Health!"',
        'name': 'Roberto L.',
        'date': '17 de março de 2026',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.grey[50],
      child: Column(
        children: [
          const Text(
            'DEPOIMENTOS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A experiência dos nossos pacientes',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 5 ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"Recebi um atendimento humanizado pela equipe. Me explicaram cada etapa com atenção e cuidado."',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ana Paula S.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '8 de abril de 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"Fui muito bem atendida por toda a equipe desde a recepção. Recomendo a todos!"',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carla M.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '29 de março de 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 3 ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"Profissionais muito educados e atenciosos, sem palavras. Super recomendado o Virtual Health!"',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Roberto L.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '17 de março de 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Consultas a partir de R\$45,00, exames em até 10x sem juros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Começar agora →',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFF1B5E20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Virtual Health',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuidando de você e sua família',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildFooterLink('Serviços'),
                  const SizedBox(width: 32),
                  _buildFooterLink('Benefícios'),
                  const SizedBox(width: 32),
                  _buildFooterLink('Depoimentos'),
                  const SizedBox(width: 32),
                  _buildFooterLink('Contato'),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 40),
          Text(
            '© 2026 Virtual Health - Todos os direitos reservados',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}