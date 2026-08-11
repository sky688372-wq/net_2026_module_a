import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:net_2026/login_screen.dart';
import 'package:net_2026/main_page_screen.dart';

void main() {
  //화면 세로 방향으로 고정시키는 부분
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginScreen()
    );
  }
}
