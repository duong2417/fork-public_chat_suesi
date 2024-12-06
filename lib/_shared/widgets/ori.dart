//   final _ctrl = StreamController<String>();
//  int currChar = 0;
//   String allText = 'ALL';
//   typeWritter(String text) {
//     if (currChar < text.length) {
//       ++currChar;
//       _ctrl.add(text.substring(0, currChar));
//       Future.delayed(const Duration(milliseconds: 20), () {
//         // typeWritter(text);
//       });
//     } else {
//       allText += text;
//       print('allText: $allText');
//     }
//   }

//    Widget buildMessage() {
//     subscription?.listen((event) {
//       String text = event.docs.map((doc) => doc.data()['text']).toList().join();
//       // for (var doc in event.docs) {
//       //   text += doc.data()['text'];
//       // }
//       print('text: $text');//5 LAN
//       typeWritter(text);
//     });
//     return StreamBuilder<Object>(
//         stream: _ctrl.stream,
//         builder: (context, snapshot) {
//           // print('snapshot.data: ${snapshot.data}');
//           if (snapshot.hasData) {
//             // final data = snapshot.data as QuerySnapshot<Map<String, dynamic>>;
//             // final chunks = data.docs.map((doc) => doc.data()['text']).toList();
//             // print('chunks: $chunks');
//             return Text(
//               // chunks.join(),
//               allText + (snapshot.data as String),
//               style: Theme.of(context)
//                   .textTheme
//                   .bodyMedium
//                   ?.copyWith(color: Colors.white),
//             );
//           }
//           return Text(
//             message,
//             style: Theme.of(context)
//                 .textTheme
//                 .bodyMedium
//                 ?.copyWith(color: Colors.white),
//           );
//         });
//   }