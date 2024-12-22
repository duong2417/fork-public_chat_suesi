import 'package:flutter/material.dart';
import '../../genai_setting/ui/genai_setting_screen.dart';

class ChatWithGeminiScreen extends StatefulWidget {
  const ChatWithGeminiScreen({super.key});

  @override
  State<ChatWithGeminiScreen> createState() => _ChatWithGeminiScreenState();
}

class _ChatWithGeminiScreenState extends State<ChatWithGeminiScreen> {
  bool _isChatOpen = false;
  bool _isFullScreen = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bong bóng chat
        Positioned(
          bottom: 50,
          right: 20,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isChatOpen = !_isChatOpen;
              });
            },
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(Icons.message, color: Colors.white),
            ),
          ),
        ),

        // Hộp chat
        if (_isChatOpen)
          Positioned(
            bottom: _isFullScreen ? 0 : 110,
            right: _isFullScreen ? 0 : 20,
            child: Container(
                width: _isFullScreen
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width * 0.7,
                height:
                    _isFullScreen ? MediaQuery.of(context).size.height : 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // color: _isFullScreen ? Colors.transparent : Colors.white,
                  borderRadius: _isFullScreen
                      ? BorderRadius.zero
                      : BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: GenaiSettingScreen(
                    isFullScreen: _isFullScreen,
                    isChatOpen: _isChatOpen,
                    onTapFullScreen: () {
                      setState(() {
                        _isFullScreen = !_isFullScreen;
                      });
                    },
                    onTapClose: () {
                      setState(() {
                        _isChatOpen = false;
                        _isFullScreen = false;
                      });
                    })
                // child: Column(
                //   children: [
                //     buildTitle(),
                //     const SizedBox(height: 200, child: GenaiSettingScreen()),
                //     // Nhập tin nhắn
                //     // Padding(
                //     //   padding: const EdgeInsets.all(8.0),
                //     //   child: Row(
                //     //     children: [
                //     //       Expanded(
                //     //         child: TextField(
                //     //           onSubmitted: (value) {
                //     //             context.read<ChatWithGeminiCubit>().sendMessage(
                //     //                 SendMessageEvent(
                //     //                     message: value, userID: widget.userID));
                //     //           },
                //     //           decoration: InputDecoration(
                //     //             filled: true,
                //     //             fillColor: _isFullScreen ? Colors.white : null,
                //     //             hintText: "Nhập tin nhắn...",
                //     //             border: OutlineInputBorder(
                //     //               borderRadius: BorderRadius.circular(10),
                //     //             ),
                //     //           ),
                //     //         ),
                //     //       ),
                //     //       const SizedBox(width: 8),
                //     //       IconButton(
                //     //         icon: const Icon(Icons.send, color: Colors.blue),
                //     //         onPressed: () {},
                //     //       ),
                //     //     ],
                //     //   ),
                //     // ),
                //   ],
                // ),
                ),
          ),
      ],
    );
  }

  Widget buildTitlePin() {
    return Container(
      // height: 100,
      // margin: const EdgeInsets.only(bottom: 10),
      constraints: const BoxConstraints.expand(),
      // padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.green,
        // borderRadius: _isFullScreen
        //     ? BorderRadius.zero
        //     : const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Gemini AI",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                    _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isFullScreen = !_isFullScreen;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isChatOpen = false;
                    _isFullScreen = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  // Widget buildTitle() {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: Colors.green,
  //       borderRadius: _isFullScreen
  //           ? BorderRadius.zero
  //           : const BorderRadius.vertical(top: Radius.circular(15)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         const Text(
  //           "Gemini AI",
  //           style: TextStyle(color: Colors.white, fontSize: 18),
  //         ),
  //         Row(
  //           children: [
  //             IconButton(
  //               icon: Icon(
  //                   _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
  //                   color: Colors.white),
  //               onPressed: () {
  //                 setState(() {
  //                   _isFullScreen = !_isFullScreen;
  //                 });
  //               },
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.close, color: Colors.white),
  //               onPressed: () {
  //                 setState(() {
  //                   _isChatOpen = false;
  //                   _isFullScreen = false;
  //                 });
  //               },
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:public_chat/const.dart';
// import '../../genai_setting/bloc/genai_bloc.dart';
// import '../bloc/chat_with_gemini_bloc.dart';

// class ChatWithGeminiScreen extends StatefulWidget {
//   const ChatWithGeminiScreen({super.key, required this.userID});
//   final String userID;

//   @override
//   State<ChatWithGeminiScreen> createState() => _ChatWithGeminiScreenState();
// }

// class _ChatWithGeminiScreenState extends State<ChatWithGeminiScreen> {
//   bool _isChatOpen = false;
//   bool _isFullScreen = false;
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Bong bóng chat
//         Positioned(
//           bottom: 50,
//           right: 20,
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 _isChatOpen = !_isChatOpen;
//               });
//             },
//             child: const CircleAvatar(
//               radius: 30,
//               backgroundColor: Colors.blue,
//               child: Icon(Icons.message, color: Colors.white),
//             ),
//           ),
//         ),

//         // Hộp chat
//         if (_isChatOpen)
//           Positioned(
//             bottom: _isFullScreen ? 0 : 110,
//             right: _isFullScreen ? 0 : 20,
//             child: Container(
//               width: _isFullScreen
//                   ? MediaQuery.of(context).size.width
//                   : MediaQuery.of(context).size.width * 0.7,
//               height: _isFullScreen ? MediaQuery.of(context).size.height : 300,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 // color: _isFullScreen ? Colors.transparent : Colors.white,
//                 borderRadius: _isFullScreen
//                     ? BorderRadius.zero
//                     : BorderRadius.circular(15),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   buildTitle(),
//                   buildListView(),
//                   // Nhập tin nhắn
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             onSubmitted: (value) {
//                               context.read<ChatWithGeminiCubit>().sendMessage(SendMessageEvent(message: value, userID: widget.userID));
//                             },
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: _isFullScreen ? Colors.white : null,
//                               hintText: "Nhập tin nhắn...",
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: const Icon(Icons.send, color: Colors.blue),
//                           onPressed: () {},
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget buildListView() {
//     return Expanded(
//       child: FirestoreListView<Map<String, dynamic>>(
//         reverse: true,
//         query: FirebaseFirestore.instance
//             .collection(privateChat)
//             .doc(widget.userID)
//             .collection(conversation)
//             .orderBy('time', descending: true),
//         itemBuilder: (context, document) {
//           final conversation = ConversationModel.fromJson(document.data());
//           return conversation.role == 'user'
//               ? Align(
//                   alignment: Alignment.centerRight,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     margin: const EdgeInsets.symmetric(vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[200],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(conversation.message),
//                   ),
//                 )
//               : Align(
//                   alignment: Alignment.centerLeft,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     margin: const EdgeInsets.symmetric(vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(conversation.message),
//                   ),
//                 );
//         },
//       ),
//     );
//   }

//   Widget buildTitle() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.blue,
//         borderRadius: _isFullScreen
//             ? BorderRadius.zero
//             : const BorderRadius.vertical(top: Radius.circular(15)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             "Chat with Gemini",
//             style: TextStyle(color: Colors.white, fontSize: 18),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(
//                     _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
//                     color: Colors.white),
//                 onPressed: () {
//                   setState(() {
//                     _isFullScreen = !_isFullScreen;
//                   });
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white),
//                 onPressed: () {
//                   setState(() {
//                     _isChatOpen = false;
//                     _isFullScreen = false;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
