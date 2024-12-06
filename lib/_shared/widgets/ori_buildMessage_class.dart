import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:public_chat/repository/database.dart';
import 'package:public_chat/service_locator/service_locator.dart';

class BuildMessage extends StatefulWidget {
  const BuildMessage(
      {super.key, required this.message, required this.subscription});
  final String message;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? subscription;

  @override
  State<BuildMessage> createState() => _BuildMessageState();
}

class _BuildMessageState extends State<BuildMessage> {
  @override
  void initState() {
    super.initState();
    if (widget.message.isEmpty) {
    String text = '';
    widget.subscription?.listen((event) async {
      // String text = event.docs.map((doc) => doc.data()['text']).toList().join();
      for (var doc in event.docs) {
        text += 'TEXT' + doc.data()['text']; //t
        // typeWritter(text);
        _ctrl.add(text);
        print('text: $text'); //5 LAN//t
      }
    });
    }
  }

  final _ctrl = StreamController<String>();
  int currChar = 0;
  String allText = '...';
  Future<void> typeWritter(String text) async {
    if (currChar < text.length) {
      ++currChar;
      _ctrl.add(text.substring(0, currChar));
      Future.delayed(const Duration(milliseconds: 20));
      typeWritter(text);
    } else {
      allText += '$text...';
    }
  }
 Widget buildMessageChunk(String id) {
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
        return Text('mytext:${doc.data().index}: ${doc.data().text}');
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (widget.message.isNotEmpty) {
      return Text(
        widget.message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white),
      );
    }
    return StreamBuilder<Object>(
        stream: widget.subscription,
        // stream:_ctrl.stream,
        builder: (context, snapshot) {
          print('snapshot.data: ${snapshot.data}');
          if (snapshot.hasData) {
            // final data = snapshot.data as QuerySnapshot<Map<String, dynamic>>;
            // final chunks = data.docs.map((doc) => doc.data()['text']).toList();
            // print('chunks: $chunks');
            return Text(
              // chunks.join(),
              (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                  .docs
                  .map((doc) => doc.data()['text'])
                  .toList()
                  .join(),
              // allText + (snapshot.data as String),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.yellow),
            );
          }
          return Text(
            widget.message.isEmpty ? 'Loading...' : widget.message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.green),
          );
        });
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
