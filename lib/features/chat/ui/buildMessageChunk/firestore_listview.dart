Widget buildMessageChunk(String id){
    FirestoreListView<ChunkData>(
                                    query: ServiceLocator.instance
                                        .get<Database>()
                                        .getMessageChunk<ChunkData>(
                                          id: 'chunk${doc.id}',
                                          fromFirestore: (snapshot, options) {
                                            final message = ChunkData.fromJson(
                                                snapshot.data() ?? {});
                                            return message;
                                          },
                                          toFirestore: (value, options) =>
                                              value.toJson(),
                                        ),
                                    itemBuilder: (BuildContext context,
                                        QueryDocumentSnapshot<ChunkData> doc) {
                                      // print('doc: ${doc.data().text}');
                                      return Text(
                                          'mytext:${doc.data().index}: ${doc.data().text}');
                                    },
                                  )
  }