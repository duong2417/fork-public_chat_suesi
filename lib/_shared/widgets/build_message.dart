import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:public_chat/repository/database.dart';
import 'package:public_chat/service_locator/service_locator.dart';

class BuildMessage extends StatelessWidget {
  const BuildMessage({
    super.key,
    required this.message,
    required this.id,
    // required this.subscription
  });
  final String message;
  final String id;
  // final Stream<QuerySnapshot<Map<String, dynamic>>>? subscription;

  // final _ctrl = StreamController<String>();

  // int currChar = 0;

  // String allText = '...';

  // Future<void> typeWritter(String text) async {
  //   if (currChar < text.length) {
  //     ++currChar;
  //     _ctrl.add(text.substring(0, currChar));
  //     Future.delayed(const Duration(milliseconds: 20));
  //     typeWritter(text);
  //   } else {
  //     allText += '$text...';
  //   }
  // }

  Widget buildMessageChunk(String id) {
    if (message.isNotEmpty) {
      return Text(
        'MSG:$message',
        style: const TextStyle(color: Colors.green),
      );
    }
    return FirestoreListView<ChunkData>(
      query: ServiceLocator.instance
          .get<Database>()
          .getMessageChunkSubcollection<ChunkData>(
            id: id,
            fromFirestore: (snapshot, options) {
              final message = ChunkData.fromJson(snapshot.data() ?? {});
              return message;
            },
            toFirestore: (value, options) => value.toJson(),
          ),
      itemBuilder:
          (BuildContext context, QueryDocumentSnapshot<ChunkData> doc) {
        final _localCtrl = StreamController<String>();
        // print('doc: ${doc.data().text}');
        // Tạo một StreamController cho từng document
        int _localCurrChar = 0;
        // Hàm typewriter cho từng document
        Future<void> _localTypeWritter(String text) async {
          if (_localCurrChar < text.length) {
            ++_localCurrChar;
            _localCtrl.add(text.substring(0, _localCurrChar));
            await Future.delayed(const Duration(milliseconds: 60));
            _localTypeWritter(text);
          } else {
            _localCtrl.close();
          }
        }

        // Bắt đầu hiệu ứng typewriter
        _localTypeWritter(doc.data().text);
        return StreamBuilder<String>(
          stream: _localCtrl.stream,
          builder: (context, snapshot) {
            return Text(snapshot.data ?? 'Loading...',
                style: const TextStyle(color: Colors.yellow));
          },
        );
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMessageChunk(id);
  }
}

class ChunkData {
  final String text;
  final int index;
  ChunkData({required this.text, required this.index});
  factory ChunkData.fromJson(Map<String, dynamic> json) => ChunkData(
        text: json['text'],
        index: json['index'],
      );
  Map<String, dynamic> toJson() => {
        'text': text,
        'index': index,
      };
}
