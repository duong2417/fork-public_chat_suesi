import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_chat/const.dart';
  import 'package:public_chat/features/chat/ui/local_background_chat_screen.dart';
import 'package:public_chat/features/genai_setting/bloc/genai_bloc.dart';
import 'package:public_chat/firebase_options.dart';
import 'package:public_chat/service_locator/service_locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math' as math;
import 'package:cloud_functions/cloud_functions.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ServiceLocator.instance.initialise();
   const ip = "127.0.0.1";
  // Cấu hình Firestore
  firestore.settings = const Settings(
    host: '$ip:4000', // Thay đổi port thành 4000
    sslEnabled: false,
    persistenceEnabled: false,
  );
  firestore.useFirestoreEmulator(ip, 8080);
  FirebaseFunctions.instance.useFunctionsEmulator(ip, 5001);
  // await setUpCollection();
  runApp(BlocProvider<GenaiBloc>(
    create: (context) => GenaiBloc(),
    child: const MainApp(),
  ));
}

Future<void> setUpCollection() async {
  await firestore.collection(codebase).doc(publicChatScreen).set({
    "code": "import 'package:flutter/material.dart'; class BaseScreen extends StatelessWidget {   const BaseScreen(this.widget);   final Widget widget;   @override   Widget build(BuildContext context) {     return Scaffold(       body: widget,     );   } }",
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // home: CustomPaintGradient(PublicChatScreen())
        home: BackgroundChatScreen()
        );
  }
}

class BaseScreen extends StatelessWidget {
  const BaseScreen(this.widget);
  final Widget widget;
  @override
  Widget build(BuildContext context) {
    final _widget = widget;
    return Scaffold(
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: _widget,
      ),
    );
  }
}
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.3, size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
/////////////////
///custom paint + gradient
class CustomPaintGradient extends StatelessWidget {
  const CustomPaintGradient(this.widget);
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: BackgroundPainterGradient(),
        child: widget,
      ),
    );
  }
}

class BackgroundPainterGradient extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.deepPurple, Colors.blueAccent],
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}