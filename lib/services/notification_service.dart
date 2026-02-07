import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  Future<void> init() async {
    try {
      _log("🔔 [1] Timezone başlatılıyor...");
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      _log("🔔 [2] Ayarlar yapılıyor...");
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      _log("🔔 [3] Plugin initialize ediliyor...");
      bool? initialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          _log("🔔 Bildirime tıklandı: ${details.payload}");
        },
      );

      _log("🔔 [4] Başlatma sonucu: ${initialized == true ? 'BAŞARILI ✅' : 'BAŞARISIZ ❌'}");

    } catch (e) {
      _log("🔔 [HATA] Init sırasında hata: $e");
    }
  }
  Future<void> scheduleDailyNotification() async {
    try {
      await cancelNotifications();

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // ID
        'Günün Nasıl Geçti? 🎨',
        'Bugünün rengini seçmeyi unutma! Birkaç saniyeni ayır.',
        _nextInstanceOfNinePM(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Günlük Hatırlatıcı',
            channelDescription: 'Her akşam hatırlatma yapar',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFF6C63FF),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      _log("🔔 Zamanlayıcı kuruldu: Her akşam 21:00");
    } catch (e) {
      _log("🔔 Zamanlayıcı hatası: $e");
    }
  }
  tz.TZDateTime _nextInstanceOfNinePM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, 23, 30);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
  Future<void> requestPermissions() async {
    _log("🔔 [?] İzin isteniyor...");
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _log("🔔 [?] İzin sonucu: ${result == true ? 'VERİLDİ' : 'REDDEDİLDİ'}");
  }
  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    _log("🔔 Tüm bildirimler iptal edildi.");
  }
}