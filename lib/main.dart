import 'dart:async';
import 'dart:convert';

import 'package:app/core/api/config.dart';
import 'package:app/core/providers/pc_provider.dart';
import 'package:app/core/providers/queue_provider.dart';
import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/theme/vibranium_theme.dart';
import 'package:app/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

String? currentJWT;

const String ggLeapApiKey = ApiConfig.apiKey;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Set the background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    await refreshGgLeapJwt();
    print("Initial JWT fetched successfully.");
  } catch (e) {
    print("Failed to fetch initial JWT: $e");
  }

  Timer.periodic(const Duration(minutes: 5), (timer) async {
    try {
      await refreshGgLeapJwt();
      print("JWT refreshed successfully at ${DateTime.now()}");
    } catch (e) {
      print("Periodic JWT refresh failed: $e");
    }
  });
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => PcProvider()),
        ChangeNotifierProvider(create: (context) => QueueProvider()),
      ],
      child: MaterialApp(
        title: 'Vibranium',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: vibraniumDarkTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}

Future<void> refreshGgLeapJwt() async {
  final url = Uri.parse(
    'https://api.ggleap.com/production/authorization/public-api/auth',
  );

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'AuthToken': ggLeapApiKey}),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Replace 'Jwt' with the exact key name returned by the ggLeap API payload
    if (data.containsKey('Jwt')) {
      currentJWT = data['Jwt'];
    } else {
      throw Exception("Response did not contain a 'Jwt' key.");
    }
  } else {
    throw Exception(
      "Failed to auth. Status code: ${response.statusCode}. Body: ${response.body}",
    );
  }
}
