import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/core/api/config.dart';
import 'package:app/core/providers/pc_provider.dart';
import 'package:app/core/providers/queue_provider.dart';
import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/theme/vibranium_theme.dart';
import 'package:app/splash.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

String? currentJWT;

const String ggLeapApiKey = ApiConfig.apiKey;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> printInstallationId() async {
  try {
    String id = await FirebaseInstallations.instance.getId();
    print('Firebase Installation ID: $id');
    // You can now show this in a Dialog or copy it to the clipboard
  } catch (e) {
    print('Error fetching Installation ID: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 1. Register background handler first
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Add this right before runApp()
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  } else {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // 3. Configure foreground behavior
  // DO NOT wrap this in an 'if' check for authorization status.
  // Set it globally to ensure the OS knows how to handle incoming pokes.
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Get token for debugging
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  await printInstallationId();

  // Your GgLeap Logic
  try {
    await refreshGgLeapJwt();
  } catch (e) {
    print("Initial JWT failed: $e");
  }

  Timer.periodic(const Duration(minutes: 7), (timer) async {
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
        home: const AppVersionGate(),
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

/// ---------------- VERSION CHECKER ----------------

class VersionCheckResult {
  final bool forceUpdate;
  final String latestVersion;
  final String minSupportedVersion;
  final String? storeUrl;
  final String? message;

  VersionCheckResult({
    required this.forceUpdate,
    required this.latestVersion,
    required this.minSupportedVersion,
    this.storeUrl,
    this.message,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    return VersionCheckResult(
      forceUpdate: json['forceUpdate'] == true,
      latestVersion: (json['latestVersion'] ?? '').toString(),
      minSupportedVersion: (json['minSupportedVersion'] ?? '').toString(),
      storeUrl: json['storeUrl']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class AppVersionGate extends StatefulWidget {
  const AppVersionGate({super.key});

  @override
  State<AppVersionGate> createState() => _AppVersionGateState();
}

class _AppVersionGateState extends State<AppVersionGate> {
  bool _loading = true;
  bool _mustUpdate = false;
  String? _error;
  String? _storeUrl;
  String _message = 'Please update the app from the store.';
  String _currentVersion = '';
  String _latestVersion = '';

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final installedVersion = packageInfo.version;

      final versionResult = await fetchLatestVersion(installedVersion);
      print("Version App : " + installedVersion);
      setState(() {
        _currentVersion = installedVersion;
        _latestVersion = versionResult.latestVersion;
        _mustUpdate =
            versionResult.forceUpdate ||
            _isVersionLower(
              installedVersion,
              versionResult.minSupportedVersion,
            );
        _storeUrl = versionResult.storeUrl;
        _message = versionResult.message?.isNotEmpty == true
            ? versionResult.message!
            : 'This version of the app is too old. Please update from the store.';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool _isVersionLower(String current, String minimum) {
    final currentParts = current.split('.').map(int.tryParse).toList();
    final minimumParts = minimum.split('.').map(int.tryParse).toList();

    final maxLength = currentParts.length > minimumParts.length
        ? currentParts.length
        : minimumParts.length;

    for (int i = 0; i < maxLength; i++) {
      final currentValue = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      final minimumValue = i < minimumParts.length ? (minimumParts[i] ?? 0) : 0;

      if (currentValue < minimumValue) return true;
      if (currentValue > minimumValue) return false;
    }

    return false;
  }

  Future<void> _openStore() async {
    if (_storeUrl == null || _storeUrl!.isEmpty) return;

    final uri = Uri.parse(_storeUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: heroTag,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image.asset(
                'assets/branding/vibranium_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    }

    if (_mustUpdate) {
      return ForceUpdateScreen(
        message: _message,
        currentVersion: _currentVersion,
        latestVersion: _latestVersion,
        onUpdatePressed: _openStore,
      );
    }

    if (_error != null) {
      return _VersionErrorScreen(error: _error!, onRetry: _checkVersion);
    }

    return const SplashScreen();
  }
}

Future<VersionCheckResult> fetchLatestVersion(String installedVersion) async {
  final uri = Uri.parse(
    'https://vibraniumjobooking.com/api/version_checker.php',
  );

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'platform': (Platform.isIOS) ? "ios" : "android",
      'currentVersion': installedVersion,
      'appName': 'Vibranium',
    }),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Version check failed: ${response.statusCode} ${response.body}',
    );
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return VersionCheckResult.fromJson(data);
}

/// ---------------- SCREENS ----------------
class ForceUpdateScreen extends StatelessWidget {
  final String message;
  final String currentVersion;
  final String latestVersion;
  final VoidCallback onUpdatePressed;

  const ForceUpdateScreen({
    super.key,
    required this.message,
    required this.currentVersion,
    required this.latestVersion,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibraniumColors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: VibraniumColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: VibraniumColors.outline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x447C3AED),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          VibraniumColors.purpleDeep,
                          VibraniumColors.purple,
                          VibraniumColors.cyan,
                        ],
                      ),
                      border: Border.all(color: VibraniumColors.outline),
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      color: VibraniumColors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Update Required',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: VibraniumColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: VibraniumColors.onSurfaceMuted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VibraniumColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VibraniumColors.outline),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Current version: $currentVersion',
                          style: const TextStyle(
                            color: VibraniumColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Latest version: $latestVersion',
                          style: const TextStyle(
                            color: VibraniumColors.cyan,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onUpdatePressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: VibraniumColors.purple,
                        foregroundColor: VibraniumColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Update from Store',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You cannot continue using this app version.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: VibraniumColors.onSurfaceMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _VersionErrorScreen({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibraniumColors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: VibraniumColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: VibraniumColors.outline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: VibraniumColors.cyan,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Version Check Failed',
                  style: TextStyle(
                    color: VibraniumColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: VibraniumColors.onSurfaceMuted),
                ),
                const SizedBox(height: 18),
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
