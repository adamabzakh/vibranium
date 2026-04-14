import 'package:flutter/services.dart';

class GgMachine {
  final String? uuid;
  final String? name;
  final String? macAddress;
  final bool? testMachine;
  final bool? fakeMachine;
  final bool? ggRockVm;
  final String? groupUuid;
  final String? state;
  final DateTime? lastUpdate;
  final DateTime? lastStateUpdate;
  final List<OpenedWindow>? openedWindows;
  final String? userUuid;
  final bool? hasGuest;
  final String? desiredVersion;
  final String? currentVersion;
  final bool? isLocked;
  final bool? lockedByAdmin;
  final String? adminLockMessage;
  final bool? lockedByPlayer;
  final DateTime? scheduledLockTime;
  final String? scheduledLockMessage;
  final String? securityPolicyGroupUuid;
  Offset? postion;

  GgMachine({
    this.uuid,
    this.name,
    this.postion,
    this.macAddress,
    this.testMachine,
    this.fakeMachine,
    this.ggRockVm,
    this.groupUuid,
    this.state,
    this.lastUpdate,
    this.lastStateUpdate,
    this.openedWindows,
    this.userUuid,
    this.hasGuest,
    this.desiredVersion,
    this.currentVersion,
    this.isLocked,
    this.lockedByAdmin,
    this.adminLockMessage,
    this.lockedByPlayer,
    this.scheduledLockTime,
    this.scheduledLockMessage,
    this.securityPolicyGroupUuid,
  });

  factory GgMachine.fromJson(Map<String, dynamic> json) {
    return GgMachine(
      uuid: json['Uuid'],
      name: json['Name'],
      macAddress: json['MacAddress'],
      testMachine: json['TestMachine'],
      fakeMachine: json['FakeMachine'],
      ggRockVm: json['GgRockVm'],
      groupUuid: json['GroupUuid'],
      state: json['State'],
      lastUpdate: json['LastUpdate'] != null
          ? DateTime.tryParse(json['LastUpdate'])
          : null,
      lastStateUpdate: json['LastStateUpdate'] != null
          ? DateTime.tryParse(json['LastStateUpdate'])
          : null,
      openedWindows: (json['OpenedWindows'] as List?)
          ?.map((e) => OpenedWindow.fromJson(e))
          .toList(),
      userUuid: json['UserUuid'],
      hasGuest: json['HasGuest'],
      desiredVersion: json['DesiredVersion'],
      currentVersion: json['CurrentVersion'],
      isLocked: json['IsLocked'],
      lockedByAdmin: json['LockedByAdmin'],
      adminLockMessage: json['AdminLockMessage'],
      lockedByPlayer: json['LockedByPlayer'],
      scheduledLockTime: json['ScheduledLockTime'] != null
          ? DateTime.tryParse(json['ScheduledLockTime'])
          : null,
      scheduledLockMessage: json['ScheduledLockMessage'],
      securityPolicyGroupUuid: json['SecurityPolicyGroupUuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Uuid': uuid,
      'Name': name,
      'MacAddress': macAddress,
      'TestMachine': testMachine,
      'FakeMachine': fakeMachine,
      'GgRockVm': ggRockVm,
      'GroupUuid': groupUuid,
      'State': state,
      'LastUpdate': lastUpdate?.toIso8601String(),
      'LastStateUpdate': lastStateUpdate?.toIso8601String(),
      'OpenedWindows': openedWindows?.map((e) => e.toJson()).toList(),
      'UserUuid': userUuid,
      'HasGuest': hasGuest,
      'DesiredVersion': desiredVersion,
      'CurrentVersion': currentVersion,
      'IsLocked': isLocked,
      'LockedByAdmin': lockedByAdmin,
      'AdminLockMessage': adminLockMessage,
      'LockedByPlayer': lockedByPlayer,
      'ScheduledLockTime': scheduledLockTime?.toIso8601String(),
      'ScheduledLockMessage': scheduledLockMessage,
      'SecurityPolicyGroupUuid': securityPolicyGroupUuid,
    };
  }
}

class OpenedWindow {
  final String? title;
  final String? handle;

  OpenedWindow({this.title, this.handle});

  factory OpenedWindow.fromJson(Map<String, dynamic> json) {
    return OpenedWindow(title: json['Title'], handle: json['Handle']);
  }

  Map<String, dynamic> toJson() {
    return {'Title': title, 'Handle': handle};
  }
}
