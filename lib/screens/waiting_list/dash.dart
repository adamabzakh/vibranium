import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VibraniumCategoryStatus extends StatefulWidget {
  const VibraniumCategoryStatus({super.key});

  @override
  State<VibraniumCategoryStatus> createState() =>
      _VibraniumCategoryStatusState();
}

class _VibraniumCategoryStatusState extends State<VibraniumCategoryStatus> {
  Map<String, dynamic>? dashboardData;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Keeps the category numbers live without refreshing the whole app
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchData(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://vibraniumjobooking.com/api/dashboard_data.php'),
      );
      if (response.statusCode == 200) {
        setState(() {
          dashboardData = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Update failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dashboardData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFAB63FF)),
      );
    }

    // Extracting the tiers map directly from your PHP JSON structure
    final Map<String, dynamic> tiers = dashboardData!['tiers'] ?? {};

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small Brand Title
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            "STATION AVAILABILITY",
            style: TextStyle(
              color: Color(0xFF9F90BB),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),

        // The Category Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0918).withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF8E49E6).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFAB63FF).withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tiers.entries.map((entry) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      color: Color(0xFF2FD5FF), // Your Neon Cyan
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
