import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permissions: ${settings.authorizationStatus}');

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle message when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);

    // Handle message when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Save FCM token to user profile
    _saveFcmToken();
  }

  static Future<void> _saveFcmToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'fcmTokenUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': newToken,
          'fcmTokenUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message: ${message.notification?.title}');

    // Show local notification
    await _showLocalNotification(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      payload: json.encode(message.data),
    );
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background message: ${message.notification?.title}');
    // Background messages are handled by native code
  }

  static void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      print('Initial message: ${message.notification?.title}');
      _handleNotificationClick(message.data);
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.notification?.title}');
    _handleNotificationClick(message.data);
  }

  static void _handleNotificationClick(Map<String, dynamic> data) {
    final type = data['type'];
    final reportId = data['reportId'];
    final memberId = data['memberId'];

    switch (type) {
      case 'report_ready':
        // Navigate to report screen
        print('Navigating to report: $reportId');
        // TODO: Implement navigation
        break;
      case 'health_alert':
        // Navigate to health dashboard
        print('Health alert for member: $memberId');
        // TODO: Implement navigation
        break;
      default:
        print('Unknown notification type: $type');
    }
  }

  static Future<void> _showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'traqa_channel',
      'Traqa Notifications',
      channelDescription: 'Health report and family notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  static Future<void> sendTestNotification() async {
    await _showLocalNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification from Traqa',
      payload: json.encode({'type': 'test'}),
    );
  }

  static Future<void> scheduleDailyReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Health Reminders',
      channelDescription: 'Daily health check-in reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    await _notifications.periodicallyShow(
      1001,
      'Time for Health Check-in',
      'Remember to track your health today!',
      RepeatInterval.daily,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}