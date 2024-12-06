Widget buildMessageChunk(String id) {
    print('id: $id');
    final _chunkRef = dbInstance.ref('chunk$id');
    // _chunkRef.push();
    // _chunkRef.set('test');
    dbInstance.ref('id').set('test2');
    return StreamBuilder<DatabaseEvent>(
      stream: _chunkRef.onValue,
      builder: (context, snapshot) {
        print('snapshot:${snapshot.data?.snapshot.value}');
        return Text('mytext:${snapshot.data?.snapshot.value ?? 'Loading...'}');
      },
    );
  }