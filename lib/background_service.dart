import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fall_detection/database/contact_database.dart';
import 'package:fall_detection/sms_sender.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'fall_detection',
      initialNotificationTitle: 'Fall Detection Active',
      initialNotificationContent: 'Monitoring for falls',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Initialize required variables
  final smsSender = SmsSender();
  DateTime? lastSmsTime;
  const double fallThreshold = 12.0;

  // Setup for Android
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Fall Detection Running",
      content: "Monitoring accelerometer data",
    );
  }

  // Main monitoring loop
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    try {
      // 1. Get latest accelerometer reading
      final acceleration = await accelerometerEventStream().first;
      final magnitude = acceleration.z.abs(); // Using Z-axis only

      // 2. Check fall threshold
      if (magnitude > fallThreshold) {
        final now = DateTime.now();

        // 3. Rate limiting (1 SMS per minute max)
        if (lastSmsTime == null || now.difference(lastSmsTime!).inMinutes >= 1) {
          final contacts = await ContactDatabase.instance.getAllContacts();

          // 4. Send SMS alerts
          for (final contact in contacts) {
            final formattedNumber = contact.phone.startsWith('0')
                ? contact.phone.replaceFirst('0', '+94')
                : contact.phone;

            await smsSender.sendSms(
              formattedNumber,
              "URGENT: Fall detected! User may need assistance.",
            );

            await Future.delayed(const Duration(milliseconds: 300));
          }

          lastSmsTime = now; // Update last SMS time
        }
      }

      // Update notification
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Last Check: ${DateTime.now().toString().substring(11, 19)}",
          content: "Last Reading: ${magnitude.toStringAsFixed(2)} m/s²",
        );
      }

    } catch (e) {
      print("Fall detection error: $e");
    }
  });
}