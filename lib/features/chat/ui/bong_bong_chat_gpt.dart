import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:public_chat/const.dart';
import 'package:public_chat/features/chat/ui/public_chat_screen.dart';

import 'local_background_chat_screen.dart';

class MyPublicChatScreen extends StatefulWidget {
  const MyPublicChatScreen({super.key});

  @override
  _MyPublicChatScreenState createState() => _MyPublicChatScreenState();
}

class _MyPublicChatScreenState extends State<MyPublicChatScreen> {
  bool _isChatOpen = false;
  bool _isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const PublicChatScreen(),
        // Bong bóng chat
        Positioned(
          bottom: 50,
          right: 20,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isChatOpen = !_isChatOpen;
              });
            },
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(Icons.message, color: Colors.white),
            ),
          ),
        ),

        // Hộp chat
        if (_isChatOpen)
          Positioned(
            bottom: _isFullScreen ? 0 : 110,
            right: _isFullScreen ? 0 : 20,
            child: Container(
              width: _isFullScreen
                  ? MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width * 0.7,
              height: _isFullScreen ? MediaQuery.of(context).size.height : 300,
              decoration: BoxDecoration(
                color: _isFullScreen ? Colors.transparent : Colors.white,
                borderRadius: _isFullScreen
                    ? BorderRadius.zero
                    : BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  buildTitle(),
                  buildListView(),
                  // Nhập tin nhắn
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) {
                              final random = Random();
                              // String id = publicChatScreen +
                              //     (random.nextInt(899999) + 100000)
                              //         .toString();
                              String id = publicChatScreen +
                                  (random.nextInt(1000000)).toString();
                              firestore.collection(conversation).doc(id).set(
                                  ConversationModel(
                                          message: value,
                                          role: 'user',
                                          time: Timestamp.fromDate(
                                              DateTime.now()))
                                      .toJson());
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _isFullScreen ? Colors.white : null,
                              hintText: "Nhập tin nhắn...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildListView() {
    return Expanded(
      child: FirestoreListView<Map<String, dynamic>>(
        reverse: true,
        query: firestore
            .collection(conversation)
            .orderBy('time', descending: true),
        itemBuilder: (context, document) {
          final conversation = ConversationModel.fromJson(document.data());
          return conversation.role == 'user'
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(conversation.message),
                  ),
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(conversation.message),
                  ),
                );
        },
      ),
    );
  }

  Widget buildTitle() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: _isFullScreen
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Chat with Gemini",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                    _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isFullScreen = !_isFullScreen;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isChatOpen = false;
                    _isFullScreen = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConversationModel {
  final String message;
  final String role;
  final Timestamp time;
  ConversationModel({
    required this.message,
    required this.role,
    required this.time,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      message: json['message'] ?? '',
      role: json['role'] ?? 'user',
      time: json['time'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'role': role,
        'time': Timestamp.fromDate(DateTime.now()),
        'new_time': Timestamp.fromMicrosecondsSinceEpoch(
            time.microsecondsSinceEpoch + 1000),
      };
  Timestamp get getTime => Timestamp.fromDate(DateTime.now());
  @override
  String toString() {
    return 'ConversationModel(message: $message, role: $role, time: $time)';
  }
}
