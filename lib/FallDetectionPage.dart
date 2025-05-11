import 'dart:async';
import 'dart:math';
import 'package:fall_detection/contactlist.dart';
import 'package:fall_detection/providers/fall-detection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'database/contact_database.dart';
import 'sms_sender.dart';

class FallDetectionPage extends StatefulWidget {
  const FallDetectionPage({super.key});

  @override
  State<FallDetectionPage> createState() => _FallDetectionPageState();
}

class _FallDetectionPageState extends State<FallDetectionPage> {
  double _magnitude = 0.0;
  String _status = 'Normal';
  final double _fallThreshold = 12.0;

  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  final SmsSender smsSender = SmsSender();

  DateTime? _lastSmsTime; // <-- Track time of last SMS

  @override
  void initState() {
    super.initState();
  }

  void _startAccelerometerStream() {
    if (context.watch<FallDetectionProvider>().isFallDetectionEnabled){
      accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
            (event) {
          final magnitude = event.z ;//sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

          setState(() {
            _magnitude = magnitude;

            if (magnitude > _fallThreshold && _status != 'Fall Detected!') {
              _status = 'Fall Detected!';
              _sendFallAlertSms();
              _startCountdown();
            } else if (magnitude <= _fallThreshold && _secondsRemaining == 0) {
              _status = 'Normal';
            }
          });
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (ctx) => const AlertDialog(
              title: Text("Sensor Error"),
              content: Text("Accelerometer not available."),
            ),
          );
        },
      );

    }



  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _secondsRemaining = 30;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _status = 'Normal';
          _countdownTimer?.cancel();

        }
      });
    });
  }

  void _sendFallAlertSms() async {
    final now = DateTime.now();

    if (_lastSmsTime == null || now.difference(_lastSmsTime!).inMinutes >= 10) {
      try {
        final contacts = await ContactDatabase.instance.getAllContacts();

        if (contacts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No contacts saved.")),
          );
          return;
        }

        bool allSuccess = true;

        for (final contact in contacts) {
          final formattedNumber = contact.phone.startsWith('0')
              ? contact.phone.replaceFirst('0', '+94')
              : contact.phone;

          bool success = await smsSender.sendSms(
            formattedNumber,
            "Fall detected! The user may need help.",
          );

          if (!success) {
            allSuccess = false;
            debugPrint("Failed to send SMS to ${contact.phone}");
          } else {
            debugPrint("SMS sent to ${contact.phone}");
          }

          // Optional: delay between messages to avoid throttling
          await Future.delayed(const Duration(milliseconds: 300));
        }

        if (!allSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Some messages failed to send.")),
          );
        } else {
          _lastSmsTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Alerts sent to all contacts.")),
          );
        }
      } catch (e) {
        debugPrint("Error sending SMS: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send alerts.")),
        );
      }
    } else {
      debugPrint("SMS already sent in the last minute. Skipping...");
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _startAccelerometerStream();
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            if (context.watch<FallDetectionProvider>().isFallDetectionEnabled)
            Text(
              "Acceleration Magnitude:\n${_magnitude.toStringAsFixed(2)} m/s²",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            if (context.watch<FallDetectionProvider>().isFallDetectionEnabled)
            Text(
              _status,
              style: TextStyle(
                fontSize: 30,
                color: _status == 'Fall Detected!' ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (context.watch<FallDetectionProvider>().isFallDetectionEnabled)
            if (_status == 'Fall Detected!' && _secondsRemaining > 0)
              Text(
                'Respond in $_secondsRemaining seconds',
                style: const TextStyle(fontSize: 20, color: Colors.orange),
              ),
          ],
        );
  }
}
