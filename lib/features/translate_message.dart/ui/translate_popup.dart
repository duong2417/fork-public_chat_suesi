import 'package:flutter/material.dart';
import 'list_hint_widget.dart';
import 'my_textfield.dart';

class TranslatePopup extends StatelessWidget {
  TranslatePopup({
    super.key,
    required this.onSubmit,
    required this.fetchListHistoryLanguages,
  });
  final void Function(String value) onSubmit;
  final Future<List<String>> Function() fetchListHistoryLanguages;

  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        ListHintWidget<String>(
          fetchListData: fetchListHistoryLanguages,
          onSelect: (value) {
            _controller.text += '$value,';
          },
          onUnSelect: (value) {
            _controller.text = _controller.text.replaceAll('$value,', '');
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Ví dụ: vi, en... (cách nhau bởi dấu phẩy)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextFieldInput(
          autofocus: true,
          hintText: "Nhập 1 hoặc nhiều ngôn ngữ/mã ngôn ngữ/đất nước...",
          controller: _controller,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            onSubmit(value);
          },
        ),
      ],
    );
  }
}
