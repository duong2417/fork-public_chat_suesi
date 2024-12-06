import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final class Message {
  final String id;
  final String message;
  final String sender;
  final String role;
  final Timestamp timestamp;
  final Map<String, dynamic> translations;

  Message({required this.message, required this.sender})
      : id = '',
        role = 'user',
        timestamp = Timestamp.now(),
        translations = {};

  Message.fromMap(this.id, Map<String, dynamic> map)
      : message = map['message'] ?? '',
        sender = map['sender'],
        role = map['role'] ?? 'bot',
        timestamp = map['time'],
        translations = map['translated'] as Map<String, dynamic>? ?? {};

  Map<String, dynamic> toMap() =>
      {'message': message, 'sender': sender, 'role': role, 'time': timestamp, 'new_time': Timestamp.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch + 1000)};
  @override
  String toString() => toMap().toString();
  // 'Message(id: $id, message: $message, sender: $sender, timestamp: $timestamp, translations: $translations)';
}

final class UserDetail {
  final String displayName;
  final String? photoUrl;
  final String uid;

  UserDetail.fromFirebaseUser(User user)
      : displayName = user.displayName ?? 'Unknown',
        photoUrl = user.photoURL,
        uid = user.uid;

  UserDetail.fromMap(this.uid, Map<String, dynamic> map)
      : displayName = map['displayName'],
        photoUrl = map['photoUrl'];

  Map<String, dynamic> toMap() =>
      {'displayName': displayName, 'photoUrl': photoUrl};
}
