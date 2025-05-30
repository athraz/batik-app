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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batik App',
      home: Scaffold(
        appBar: AppBar(title: Text('Batik App')),
        body: Center(child: Text('Hello World')),
      ),
    );
  }
}
