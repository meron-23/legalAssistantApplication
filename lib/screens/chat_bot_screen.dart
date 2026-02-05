import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  // Replace with your actual Gemini API key
  static const String _apiKey = 'AIzaSyDKwDbo0u4DPHXG5qtQFuiWzRolZsJ_SLM';
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are a Federal Court Assistant. Your goal is to help citizens understand '
        'court procedures, case status meanings, and how to find public records. '
        'You must NOT provide legal advice. Always include a disclaimer that you are '
        'not a lawyer and this is not legal advice. Be formal, helpful, and concise.',
      ),
    );
    _chat = _model.startChat();
  }

  void _sendMessage() async {
    final text = _messageController.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messageController.clear();
      _isTyping = true;
    });

    try {
      final response = await _chat.sendMessage(Content.text(text));
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': response.text ?? 'No response.',
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'Error: $e'});
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Assistant Bot')),
      body: Column(
        children: [
          _buildDisclaimer(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(msg['text']!),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Bot is typing...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      color: Colors.amber[50],
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, size: 20, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Disclaimer: This AI chatbot provides general procedure info and is NOT a substitute for legal advice.',
              style: TextStyle(fontSize: 11, color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Ask about procedures...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
