import 'package:batik_app/screens/create_post_page.dart';
import 'package:batik_app/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:batik_app/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'home',
      routes: {
        // 'login': (context) => LoginPage(),
        // 'register': (context) => RegisterPage(),
        // 'profile': (context) => ProfilePage(),
        'home': (context) => HomePage(),
        'post/create': (context) => CreatePostPage(),
      },
    );
  }
}
