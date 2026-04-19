import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  print('Testing Firebase initialization...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
    print('Android App ID: ${DefaultFirebaseOptions.android.appId}');
    print('Web App ID: ${DefaultFirebaseOptions.web.appId}');
    print('Project ID: ${DefaultFirebaseOptions.android.projectId}');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
}