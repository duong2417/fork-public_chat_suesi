import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:public_chat/_shared/widgets/build_message.dart';

class ChatBubble extends StatelessWidget {
  final bool isMine;
  final String message;
  final String? photoUrl;
  final String? displayName;
  final Map<String, dynamic> translations;
  final String id;
  final String role;
  // final Stream<QuerySnapshot<Map<String, dynamic>>>? subscription;

  const ChatBubble({
    required this.isMine,
    required this.message,
    required this.photoUrl,
    required this.displayName,
    this.translations = const {},
    super.key,
    required this.id,
    required this.role,
    // required this.subscription
  });

  final double _iconSize = 24.0;
  @override
  Widget build(BuildContext context) {
    // user avatar
    final List<Widget> widgets = []; //cp at here
    widgets.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_iconSize),
        child: photoUrl == null
            ? const _DefaultPersonWidget()
            : ImageNetwork(
                image: photoUrl!,
                width: _iconSize,
                height: _iconSize,
                fitAndroidIos: BoxFit.fitWidth,
                fitWeb: BoxFitWeb.contain,
                onError: const _DefaultPersonWidget(),
                onLoading: const _DefaultPersonWidget()),
      ),
    ));

    // message bubble
    final messageBubble = Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            // color:Colors.blue),
            color: isMine ? Colors.black26 : Colors.black87),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // display name
            Text(
              displayName ?? 'Unknown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isMine ? Colors.black87 : Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            // original language
            if (role == 'bot')
              BuildMessage(
                  id: id,
                  message: message,
                  // subscription: subscription,
                  key: key)
            else
              Text('USER:$message', style: const TextStyle(color: Colors.white))
          ],
        ));
    widgets.add(messageBubble);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: isMine ? widgets.reversed.toList() : widgets,
      ),
    );
  }
}

class _DefaultPersonWidget extends StatelessWidget {
  const _DefaultPersonWidget();

  @override
  Widget build(BuildContext context) => const Icon(
        Icons.person,
        color: Colors.black,
        size: 20,
      );
}
