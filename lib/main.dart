import 'package:fall_detection/contactlist.dart';
import 'package:fall_detection/providers/fall-detection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'background_service.dart';
import 'database/contact_database.dart';
import 'home.dart';
import 'providers/contact_provider.dart';
import 'FallDetectionPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ContactDatabase.instance.database;
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  //await initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FallDetectionProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()..loadContacts()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fall Detection',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: Home(), // You can switch to FallDetectionPage() here
      debugShowCheckedModeBanner: false,
    );
  }



















}
