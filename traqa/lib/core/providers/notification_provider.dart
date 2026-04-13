import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationPreferencesProvider = StateNotifierProvider<NotificationPreferencesNotifier, Map<String, bool>>((ref) {
  return NotificationPreferencesNotifier();
});

class NotificationPreferencesNotifier extends StateNotifier<Map<String, bool>> {
  NotificationPreferencesNotifier() : super({}) {
    _loadPreferences();
  }

  static const String _keyReportNotifications = 'notifications_reports';
  static const String _keyFamilyNotifications = 'notifications_family';
  static const String _keyReminderNotifications = 'notifications_reminders';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    state = {
      _keyReportNotifications: prefs.getBool(_keyReportNotifications) ?? true,
      _keyFamilyNotifications: prefs.getBool(_keyFamilyNotifications) ?? true,
      _keyReminderNotifications: prefs.getBool(_keyReminderNotifications) ?? true,
    };
  }

  Future<void> setReportNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReportNotifications, enabled);

    state = {
      ...state,
      _keyReportNotifications: enabled,
    };
  }

  Future<void> setFamilyNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFamilyNotifications, enabled);

    state = {
      ...state,
      _keyFamilyNotifications: enabled,
    };
  }

  Future<void> setReminderNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderNotifications, enabled);

    state = {
      ...state,
      _keyReminderNotifications: enabled,
    };
  }

  bool get reportNotifications => state[_keyReportNotifications] ?? true;
  bool get familyNotifications => state[_keyFamilyNotifications] ?? true;
  bool get reminderNotifications => state[_keyReminderNotifications] ?? true;
}