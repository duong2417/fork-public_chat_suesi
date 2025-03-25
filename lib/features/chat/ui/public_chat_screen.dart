import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_chat/_shared/bloc/user_manager/user_manager_cubit.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/_shared/widgets/chat_bubble_widget.dart';
import 'package:public_chat/_shared/widgets/message_box_widget.dart';
import 'package:public_chat/features/chat/bloc/chat_cubit.dart';
import 'package:public_chat/utils/locale_support.dart';

class PublicChatScreen extends StatefulWidget {
  const PublicChatScreen({super.key});

  @override
  State<PublicChatScreen> createState() => _PublicChatScreenState();
}

class _PublicChatScreenState extends State<PublicChatScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = MediaQuery.of(context).platformBrightness;
    final darkMode = brightness == Brightness.dark;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: darkMode ? Colors.black : Colors.white,
        systemNavigationBarDividerColor: darkMode ? Colors.black : Colors.white,
        statusBarColor: Colors.transparent, // Transparent để thích ứng tốt hơn
        statusBarBrightness:
            darkMode ? Brightness.light : Brightness.dark, // Cho iOS
        statusBarIconBrightness:
            darkMode ? Brightness.light : Brightness.dark, // Cho Android
        systemNavigationBarIconBrightness:
            darkMode ? Brightness.light : Brightness.dark,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    return BlocProvider<ChatCubit>(
      create: (context) => ChatCubit(),
      child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(context.locale.publicRoomTitle),
          ),
          body: Column(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    return FirestoreListView<Message>(
                      query: context.read<ChatCubit>().chatContent,
                      reverse: true,
                      itemBuilder: (BuildContext context,
                          QueryDocumentSnapshot<Message> doc) {
                        if (!doc.exists) {
                          return const SizedBox.shrink();
                        }

                        final Message message = doc.data();
                        final query = context.read<ChatCubit>().chatContent;

                        return FutureBuilder<Position>(
                            future: _determineMessagePositionFromFirestore(
                              currentMessage: message,
                              query: query,
                              currentDoc: doc,
                            ),
                            builder: (context, snapshot) {
                              return BlocProvider<UserManagerCubit>.value(
                                value: UserManagerCubit()
                                  ..queryUserDetail(message.sender),
                                child: BlocBuilder<UserManagerCubit,
                                    UserManagerState>(
                                  builder: (context, state) {
                                    String? photoUrl;
                                    String? displayName;

                                    if (state is UserDetailState) {
                                      photoUrl = state.photoUrl;
                                      displayName = state.displayName;
                                    }

                                    return ChatBubble(
                                        position:
                                            snapshot.data ?? Position.middle,
                                        isMine: message.sender == user?.uid,
                                        message: message.message,
                                        photoUrl: photoUrl,
                                        displayName: displayName,
                                        translations: message.translations);
                                  },
                                ),
                              );
                            });
                      },
                      emptyBuilder: (context) => const Center(
                        child: Text(
                            'No messages found. Send the first message now!'),
                      ),
                      loadingBuilder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
              MessageBox(
                onSendMessage: (value) {
                  if (user == null) {
                    // do nothing
                    return;
                  }
                  FirebaseFirestore.instance
                      .collection('public')
                      .add(Message(sender: user.uid, message: value).toMap());
                },
              )
            ],
          )),
    );
  }

  Future<Position> _determineMessagePositionFromFirestore({
    required Message currentMessage,
    required Query<Message> query,
    required QueryDocumentSnapshot<Message> currentDoc,
  }) async {
    // Lấy tin nhắn trước
    final beforeQuery = query.endBefore([currentDoc]).limitToLast(1);

    // Lấy tin nhắn sau
    final afterQuery = query.startAfter([currentDoc]).limit(1);

    final beforeDocs = await beforeQuery.get();
    final afterDocs = await afterQuery.get();

    final hasBefore = beforeDocs.docs.isNotEmpty;
    final hasAfter = afterDocs.docs.isNotEmpty;

    final beforeMessage = hasBefore ? beforeDocs.docs.first.data() : null;
    final afterMessage = hasAfter ? afterDocs.docs.first.data() : null;

    // Nếu không có tin nhắn trước và sau
    if (!hasBefore && !hasAfter) return Position.single;

    // Nếu là tin nhắn đầu tiên của chuỗi
    if (!hasBefore || beforeMessage?.sender != currentMessage.sender) {
      return Position.first;
    }

    // Nếu là tin nhắn cuối cùng của chuỗi
    if (!hasAfter || afterMessage?.sender != currentMessage.sender) {
      return Position.last;
    }

    // Nếu là tin nhắn ở giữa
    return Position.middle;
  }
}
