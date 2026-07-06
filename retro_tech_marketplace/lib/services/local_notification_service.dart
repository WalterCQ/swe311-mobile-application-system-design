import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final LocalNotificationService instance = LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: false,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: false, sound: true);
  }

  Future<void> showLaunchTestNotification() async {
    await initialize();
    const android = AndroidNotificationDetails(
      'retro_tech_test_notifications',
      'RetroTech test notifications',
      channelDescription: 'One-minute launch test notification for coursework.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'RetroTech test notification',
    );
    const darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );
    const details = NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
    await _plugin.show(
      id: 1001,
      title: 'RetroTech test notification',
      body: 'System notification is working.',
      notificationDetails: details,
      payload: 'launch-test-notification',
    );
  }
}
