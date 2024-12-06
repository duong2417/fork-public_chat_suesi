import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:public_chat/_shared/data/chat_data.dart';

final class Database {
  static Database? _instance;

  Database._();

  static Database get instance {
    _instance ??= Database._();
    return _instance!;
  }

  final String _publicRoom = 'public';
  final String _userList = 'users';
  void writePublicMessage(Message message) {
    FirebaseFirestore.instance.collection(_publicRoom).add(message.toMap());
  }

  Query<T> getPublicChatContents<T>({
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  }) {
    return FirebaseFirestore.instance
        .collection(_publicRoom)
        .orderBy('time', descending: true)
        .withConverter(fromFirestore: fromFirestore, toFirestore: toFirestore);
  }

  Query<T> getMessageChunkFromNew<T>({
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
    // required String id,
  }) {
    return FirebaseFirestore.instance
        .collection("new")
        // .orderBy('index')
        .withConverter(fromFirestore: fromFirestore, toFirestore: toFirestore);
  }

  Query<T> getMessageChunk<T>({
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
    required String id,
  }) {
    return FirebaseFirestore.instance
        .collection(id)
        // .orderBy('index')
        .withConverter(fromFirestore: fromFirestore, toFirestore: toFirestore);
  }

  Query<T> getMessageChunkSubcollection<T>({
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
    required String id,
  }) {
    return FirebaseFirestore.instance
        .collection(_publicRoom)
        .doc(id)
        .collection('message_chunk')
        .orderBy('index')
        .withConverter(fromFirestore: fromFirestore, toFirestore: toFirestore);
  }

  void saveUser(User user) {
    final UserDetail userDetail = UserDetail.fromFirebaseUser(user);
    FirebaseFirestore.instance
        .collection(_userList)
        .doc(user.uid)
        .set(userDetail.toMap(), SetOptions(merge: true));
  }

  Future<DocumentSnapshot<UserDetail>> getUser(String uid) {
    return FirebaseFirestore.instance
        .collection(_userList)
        .doc(uid)
        .withConverter(
            fromFirestore: _userDetailFromFirestore,
            toFirestore: _userDetailToFirestore)
        .get(const GetOptions(source: Source.serverAndCache));
  }

  Stream<QuerySnapshot<UserDetail>> getUserStream() {
    return FirebaseFirestore.instance
        .collection(_userList)
        .withConverter(
            fromFirestore: _userDetailFromFirestore,
            toFirestore: _userDetailToFirestore)
        .snapshots();
  }

  // Stream<QuerySnapshot<Map<String, dynamic>>> getMessageChunkStream(
  //     String messageId) {
  //   return FirebaseFirestore.instance
  //       .collection(_publicRoom)
  //       .doc(messageId)
  //       .collection('message_chunk')
  //       .orderBy('index')
  //       .snapshots();
  // }
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessageChunkStream(
      String messageId) {
    return FirebaseFirestore.instance
        .collection(messageId)
        .orderBy('index')
        .snapshots();
  }

  /// ###############################################################
  /// fromFirestore and toFirestore
  UserDetail _userDetailFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) =>
      UserDetail.fromMap(snapshot.id, snapshot.data() ?? {});
  Map<String, Object?> _userDetailToFirestore(
    UserDetail value,
    SetOptions? options,
  ) =>
      value.toMap();
}
