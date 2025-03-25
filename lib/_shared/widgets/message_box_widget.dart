import 'package:flutter/material.dart';

class MessageBox extends StatefulWidget {
  final ValueChanged<String> onSendMessage;
  const MessageBox({required this.onSendMessage, super.key});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _controller,
      maxLines: 5,
      minLines: 1,
      decoration: InputDecoration(
        enabledBorder: theme.inputDecorationTheme.enabledBorder,
        focusedBorder: theme.inputDecorationTheme.focusedBorder,
        errorBorder: theme.inputDecorationTheme.errorBorder,
        focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder,
        fillColor: theme.inputDecorationTheme.fillColor,
        focusColor: theme.inputDecorationTheme.focusColor,
        hintText: 'Enter your message',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey,
        ),
        filled: true,
        border: theme.inputDecorationTheme.border,
        suffixIcon: IconButton(
          onPressed: () {
            widget.onSendMessage(_controller.text);
            _controller.text = '';
          },
          icon: const Icon(Icons.send),
        ),
      ),
      onSubmitted: (value) {
        widget.onSendMessage(value);
        _controller.text = '';
      },
    );
  }
}
