import 'package:flutter/material.dart';
import 'package:flutter_ai_chatbot/flutter_ai_chatbot.dart';

import 'home.dart';
import 'login.dart';
import 'clinicas.dart';
import 'contato.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() =>
      _ChatbotPageState();
}

class _ChatbotPageState
    extends State<ChatbotPage> {
  String _currentPage = 'Chatbot';


  final String deepseekApiKey =
      'sk-473f4e82283942a1a6f07ef37dfbc511';

  void _onPageChanged(String page) {
    if (page == 'Início') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } else if (page == 'Clínicas') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ClinicasPage(),
        ),
      );
    } else if (page == 'Contato') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ContatoPage(),
        ),
      );
    } else if (page ==
        'Fazer Consulta') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F5F9),

      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 70,
                ),

                // HEADER
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  color:
                      const Color(
                    0xFF2E7D32,
                  ),

                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Text(
                        'Assistente Virtual',
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 24,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      SizedBox(
                        height: 4,
                      ),

                      Text(
                        'Converse com nosso assistente médico',
                        style: TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // CHATBOT
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    child: Card(
                      elevation: 4,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),

                        child: ChatBotWidget(
                          // API KEY
                          apiKey:
                              deepseekApiKey,

                          // DEEPSEEK
                          aiService:
                              AIService.deepseek,

                          // APARÊNCIA
                          primaryColor:
                              const Color(
                            0xFF2E7D32,
                          ),

                          chatIcon:
                              Icons.chat,

                          headerTitle:
                              'Virtual Health AI',

                          headerIcon:
                              Icons.smart_toy,

                          clearHistoryOnClose:
                              false,

                          initialMessage:
                              '''
Olá! 👋

Sou o assistente virtual da Virtual Health.

Descreva seus sintomas ou faça perguntas médicas.

Estou aqui para ajudar 😊
''',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // NAVBAR
          Positioned(
            top: 10,
            left: 16,
            right: 16,

            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),

                boxShadow: const [
                  BoxShadow(
                    color:
                        Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,

                children: [
                  _buildNavItem(
                    Icons.home,
                    'Início',
                  ),

                  _buildNavItem(
                    Icons.chat,
                    'Chatbot',
                  ),

                  _buildNavItem(
                    Icons.local_hospital,
                    'Clínicas',
                  ),

                  _buildNavItem(
                    Icons.contact_mail,
                    'Contato',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String page,
  ) {
    final isSelected =
        _currentPage == page;

    return GestureDetector(
      onTap: () =>
          _onPageChanged(page),

      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,

            color: isSelected
                ? const Color(
                    0xFF2E7D32,
                  )
                : Colors.grey,
          ),

          Text(
            page,

            style: TextStyle(
              color: isSelected
                  ? const Color(
                      0xFF2E7D32,
                    )
                  : Colors.grey,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}