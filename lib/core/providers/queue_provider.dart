import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class QueueProvider extends ChangeNotifier {
  static const String _baseUrl = "https://vibraniumjobooking.com/api";
  bool _isLoading = false;
  Map<String, dynamic> laneStats = {};
  List<dynamic> _userQueues = [];
  List<dynamic> _fullWaitingList = [];
  Map<String, dynamic>? _bestPosition;

  // Getters
  bool get isLoading => _isLoading;
  List<dynamic> get fullWaitingList => _fullWaitingList;
  Map<String, dynamic>? get bestPosition => _bestPosition;
  List<dynamic> get userQueues => _userQueues;

  Future<void> updateQueueStats(String userUuid) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_queue_stats.php?user_uuid=$userUuid'),
      );
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['success'] == true) {
          laneStats = res['global_stats'] ?? {};
          _userQueues = res['user_queues'] ?? [];
          _fullWaitingList = res['full_queue'] ?? [];
          _bestPosition = res['best_position'];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Stats Error: $e");
    }
  }

  Future<bool> joinWaitingList(
    String uuid,
    String name,
    String lanesString,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check/Request Permissions
      var status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        await Permission.notification.request();
      }

      // 2. Get the Token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("Vibranium Debug: FCM Token retrieved: $fcmToken");

      // 3. Perform the Request
      final response = await http
          .post(
            Uri.parse('$_baseUrl/join_queue.php'),
            body: {
              'user_uuid': uuid,
              'username': name,
              'queue_type': lanesString,
              'fcm': fcmToken ?? "",
            },
          )
          .timeout(const Duration(seconds: 10));

      // --- DEBUGGING BLOCK START ---
      debugPrint("Vibranium Debug: Status Code: ${response.statusCode}");
      debugPrint("Vibranium Debug: Raw Server Output: ${response.body}");
      // --- DEBUGGING BLOCK END ---

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['success'] == true) {
          await updateQueueStats(uuid);
          return true;
        } else {
          debugPrint("Vibranium Logic Error: ${res['message']}");
        }
      } else if (response.statusCode == 500) {
        debugPrint(
          "Vibranium Server Error: The server crashed. Check the PHP raw output printed above.",
        );
      }

      return false;
    } catch (e) {
      debugPrint("Vibranium Connection Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> exitWaitingList(String uuid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check/Request Permissions
      var status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        await Permission.notification.request();
      }

      // 2. Get the Token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("Vibranium Debug: FCM Token retrieved: $fcmToken");

      // 3. Perform the Request
      final response = await http
          .post(
            Uri.parse('$_baseUrl/remove_queue.php'),
            body: jsonEncode({'user_uuid': uuid}),
          )
          .timeout(const Duration(seconds: 10));

      // --- DEBUGGING BLOCK START ---
      debugPrint("Vibranium Debug: Status Code: ${response.statusCode}");
      debugPrint("Vibranium Debug: Raw Server Output: ${response.body}");
      // --- DEBUGGING BLOCK END ---

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['success'] == true) {
          await updateQueueStats(uuid);
          return true;
        } else {
          debugPrint("Vibranium Logic Error: ${res['message']}");
        }
      } else if (response.statusCode == 500) {
        debugPrint(
          "Vibranium Server Error: The server crashed. Check the PHP raw output printed above.",
        );
      }

      return false;
    } catch (e) {
      debugPrint("Vibranium Connection Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
