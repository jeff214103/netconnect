import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:netconnect/firebase_options.dart';
import 'package:netconnect/provider/data_provider.dart';
import 'package:netconnect/services/firebase_service.dart';
import 'package:netconnect/ui/home_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseService().init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DataProvider())],
      child: const NetConnectApp(),
    ),
  );
}

class NetConnectApp extends StatelessWidget {
  const NetConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetConnect',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const HomePage(),
    );
  }
}
