import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ExpandableTextWidget(
      {super.key, required this.text, this.maxLines = 1, this.style});

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;
  bool _isOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }
  late final TextPainter textPainter;
  void _checkOverflow() {
    textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: widget.style,
      ),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width);

    setState(() {
      _isOverflowing = textPainter.didExceedMaxLines;
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return RichText(
  //     maxLines: _isExpanded ? null : widget.maxLines,
  //     overflow: TextOverflow.ellipsis,
  //     text: TextSpan(
  //       children: [
  //         TextSpan(
  //           text: widget.text,
  //           style: widget.style ?? DefaultTextStyle.of(context).style,
  //         ),
  //         if (_isOverflowing)
  //           TextSpan(
  //             text: ' ${_isExpanded ? 'See less' : 'See more'}',
  //             style: const TextStyle(
  //               color: Color.fromARGB(255, 98, 51, 239),
  //             ),
  //             recognizer: TapGestureRecognizer()
  //               ..onTap = () {
  //                 setState(() {
  //                   _isExpanded = !_isExpanded;
  //                 });
  //               },
  //           ),
  //       ],
  //     ),
  //   );
  // }

  @override
Widget build(BuildContext context) {
  // final textStyle = widget.style ?? DefaultTextStyle.of(context).style;
  // final span = TextSpan(text: widget.text, style: textStyle);
  // final textPainter = TextPainter(
  //   text: span,
  //   maxLines: widget.maxLines,
  //   textDirection: TextDirection.ltr,
  // );

  // textPainter.layout(maxWidth: MediaQuery.of(context).size.width);

  // final isOverflowing = textPainter.didExceedMaxLines;

  return RichText(
    text: TextSpan(
      style: widget.style,
      children: [
        TextSpan(
          text: _isExpanded || !_isOverflowing
              ? widget.text
              : '${widget.text.substring(0, textPainter.getOffsetBefore(widget.maxLines * 100) ?? widget.text.length)}...',
        ),
        if (_isOverflowing)
          TextSpan(
            text: _isExpanded ? ' See less' : ' See more',
            style: const TextStyle(
              color: Color.fromARGB(255, 98, 51, 239),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
          ),
      ],
    ),
  );
}

}
