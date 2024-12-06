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
        // print('doc: ${doc.data().text}');
        // Tạo một StreamController cho từng document
        final _localCtrl = StreamController<String>();
        _localCtrl.add(doc.data().text);
        // int _localCurrChar = 0;
    
        // Hàm typewriter cho từng document
        // Future<void> _localTypeWritter(String text) async {
        //   if (_localCurrChar < text.length) {
        //     ++_localCurrChar;
        //     _localCtrl.add(text.substring(0, _localCurrChar));
        //     Future.delayed(const Duration(milliseconds: 20), () {
        //       _localTypeWritter(text);
        //     });
        //   }
        // }
    
        // // Bắt đầu hiệu ứng typewriter
        // _localTypeWritter(doc.data().text);
    
        return StreamBuilder<String>(
          stream: _localCtrl.stream,
          builder: (context, snapshot) {
            print('snapshot: ${snapshot.data}');
            return Text('mytext:${doc.data().index}: ${snapshot.data ?? ''}',
                style: const TextStyle(color: Colors.yellow));
          },
        );
      },
    );
  }