import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'core/services/payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications
  await NotificationService.initialize();

  // Initialize payment service
  PaymentService.initialize();

  runApp(const ProviderScope(child: TraqaApp()));
}