import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_network/image_network.dart';

import '../../utils/global.dart';

class ChatBubble extends StatelessWidget {
  final bool isMine;
  final String message;
  final String? photoUrl;
  final String? displayName;
  final Map<String, dynamic> translations;
  final String id;

  const ChatBubble(
      {required this.isMine,
      required this.message,
      required this.photoUrl,
      required this.displayName,
      this.translations = const {},
      super.key,
      required this.id});

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
    widgets.add(Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
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
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white),
          ),
          if (translations.isNotEmpty &&
              translations.containsKey(Global.localLanguageCode) &&
              translations[Global.localLanguageCode] != null)
            if (kDebugMode)
              buildTranslation(context: context, isMine: isMine)
            else if (!isMine) //in production mode, only show translation for other users, not mine
              buildTranslation(context: context, isMine: isMine)
        ],
      ),
    ));
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

  Widget buildTranslation(
      {required BuildContext context, required bool isMine}) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(
            text: '${Global.localLanguageCode} ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isMine ? Colors.black87 : Colors.grey)),
        TextSpan(
          text:
              translations[Global.localLanguageCode] ?? 'translation not found',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: isMine ? Colors.black87 : Colors.grey),
        )
      ]),
      textAlign: isMine ? TextAlign.right : TextAlign.left,
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
