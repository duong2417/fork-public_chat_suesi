import 'package:shared_preferences/shared_preferences.dart';

const keyCurrentSelectedLanguages = 'current_selected_languages';
String deviceLocale = 'việt nam';
// String deviceLocale = Platform.isAndroid ? Platform.localeName : 'en';
String defaultLanguageCode = 'en';

class LocalSharedData {
  LocalSharedData._internal();
  static LocalSharedData instance = LocalSharedData._internal();
  factory LocalSharedData() {
    return instance;
  }

  late SharedPreferences sharedPreferences;

  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  setCurrentSelectedLanguages(List<String> languages) async {
    await sharedPreferences.setStringList(
        keyCurrentSelectedLanguages, languages);
  }

  List<String> getCurrentSelectedLanguages() {
    // return sharedPreferences.getStringList(keyCurrentSelectedLanguages) ??
    //     [
    //       deviceLocale,
    //       defaultLanguageCode
    //     ]; // deviceLocale != 'en' ? 'en' : 'japan'
    return ['việt nam', 'en'];
  }
}
