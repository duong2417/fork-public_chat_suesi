import 'package:flutter/material.dart';
class BaseScreen extends StatelessWidget {
  const BaseScreen(this.widget);
  final Widget widget;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: widget,
      ),
    );
  }
}
