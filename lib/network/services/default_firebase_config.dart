import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
        appId: '',
        apiKey: '',
        projectId: '',
        messagingSenderId: '',
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '',
        apiKey: '',
        projectId: '',
        messagingSenderId: '',
        iosBundleId: '',
      );
    } else {
      // Android
      return const FirebaseOptions(
        appId: '1:423110541598:android:90231be68dfb816a31890f',
        apiKey: 'AIzaSyAAFJ1m7lZNCLH0SR2y_rAZIQAS7i5anvE',
        projectId: 'kivicare-8c774',
        messagingSenderId: '423110541598',
        storageBucket: 'kivicare-8c774.appspot.com',
      );
    }
  }
}
