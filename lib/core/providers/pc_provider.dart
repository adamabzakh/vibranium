import 'dart:convert';

import 'package:app/core/api/config.dart';
import 'package:app/core/models/pc.dart';
import 'package:app/core/models/pc_formatted.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Label → categoryId mapping.
// The groups API returns { uuid, label } where label is a human-readable name.
// Adjust the keys here to match whatever your backend actually sends.
// ---------------------------------------------------------------------------
const Map<String, String> _kLabelToCategoryId = {
  'normal': 'normal',
  'standard': 'normal',
  'gaming': 'normal',
  'stage': 'stage',
  'stream': 'stage',
  'showcase': 'stage',
  'vip': 'vip',
  'premium': 'vip',
  'master vip': 'master_vip',
  'master_vip': 'master_vip',
  'master': 'master_vip',
  'top tier': 'master_vip',
};

String _resolveCategoryId(String label) {
  final key = label.trim().toLowerCase();
  return _kLabelToCategoryId[key] ?? key;
}

// ---------------------------------------------------------------------------

class PcGroup {
  const PcGroup({required this.uuid, required this.label});

  final String uuid;
  final String label;

  factory PcGroup.fromJson(Map<String, dynamic> json) =>
      PcGroup(uuid: json['uuid'] as String, label: json['label'] as String);

  String get categoryId => _resolveCategoryId(label);
}

// ---------------------------------------------------------------------------

class PcProvider extends ChangeNotifier {
  List<GgMachine> pcs = [];
  List<GgMachine> currentSelectedPcs = [];
  List<PcGroup> groups = [];
  List consoles = [];

  List<UnifiedPC> currentFpcs = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchConsoles() async {
    final url = Uri.parse('${ApiConfig.apiBaseUrl}/consoles/get-all');
    final response = await http.get(url, headers: _authHeaders);
    if (response.statusCode == 200) {
      final preFilter = jsonDecode(response.body)['Devices'];

      consoles = preFilter
          .where((element) => element['Type'] == "Ps5")
          .toList();
      notifyListeners();
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to fetch consoles: ${response.body}');
    }
  }

  Future<void> getAllPCServerSide(String area) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _fetchGroups();
      await fetchMachines();
      await getPcsPositionsFromServer(area);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('PcProvider error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchGroups() async {
    groups = [
      PcGroup(uuid: "8e1f47f9-415d-41a4-8fdd-13ad31503164", label: "Normal"),
      PcGroup(uuid: "62934eb8-b980-490f-adf8-3c2abcd6dd4a", label: "Vip"),
      PcGroup(uuid: "b8a2e990-d142-46b2-b183-fd84741851dc", label: "Mvip"),
    ];
  }

  Future<void> fetchMachines() async {
    final url = Uri.parse('${ApiConfig.apiBaseUrl}/machines/get-all');

    ApiConfig.printCurl(method: 'GET', url: url, headers: _authHeaders);

    final response = await http.get(url, headers: _authHeaders);

    if (response.statusCode == 200) {
      final List<dynamic> raw = jsonDecode(response.body)['Machines'];
      pcs = raw.map((s) {
        return GgMachine.fromJson(s);
      }).toList();
    } else {
      throw Exception('Failed to fetch machines: ${response.body}');
    }
  }

  Future<void> getPcsPositionsFromServer(String area) async {
    final url = Uri.parse(
      'https://vibraniumjobooking.com/api/get_pcs.php?area=$area',
    );

    ApiConfig.printCurl(method: 'GET', url: url, headers: _authHeaders);

    final response = await http.get(url, headers: _authHeaders);

    if (response.statusCode == 200) {
      currentSelectedPcs.clear();
      final List pcsWithPositions = jsonDecode(response.body)['machines'];

      for (var pc in pcs) {
        final currentPcPosition = pcsWithPositions
            .cast<Map<String, dynamic>>()
            .firstWhere((element) {
              final apiName = (element['ggleap_name'] ?? '')
                  .toString()
                  .replaceAll("-", "")
                  .toLowerCase();
              final pcName = (pc.name ?? '')
                  .toString()
                  .replaceAll("-", "")
                  .toLowerCase();

              if (apiName == pcName) {
                print(apiName);
                print(pcName);
              }

              return apiName == pcName;
            }, orElse: () => {});

        // Skip if not found
        if (currentPcPosition.isEmpty) {
          continue;
        }

        // Assign position safely
        pc.postion = Offset(
          (currentPcPosition['x'] as num).toDouble(),
          (currentPcPosition['y'] as num).toDouble(),
        );

        currentSelectedPcs.add(pc);
      }

      // Notify once after loop
      notifyListeners();
    } else {
      print("Failed to read");
    }
  }

  int getOnlyNumber(String input) {
    // \d+ matches one or more digits
    final RegExp regExp = RegExp(r'\d+');
    final match = regExp.firstMatch(input);

    // Return the matched number, or an empty string if no number is found
    return int.parse((match?.group(0) ?? 0).toString());
  }

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $currentJWT',
  };
}
