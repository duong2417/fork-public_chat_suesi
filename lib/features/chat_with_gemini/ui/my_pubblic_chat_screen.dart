import 'package:flutter/material.dart';
import 'package:public_chat/features/chat/ui/public_chat_screen.dart';
import 'chat_with_gemini_bubble.dart';

class MyPublicChatScreen extends StatefulWidget {
  const MyPublicChatScreen({super.key});

  @override
  _MyPublicChatScreenState createState() => _MyPublicChatScreenState();
}

class _MyPublicChatScreenState extends State<MyPublicChatScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          PublicChatScreen(),
          ChatWithGeminiBubble(),
        ],
      ),
    );
  }
}
