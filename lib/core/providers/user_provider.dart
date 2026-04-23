import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/core/api/config.dart';
import 'package:app/core/models/pc.dart';
import 'package:app/core/models/session.dart';
import 'package:app/core/models/user.dart';
import 'package:app/core/models/user_rank.dart';
import 'package:app/core/models/user_time.dart';
import 'package:app/core/providers/pc_provider.dart';

import 'package:app/main.dart';
import 'package:app/screens/book_pc/book_pc_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  GgLeapUser? _user;

  GgLeapUser? get user => _user;

  bool isLoading = false;

  List<GgSession> userSesstions = [];
  List<UserTime> userTime = [];
  GgMachine? currentBookedPc;

  String? errorMessage;

  List leaderBoard = [];

  Future<void> getLeaderBoard() async {
    final response = await http.get(
      Uri.parse("https://vibraniumjobooking.com/api/userLeaderBoard.php"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      leaderBoard = data;
      notifyListeners();
    } else {
      print("Faild to get LeaderBoard : ${response.statusCode}");
    }
  }

  Future<void> getCurrectLoggedingPC(PcProvider pcProvider) async {
    if (pcProvider.pcs.isEmpty) {
      await pcProvider.fetchMachines();
      getCurrectLoggedingPC(pcProvider);
    } else {
      GgMachine? loggedinPC = pcProvider.pcs.firstWhere(
        (element) => element.userUuid == user!.uuid,
        orElse: () => GgMachine(),
      );

      if (loggedinPC.uuid != null) {
        final name = loggedinPC.name!.toLowerCase();
        final pcNumber = (name.contains("pc"))
            ? int.parse(name.split('pc').last)
            : 0;
        print("Saving PC");
        await saveCurrentBookedPc(
          pcId: loggedinPC.name ?? "",
          areaId: (name.contains("pc"))
              ? "Noraml"
              : (name.startsWith("vip"))
              ? "VIP"
              : (name.startsWith("MV"))
              ? "Master"
              : (name.startsWith("S"))
              ? "Stage"
              : "",
          categoryId: (name.contains("pc"))
              ? (pcNumber <= 28)
                    ? "Area 1"
                    : (pcNumber <= 57)
                    ? "Area 2"
                    : "Area 3"
              : (name.startsWith("mv"))
              ? "Master Vip"
              : (name.startsWith("v"))
              ? "Vip"
              : (name.startsWith("s"))
              ? "Stage"
              : "",
        );
      } else {
        print("User is not looged in anywere");
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('current_booked_pc_v1');
      }

      currentBookedPc = loggedinPC;

      notifyListeners();
    }
  }

  Future<void> registerUser() async {
    if (!(await Permission.notification.isGranted)) {
      await Permission.notification.request();
    }

    // Replace with your actual domain
    final url = Uri.parse(
      'https://vibraniumjobooking.com/api/register_user.php',
    );

    try {
      if (Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          // If this is null, FCM won't work yet.
          // Wait a second or retry.
          await Future.delayed(Duration(seconds: 1));
        }
      }
      final fcm = await FirebaseMessaging.instance.getToken();

      print("Device FCM : $fcm");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': user!.username,
          'uuid': user!.uuid,
          'fcm_token': fcm,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          print("User synced: ${result['message']}");
        } else {
          print("API Error: ${result['message']}");
        }
      } else {
        print("Server responded with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Network error: $e");
    }
  }

  Future<bool> deleteAcc() async {
    final String url =
        '${ApiConfig.apiBaseUrl}/users/delete?Uuid=${user!.uuid}';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
        },
      );

      ApiConfig.printCurl(
        method: 'GET',
        url: Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
        },
      );

      if (response.statusCode == 200) {
        print("account deleted");

        notifyListeners();
        return true;
      } else {
        print('Failed to get user sessions: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching sessions: $e');
      return false;
    }
  }

  Future<bool> addTime({int? prizeOld}) async {
    int prize = 0;
    if (prizeOld == null) {
      prize = 4;
    } else {
      prize = prizeOld;
    }

    isLoading = true;
    notifyListeners();

    final String url = '${ApiConfig.apiBaseUrl}/users/add-play-time';
    String correlationId = Uuid().v4();
    final prizeInSeconds = prize * 3600;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
          'X-Correlation-Id': correlationId,
        },
        body: jsonEncode({
          "Uuid": user!.uuid,
          "Seconds": prizeInSeconds,
          "PaymentMethod": "Balance",
        }),
      );

      ApiConfig.printCurl(
        method: 'GET',
        url: Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
          'X-Correlation-Id': correlationId,
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('Failed to add time: ${response.body}');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error fetching time: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logoutUserFromPc() async {
    final String url = '${ApiConfig.apiBaseUrl}/machines/execute-action';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
      body: jsonEncode({
        'action': 'UserLogout',
        'userUuid': user!.uuid,
        'machineUuid': currentBookedPc!.uuid!,
      }),
    );

    print(response.statusCode);

    if (response.statusCode == 204) {
      currentBookedPc = null;
      await SharedPreferences.getInstance().then((prefs) {
        prefs.remove('current_booked_pc_v1');
      });
      notifyListeners();
      return true;
    } else {
      print('Failed to logout user from pc: ${response.body}');
      return false;
    }
  }

  Future<void> getUserTime() async {
    final String url =
        '${ApiConfig.apiBaseUrl}/users/gamepasses/list?UserUuid=${user!.uuid}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
        },
      );

      ApiConfig.printCurl(
        method: 'GET',
        url: Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
        },
      );

      if (response.statusCode == 200) {
        // 3. Decode the list of sessions
        final List<dynamic> offers = jsonDecode(response.body)["Offers"];

        userTime = offers.map((s) => UserTime.fromJson(s)).toList();

        double totalTime = 0.0;
        double usedTime = 0.0;

        for (var pass in userTime) {
          totalTime += pass.totalTimeSeconds;
          usedTime += pass.usedTimeSeconds;
        }

        double remainingTime = totalTime - usedTime;

        if (remainingTime == 0) {
          return;
        }

        user!.timeRemaining = remainingTime.toInt() + user!.timeRemaining;

        notifyListeners();
      } else {
        print('Failed to get user sessions: ${response.body}');
        throw Exception('Failed to get sessions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching sessions: $e');
      throw Exception('Error fetching sessions: $e');
    }
  }

  void setUser(GgLeapUser user) {
    _user = user;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('userUsername', user.username);
      prefs.setString('userUuid', user.uuid);
      prefs.setString('userEmail', user.email);
    });
    getUserTime();
    loadPoints();
    notifyListeners();
  }

  Future<void> loadPoints() async {
    final String url =
        '${ApiConfig.apiBaseUrl}/coins/balance?UserUuid=${user!.uuid}';

    if (user!.pointsBalance != null) {
      return;
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
    );

    // Using your custom curl printer
    ApiConfig.printCurl(
      method: 'GET',
      url: Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Extract the main balance
      // We use .toDouble() because the API might return an int or double
      final double balance = (data['Balance'] ?? 0.0).toDouble();

      // If you have a provider or state manager (like setUser),
      // you might want to update it here:
      // currentBalance = balance;
      // notifyListeners();

      // Optionally save to SharedPreferences like your createUser function
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('userBalance', balance);

      user!.pointsBalance = balance;

      notifyListeners();
    } else {
      print('Failed to get balance: ${response.body}');
      user!.pointsBalance = 0.0;
      notifyListeners();
    }
  }

  Future<bool> lockPC(pcUid) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/admin_login_requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
      body: jsonEncode({
        "userUuid": user!.uuid,
        "machineUuid": pcUid,
        "lockPcAfterLogin": true,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to book pc: ${response.body}');
      return false;
    }
  }

  void checkIfloggedIn(debug) async {
    if (debug) {
      final user = await getUserByUuid(
        "6ea89252-77c4-48b0-be6f-b5c824eaec05",
      ); //boubou
      setUser(user);

      return;
    }
    SharedPreferences.getInstance().then((pref) async {
      final String? userName = pref.getString('userUuid');

      if (userName != null) {
        GgLeapUser user = await getUserByUuid(userName);

        if (!user.locked) {
          setUser(user);
        } else {
          pref.clear();
        }
      }
    });
  }

  Future<bool> login(String username, String password) async {
    isLoading = true;
    notifyListeners();
    final isloginValid = await checkLogin(username, password);

    if (isloginValid) {
      try {
        final newUser = await getUserByUserName(username);

        setUser(newUser);

        isLoading = false;
        notifyListeners();

        return true;
      } catch (e) {
        isLoading = false;
        notifyListeners();
        print(e.toString());
        return false;
      }
    } else {
      isLoading = false;
      notifyListeners();
      print("error login inValid");
      return false;
    }
  }

  Future<String> resetPassword(String userName) async {
    final userHere = await getUserByUserName(userName);

    final response = await http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/users/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
      body: jsonEncode({'Uuid': userHere.uuid}),
    );

    ApiConfig.printCurl(
      method: 'POST',
      url: Uri.parse('${ApiConfig.apiBaseUrl}/users/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
      body: jsonEncode({'Uuid': userHere.uuid}),
    );

    if (response.statusCode == 200) {
      return userHere.email;
    } else {
      print('Failed to create user: ${response.body}');
      return "";
    }
  }

  Future<bool> checkLogin(String username, String password) async {
    const String url =
        'https://api.ggleap.com/production/authorization/user/login';

    // The centerUuid from your working cURL
    const String centerUuid = 'd0e2ed89-b8f0-4d2e-b3e4-be411bf392fd';

    final Map<String, String> headers = {
      'sec-ch-ua-platform': '"Windows"',
      'X-GG-Client': 'DynamicCenterPagesWeb 0.1',
      'Accept': 'application/json, text/plain, */*',
      'sec-ch-ua':
          '"Chromium";v="146", "Not-A.Brand";v="24", "Google Chrome";v="146"',
      'Content-Type': 'application/json',
      'sec-ch-ua-mobile': '?0',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36',
      'Sec-Fetch-Site': 'cross-site',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Dest': 'empty',
      'host': 'api.ggleap.com',
    };

    final String body = jsonEncode({
      "username": username,
      "password": password,
      "centerUuid": centerUuid,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // API Change Detection: Verify if the 'Jwt' token still exists in the response
        bool apiChanged = !data.containsKey('Jwt');
        if (apiChanged) {
          print(
            "API response structure has changed. 'Jwt' token not found in the response.",
          );
          return false;
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> createUser(CreateUserRequest request) async {
    String correlationId = Uuid().v4();
    final response = await http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/users/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
        'X-Correlation-ID': correlationId,
      },
      body: jsonEncode({'User': request.toJson()}),
    );

    ApiConfig.printCurl(
      method: 'POST',
      url: Uri.parse('${ApiConfig.apiBaseUrl}/users/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
      body: jsonEncode({'User': request.toJson()}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userUuid = data['UserUuid'];
      final user = await getUserByUuid(userUuid);
      setUser(user);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('userUsername', user.username);
        prefs.setString('userUuid', userUuid);
        prefs.setString('userEmail', user.email);
      });
    } else {
      print('Failed to create user: ${response.body}');
      errorMessage = jsonDecode(
        response.body,
      )['ValidationFailures'][0]['Message'];
      notifyListeners();
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<GgLeapUser> getUserByUuid(String userUuid) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.apiBaseUrl}/users/user-details?Uuid=$userUuid'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GgLeapUser.fromJson(data['User']);
    } else {
      print('Failed to get user: ${response.body}');
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  Future<GgLeapUser> getUserByUserName(String username) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.apiBaseUrl}/users/user-details?userName=$username',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $currentJWT',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GgLeapUser.fromJson(data['User']);
    } else {
      print('Failed to get user: ${response.body}');
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  String getRankName(double totalSpent) {
    if (totalSpent >= 250) {
      return "VIBE: Eternal";
    } else if (totalSpent >= 150) {
      return "Obsidian";
    } else if (totalSpent >= 100) {
      return "Cobalt";
    } else if (totalSpent >= 50) {
      return "Unranked";
    } else {
      return "None";
    }
  }

  Future<void> getUserRank() async {
    final uri = Uri.https('vibraniumjobooking.com', '/api/user_manager.php');

    final response = await http.post(
      uri,
      body: {'uuid': user!.uuid, 'action': "get_user"},
    );

    print(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      user!.rank = UserRank.fromJson(data['data']);
      notifyListeners();
    } else {
      print('Error: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }

  void updateCollectionStatus(bool hasCollected) {
    user!.rank.hasCollected = hasCollected ? "true" : "false";
    notifyListeners();
  }

  void initLoad() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Future<void> updateUserRank({isUpdatingCollection}) async {
    print("Updating User Rank...");
    isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.https(
        'api.ggleap.com',
        '/production/user_activity_graph_requests',
        {
          'UserUuid': user!.uuid,
          'TimeFrameType': 'LastMonth',
          'UserActivityType': 'MoneySpent',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': '$currentJWT',
          'X-GG-Client': 'CenterAdmin admin.ggleap.com 1.9088.0.9122',
          'Accept': 'application/json, text/plain, */*',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Error: ${response.statusCode}');
        print('Body: ${response.body}');
        return;
      }

      final data = jsonDecode(response.body);
      final payList = data['ActivityGraph']['Values'] as Map<String, dynamic>;

      final totalPays = payList.values.fold<double>(
        0,
        (sum, item) => sum + (item as num).toDouble(),
      );

      final rank = getRankName(totalPays);

      print("Sending hasCollected: ${user!.rank.hasCollected}");

      await updateUserOld(
        uuid: user!.uuid,
        username: user!.username,
        rank: rank,
        reward: rank == "VIBE: Eternal"
            ? "10"
            : rank == "Obsidian"
            ? "7"
            : rank == "Cobalt"
            ? "5"
            : "0",
        hasCollected: (isUpdatingCollection ?? false)
            ? "true"
            : user!.rank.hasCollected,

        totalSpent: totalPays,
      );
    } catch (e) {
      print("updateUserRank error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserOld({
    required String uuid,
    String? rank,
    String? reward,
    String? hasCollected,
    double? totalSpent,
    String? newCollection,
    required String username,
  }) async {
    try {
      final body = <String, String>{'action': 'update_user', 'uuid': uuid};

      if (rank != null) body['rank'] = rank;
      if (reward != null) body['reward'] = reward;
      if (hasCollected != null) body['hasCollected'] = hasCollected;
      if (totalSpent != null) body['totalSpent'] = totalSpent.toString();
      if (newCollection != null) body['newCollection'] = newCollection;
      body['username'] = username;

      print("POST body: $body");

      final response = await http.post(
        Uri.parse('https://vibraniumjobooking.com/api/user_manager.php'),
        body: body,
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Update failed');
      }
    } catch (e) {
      print("updateUserOld error: $e");
      rethrow;
    }
  }

  double getRankProgress(double totalSpent) {
    if (totalSpent >= 250) return 1.0; // Max Rank

    if (totalSpent >= 150) {
      // Progress between Obsidian (150) and VIB (200)
      return (totalSpent - 150) / 50;
    } else if (totalSpent >= 100) {
      // Progress between Titanium (100) and Obsidian (150)
      return (totalSpent - 100) / 50;
    } else if (totalSpent >= 50) {
      // Progress between Cobalt (50) and Titanium (100)
      return (totalSpent - 50) / 50;
    } else {
      // Progress toward Cobalt (0 to 50)
      return totalSpent / 50;
    }
  }

  Future<void> getUserSessions() async {
    final String url =
        '${ApiConfig.apiBaseUrl}/users/gamepasses/list?UserUuid=${user!.uuid}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
        },
      );

      ApiConfig.printCurl(
        method: 'GET',
        url: Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
        },
      );

      if (response.statusCode == 200) {
        // 3. Decode the list of sessions
        final List<dynamic> sessions = jsonDecode(response.body)["Offers"];

        userSesstions = sessions.map((s) => GgSession.fromJson(s)).toList();
        notifyListeners();
      } else {
        print('Failed to get user sessions: ${response.body}');
        throw Exception('Failed to get sessions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching sessions: $e');
      isLoading = false;
      userSesstions = [];
      notifyListeners();
    }
  }

  Future<void> redeemFreeMeal(context) async {
    isLoading = true;
    notifyListeners();
    if (!(user!.rank.rank.toUpperCase() == "VIBE: ETERNAL")) return;

    final response = await http.post(
      Uri.parse('https://vibraniumjobooking.com/api/user_manager.php'),
      body: {'action': 'update_meal', 'uuid': user!.uuid, 'amount': '-1'},
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      await updateUserRank(isUpdatingCollection: false);

      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
      notifyListeners();
      print("Failed to redeem meal: ${data['message']}");
    }
  }
}

class CreateUserRequest {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String dateOfBirth;
  final String? profileImage;

  CreateUserRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dateOfBirth,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'birthdate': dateOfBirth,
      "PostPayLimit": 0,
      'phone': phone,
      'email': email,
      'profileImage': profileImage,
    };
  }

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      username: json['username'],
      password: json['password'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'],
      profileImage: json['profileImage'],
    );
  }
}
