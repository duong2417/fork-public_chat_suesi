import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:public_chat/themes/base/extension.dart';

import '../../utils/global.dart';

enum Position {
  first,
  last,
  middle,
  single,
}

class ChatBubble extends StatelessWidget {
  final bool isMine;
  final String message;
  final String? photoUrl;
  final String? displayName;
  final Map<String, dynamic> translations;
  final Position position;

  final double _iconSize = 24.0;

  const ChatBubble(
      {required this.isMine,
      required this.message,
      required this.photoUrl,
      required this.displayName,
      this.translations = const {},
      this.position = Position.middle,
      super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    final colorScheme = context.myColorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // user avatar
    if (!isMine) {
      if (position == Position.last) {
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
      } else {
        widgets.add(const SizedBox(width: 40));
      }
    }

    // message bubble
    widgets.add(Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: boTopLeft(),
              topRight: boTopRight(),
              bottomLeft: boBottomLeft(),
              bottomRight: boBottomRight()),
          color: isMine
              ? colorScheme.messageMeColor
              : colorScheme.messageOtherColor),
      padding: const EdgeInsets.all(10.0),
      margin: EdgeInsets.only(right: isMine ? 6 : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // original language
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: (isDarkMode || isMine) ? Colors.white : Colors.black),
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
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // display name if it's the first message
          if (position == Position.first && !isMine)
            Padding(
              padding: EdgeInsets.only(
                  bottom: 4, left: isMine ? 0 : 42, right: isMine ? 6 : 0),
              child: Text(
                displayName ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: isMine ? widgets.reversed.toList() : widgets,
          ),
        ],
      ),
    );
  }

//other
  Radius boBottomLeft() {
    if (isMine) return const Radius.circular(20);
    if (position == Position.first || position == Position.middle) {
      return const Radius.circular(4);
    }
    return const Radius.circular(20);
  }

  Radius boTopLeft() {
    if (isMine) return const Radius.circular(20);
    if (position == Position.last || position == Position.middle) {
      return const Radius.circular(4);
    }
    return const Radius.circular(20);
  }

//me
  Radius boBottomRight() {
    if (!isMine) return const Radius.circular(20);
    if (position == Position.first || position == Position.middle) {
      return const Radius.circular(4);
    }
    return const Radius.circular(20);
  }

  Radius boTopRight() {
    if (!isMine) return const Radius.circular(16);
    if (position == Position.last || position == Position.middle) {
      return const Radius.circular(4);
    }
    return const Radius.circular(20);
  }

  Color buildColorMessageContainer(BuildContext context) {
    return isMine
        ? context.myColorScheme.messageMeColor!
        : context.myColorScheme.messageOtherColor!;
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
  Widget build(BuildContext context) => const CircleAvatar(
        radius: 12,
        backgroundColor: Colors.grey,
        // child: Icon(
        //   Icons.person,
        //   color: Colors.white,
        // ),
      );
}
