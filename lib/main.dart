import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_chat/features/genai_setting/bloc/genai_bloc.dart';
import 'package:public_chat/firebase_options.dart';
import 'package:public_chat/service_locator/service_locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'features/login/ui/login_screen.dart';
import 'features/chat/ui/public_chat_screen.dart';
import 'features/translate_message.dart/bloc/translate_message_bloc.dart';
import 'utils/local_shared_data.dart';

BuildContext? get globalAppContext => navigatorKey.currentContext;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalSharedData().init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Cấu hình kết nối với Firebase Emulator
  const ip = "127.0.0.1";
  final instance = FirebaseFirestore.instance;
  // Cấu hình Firestore
  instance.settings = const Settings(
    host: '$ip:4000',  // Thay đổi port thành 4000
    sslEnabled: false,
    persistenceEnabled: false,
  );
  
  // Kết nối Functions emulator nếu cần
  instance.useFirestoreEmulator(ip, 8080);
  FirebaseFunctions.instance.useFunctionsEmulator(ip, 5001);
  // instance.collection('a').doc().set({'b': 'd'});
  // instance.collection('A').doc().set({'B': 'C SET'});
  // try {
  //   final doc = await instance.collection('A').doc().get();
  //   print(doc.data());
  // } catch (e) {
  //   if (e.toString().contains('client is offline')) {
  //     // Xử lý khi offline
  //     print('client is offline');
  //   }
  // }
  ServiceLocator.instance.initialise();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<GenaiBloc>(create: (context) => GenaiBloc()),
        BlocProvider<TranslateMessageBloc>(create: (context) {
          final languages = LocalSharedData().getCurrentSelectedLanguages();
          return TranslateMessageBloc()
            ..add(EnableTranslateEvent(languages: languages));
        }),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: PublicChatScreen());
  }
}
