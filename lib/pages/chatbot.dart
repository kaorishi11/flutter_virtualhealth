import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
import 'login.dart';
import 'clinicas.dart';
import 'contato.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  String _currentPage = 'Chatbot';

  final TextEditingController _controller =
      TextEditingController();

  final List<Map<String, dynamic>> messages = [];

  bool isLoading = false;

  // SUA NOVA KEY DO GROQ
  final String groqApiKey =
      'COLE_SUA_NOVA_KEY_AQUI';

  @override
  void initState() {
    super.initState();

    messages.add({
      'role': 'assistant',
      'text':
          'Olá! 👋\n\nSou o assistente virtual da Virtual Health.\n\nDescreva seus sintomas ou faça perguntas médicas 😊',
    });
  }

  Future<void> sendMessage() async {
    String userMessage =
        _controller.text.trim();

    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({
        'role': 'user',
        'text': userMessage,
      });

      isLoading = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(
          'https://api.groq.com/openai/v1/chat/completions',
        ),
        headers: {
          'Authorization':
              'Bearer $groqApiKey',
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "Você é um assistente médico virtual da Virtual Health. Nunca dê diagnóstico definitivo e recomende procurar um médico quando necessário."
            },
            {
              "role": "user",
              "content": userMessage
            }
          ]
        }),
      );

      final data =
          jsonDecode(response.body);

      String botResponse =
          data['choices'][0]['message']
              ['content'];

      setState(() {
        messages.add({
          'role': 'assistant',
          'text': botResponse,
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'assistant',
          'text':
              'Erro ao conectar ao assistente.',
        });
      });
    }

    setState(() {
      isLoading = false;
    });
  }

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
                      SizedBox(height: 4),
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

                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            ListView.builder(
                          padding:
                              const EdgeInsets
                                  .all(16),
                          itemCount:
                              messages.length,
                          itemBuilder:
                              (context,
                                  index) {
                            final msg =
                                messages[
                                    index];

                            bool isUser =
                                msg['role'] ==
                                    'user';

                            return Align(
                              alignment: isUser
                                  ? Alignment
                                      .centerRight
                                  : Alignment
                                      .centerLeft,
                              child:
                                  Container(
                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 10,
                                ),
                                padding:
                                    const EdgeInsets
                                        .all(
                                  14,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: isUser
                                      ? const Color(
                                          0xFF2E7D32)
                                      : Colors
                                          .white,
                                  borderRadius:
                                      BorderRadius.circular(
                                          16),
                                ),
                                child: Text(
                                  msg['text'],
                                  style:
                                      TextStyle(
                                    color: isUser
                                        ? Colors
                                            .white
                                        : Colors
                                            .black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      if (isLoading)
                        const Padding(
                          padding:
                              EdgeInsets.all(
                                  10),
                          child:
                              CircularProgressIndicator(),
                        ),

                      Padding(
                        padding:
                            const EdgeInsets
                                .all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  TextField(
                                controller:
                                    _controller,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Digite sua mensagem...',
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            16),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                width: 10),

                            IconButton(
                              onPressed:
                                  sendMessage,
                              icon:
                                  const Icon(
                                Icons.send,
                                color: Color(
                                    0xFF2E7D32),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
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