import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_chat/features/genai_setting/bloc/genai_bloc.dart';
import 'package:public_chat/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:public_chat/service_locator/service_locator.dart';
// import 'features/chat/ui/public_chat_screen.dart';
import 'features/chat_with_gemini/ui/my_pubblic_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ServiceLocator.instance.initialise();
  //  const ip = "127.0.0.1";
  // // Cấu hình Firestore
  // FirebaseFirestore.instance.settings = const Settings(
  //   host: '$ip:4000', // Thay đổi port thành 4000
  //   sslEnabled: false,
  //   persistenceEnabled: false,
  // );
  // FirebaseFirestore.instance.useFirestoreEmulator(ip, 8080);
  // FirebaseFunctions.instance.useFunctionsEmulator(ip, 5001);
  runApp(BlocProvider<GenaiBloc>(
    create: (context) => GenaiBloc(),
    child: const MainApp(),
  ));
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
        home: MyPublicChatScreen());
  }
}
