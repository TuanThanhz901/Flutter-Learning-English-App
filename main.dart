import 'package:final_project/pages/LogIn.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (kIsWeb) {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      options: firebaseOptions,
    );
  } else {
    Firebase.initializeApp();
  }

  runApp(MainApp());
}

const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyDKNoWdfBFaVfH4D_caD-aUlvf3x0n1tFg",
    authDomain: "emax-e817a.firebaseapp.com",
    projectId: "emax-e817a",
    storageBucket: "emax-e817a.appspot.com",
    messagingSenderId: "118053547334",
    appId: "1:118053547334:web:b05199acaa7f535866c947",
    measurementId: "G-FRRGW29JRQ");

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogIn(),
    );
  }
}
