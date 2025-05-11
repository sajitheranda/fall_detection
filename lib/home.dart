import 'package:fall_detection/FallDetectionPage.dart';
import 'package:fall_detection/contactlist.dart';
import 'package:fall_detection/database/notify_database.dart';
import 'package:fall_detection/providers/fall-detection_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //bool isFallDetectionEnabled = true; // Boolean to toggle Fall Detection


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fall Detection'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Add the Toggle button at the top
          ListTile(
            title: const Text('Enable Fall Detection'),
            trailing: Switch(
              value: context.watch<FallDetectionProvider>().isFallDetectionEnabled,
              onChanged: (bool value) {
                context.read<FallDetectionProvider>().toggleFallDetection(value);
              },
            ),
          ),
          Divider(),
          // ListView with Fall Detection and Contact List
          Expanded(
            child: ListView(
              children: [
                // Show FallDetectionPage if the toggle is on
                if (context.watch<FallDetectionProvider>().isFallDetectionEnabled) Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FallDetectionPage(),
                ),

                // Show ContactListScreen always
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ContactListScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
