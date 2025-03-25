import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:public_chat/_shared/bloc/user_manager/user_manager_cubit.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/_shared/widgets/chat_bubble_widget.dart';
import 'package:public_chat/_shared/widgets/message_box_widget.dart';
import 'package:public_chat/data.dart';
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
                    final _msg = messages.reversed.toList();
                    return ListView.builder(
                      reverse: true,
                      itemCount: _msg.length,
                      padding: const EdgeInsets.only(bottom: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final position =
                            determineMessagePosition(index, messages);
                        double topPadding = position == Position.first ? 10 : 0;
                        double bottomPadding =
                            position == Position.last ? 10 : 0;
                        return Padding(
                          padding: EdgeInsets.only(
                              top: topPadding, bottom: bottomPadding),
                          child: ChatBubble(
                            position: position,
                            isMine: messages[index].isMe,
                            message: messages[index].message,
                            photoUrl: null,
                            displayName: messages[index].sender,
                            translations: messages[index].translations,
                          ),
                        );
                      },
                    );
                    // return FirestoreListView<Message>(
                    //   query: context.read<ChatCubit>().chatContent,
                    //   reverse: true,
                    //   itemBuilder: (BuildContext context,
                    //       QueryDocumentSnapshot<Message> doc) {
                    //     if (!doc.exists) {
                    //       return const SizedBox.shrink();
                    //     }

                    //     final Message message = doc.data();

                    //     return BlocProvider<UserManagerCubit>.value(
                    //       value: UserManagerCubit()
                    //         ..queryUserDetail(message.sender),
                    //       child:
                    //           BlocBuilder<UserManagerCubit, UserManagerState>(
                    //         builder: (context, state) {
                    //           String? photoUrl;
                    //           String? displayName;

                    //           if (state is UserDetailState) {
                    //             photoUrl = state.photoUrl;
                    //             displayName = state.displayName;
                    //           }

                    //           return ChatBubble(
                    //               isMine: message.sender == user?.uid,
                    //               message: message.message,
                    //               photoUrl: photoUrl,
                    //               displayName: displayName,
                    //               translations: message.translations);
                    //         },
                    //       ),
                    //     );
                    //   },
                    //   emptyBuilder: (context) => const Center(
                    //     child: Text(
                    //         'No messages found. Send the first message now!'),
                    //   ),
                    //   loadingBuilder: (context) => const Center(
                    //     child: CircularProgressIndicator(),
                    //   ),
                    // );
                  },
                ),
              ),
              MessageBox(
                onSendMessage: (value) {
                  if (user == null) {
                    // do nothing
                    return;
                  }
                  FirebaseFirestore.instance.collection('public').add(
                      Message(sender: user.uid, message: value, isMe: true)
                          .toMap());
                },
              )
            ],
          )),
    );
  }

  Position determineMessagePosition(int index, List<Message> messages) {
    if (index == 0) return Position.last;
    if (index == messages.length - 1) return Position.first;
    if (messages[index].isMe != messages[index + 1].isMe) return Position.first;
    if (messages[index - 1].isMe != messages[index].isMe) return Position.last;
    return Position.middle;
  }
}
