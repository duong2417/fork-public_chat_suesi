import 'package:flutter/material.dart';
import '../../genai_setting/ui/genai_setting_screen.dart';

class ChatWithGeminiBubble extends StatefulWidget {
  const ChatWithGeminiBubble({super.key});

  @override
  State<ChatWithGeminiBubble> createState() => _ChatWithGeminiBubbleState();
}

class _ChatWithGeminiBubbleState extends State<ChatWithGeminiBubble> {
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
                    })),
          ),
      ],
    );
  }
}
