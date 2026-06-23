import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/TokenProvider.dart';
import '../services/user_services.dart';
import '../theme/app_theme.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Chatscreen> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Salut 👋", "isMe": false},
    {"text": "Bienvenue dans le chat", "isMe": false},
  ];

  bool isLoading = false;

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      messages.add({"text": userMessage, "isMe": true});
      isLoading = true;
    });

    _controller.clear();

    try {
      final token = context.read<TokenProvider>().token;
      final response = await chat(token: token!, query: userMessage);

      int agentMessageIndex = messages.length;
      messages.add({
        'text': '',
        'isMe': false,
      });

      await for (final data in response) {
        setState(() {
          messages[agentMessageIndex]['text'] += data;
        });
      }
    } catch (e) {
      final errorText = e.toString();
      setState(() {
        messages.add({
          'text': 'Erreur : $errorText',
          'isMe': false,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chat error : $errorText'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text(
          "Discussion",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isMe = message["isMe"];

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.secondary : const Color(0xFF151F2C),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      border: isMe 
                          ? null 
                          : Border.all(color: Colors.white.withOpacity(0.02)),
                    ),
                    child: Text(
                      message["text"],
                      style: TextStyle(
                        color: isMe ? AppTheme.primary : Colors.white70,
                        fontSize: 15,
                        fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// Typing Indicator discret
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.secondary.withOpacity(0.6),
                  ),
                ),
              ),
            ),

          /// Input Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: const TextStyle(color: AppTheme.border, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFF151F2C),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppTheme.secondary.withOpacity(0.3), width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: isLoading ? null : sendMessage,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}