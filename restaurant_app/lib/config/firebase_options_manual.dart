import 'package:firebase_core/firebase_core.dart';
import 'app_config.dart';

class FirebaseOptionsManual {
  static FirebaseOptions web() => const FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        authDomain: AppConfig.firebaseAuthDomain,
        projectId: AppConfig.firebaseProjectId,
        storageBucket: AppConfig.firebaseStorageBucket,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        appId: AppConfig.firebaseAppId,
        measurementId: AppConfig.firebaseMeasurementId,
      );
}
