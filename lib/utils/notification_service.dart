import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions (iOS)
    await _messaging.requestPermission();
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // TODO:
  // - 1) Notification for handling new likes on User's posts
  // - 2) Notification for handling new comments on User's posts
}
