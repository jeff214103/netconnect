import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:netconnect/firebase_options.dart';

class FirebaseService {
  static final FirebaseAppCheck appCheck = FirebaseAppCheck.instance;

  Future<void> init() async {
    await appCheck.activate(
      webProvider: ReCaptchaV3Provider(DefaultFirebaseOptions.RecaptchaSiteID),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );
  }
}
