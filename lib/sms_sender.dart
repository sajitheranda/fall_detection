import 'package:another_telephony/telephony.dart';

class SmsSender {
  final Telephony telephony = Telephony.instance;

  Future<bool> sendSms(String phoneNumber, String message) async {
    // Request permissions for SMS
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

    if (permissionsGranted != null && permissionsGranted) {
      // Send the SMS
      telephony.sendSms(
        to: phoneNumber,
        message: message,
      );
      return true;
    } else {
      return false;
    }
  }
}