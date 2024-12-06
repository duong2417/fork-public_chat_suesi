import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/features/chat/bloc/chat_cubit.dart';
import 'package:public_chat/repository/database.dart';
import 'package:public_chat/service_locator/service_locator.dart';
import 'package:public_chat/utils/locale_support.dart';
// import '../../../_shared/bloc/user_manager/user_manager_cubit.dart';
// import '../../../_shared/dialog/loading_dialog.dart';
import '../../../_shared/widgets/chat_bubble_widget.dart';
import '../../../_shared/widgets/message_box_widget.dart';

class PublicChatScreen extends StatelessWidget {
  const PublicChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return BlocProvider<ChatCubit>(
      create: (context) => ChatCubit(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(context.locale.publicRoomTitle),
            // actions: const [TranslateSettingsButton(), SettingsButton()],
          ),
          body: Column(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    return FirestoreListView<ChunkData>(
                      query: ServiceLocator.instance.get<Database>().getMessageChunk<ChunkData>(
                            fromFirestore: (snapshot, options) {
                              final message = ChunkData.fromJson(snapshot.data() ?? {});
                              return message;
                            },
                            toFirestore: (value, options) => value.toJson(),
                          ),
                      itemBuilder:
                          (BuildContext context, QueryDocumentSnapshot<ChunkData> doc) {
                        print('doc: ${doc.data().text}');
                        return Text('mytext: ${doc.data().text}');
                      },
                    );
                    // return FirestoreListView<Message>(
                    //     query: context.read<ChatCubit>().chatContent,
                    //     reverse: true,
                    //     showFetchingIndicator: true,
                    //     itemBuilder: (BuildContext context,
                    //         QueryDocumentSnapshot<Message> doc) {
                    //       // print(
                    //       //     'build FirestoreListView:${doc.data().toString()}');
                    //       if (!doc.exists) {
                    //         return const SizedBox.shrink();
                    //       }
                    //       final Message message = doc.data();
                    //       // return SizedBox(
                    //       //     height: 200, child: Text(message.toString()));
                    //       return BlocProvider<UserManagerCubit>.value(
                    //         value: UserManagerCubit()
                    //           ..queryUserDetail(message.sender),
                    //         child:
                    //             BlocBuilder<UserManagerCubit, UserManagerState>(
                    //           builder: (context, state) {
                    //             String? photoUrl;
                    //             String? displayName;

                    //             if (state is UserDetailState) {
                    //               photoUrl = state.photoUrl;
                    //               displayName = state.displayName;
                    //             }
                    //             return ChatBubble(
                    //                 key: UniqueKey(),
                    //                 role: message.role,
                    //                 isMine: message.role == 'user',
                    //                 // isMine: message.sender == user?.uid,
                    //                 message: message.message,
                    //                 subscription: message.role == 'bot' ? ServiceLocator.instance.get<Database>().getMessageChunkStream(doc.id) :null,
                    //                 photoUrl: photoUrl,
                    //                 displayName: displayName,
                    //                 translations: message.translations,
                    //                 id: doc.id);
                    //           },
                    //         ),
                    //       );
                    //     },
                    //     fetchingIndicatorBuilder: (context) =>
                    //         const LoadingState(),
                    //     emptyBuilder: (context) => const Center(
                    //           child: Text(
                    //               'No messages found. Send the first message now!'),
                    //         ),
                    //     loadingBuilder: (context) => const LoadingState());
                 
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MessageBox(
                    onSendMessage: (value) {
                      // if (user == null) {
                      //   // do nothing
                      //   return;
                      // }
                      final msg =
                          Message(sender: user?.uid ?? 'uid', message: value);
                      FirebaseFirestore.instance
                          .collection('public')
                          .add(msg.toMap());
                    },
                  ),
                ],
              )
            ],
          )),
    );
  }
}
