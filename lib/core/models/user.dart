class GgLeapUser {
  final String uuid;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String centerUuid;
  final DateTime? birthdate;
  int timeRemaining;
  final String accountStatus;
  final String? studentId;
  double? pointsBalance;
  final String phone;
  final DateTime? lastSeen;
  final bool deleted;
  final String? notes;
  final double balance;
  final String groupUuid;
  final DateTime? userGroupMembershipEndDate;
  final bool locked;
  final DateTime? registeredAt;
  final double postPayLimit;
  final Map<String, CustomField> userCustomFields;
  final String photoUrl;
  final bool hasReminderNote;
  final UserGroupMembershipTrial? userGroupMembershipTrial;
  String rank;
  double? totalSpentLastMonth;

  GgLeapUser({
    required this.uuid,
    required this.username,
    this.totalSpentLastMonth,

    required this.email,
    required this.firstName,
    required this.rank,
    required this.lastName,
    required this.centerUuid,
    this.birthdate,
    required this.timeRemaining,
    required this.accountStatus,
    this.studentId,
    required this.phone,
    this.lastSeen,
    required this.deleted,
    this.notes,
    required this.balance,
    required this.groupUuid,
    this.userGroupMembershipEndDate,
    required this.locked,
    this.pointsBalance,
    this.registeredAt,
    required this.postPayLimit,
    required this.userCustomFields,
    required this.photoUrl,
    required this.hasReminderNote,
    this.userGroupMembershipTrial,
  });

  factory GgLeapUser.fromJson(Map<String, dynamic> json) {
    // Parsing dynamic keys in UserCustomFields
    final Map<String, CustomField> parsedCustomFields = {};
    if (json['UserCustomFields'] != null) {
      json['UserCustomFields'].forEach((key, value) {
        parsedCustomFields[key] = CustomField.fromJson(value);
      });
    }

    return GgLeapUser(
      uuid: json['Uuid'] ?? '',
      username: json['Username'] ?? '',
      email: json['Email'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      rank: 'Unknown',
      centerUuid: json['CenterUuid'] ?? '',
      birthdate: json['Birthdate'] != null
          ? DateTime.tryParse(json['Birthdate'])
          : null,
      timeRemaining: json['TimeRemaining'] ?? 0,
      accountStatus: json['AccountStatus'] ?? '',
      studentId: json['StudentId'],
      phone: json['Phone'] ?? '',
      lastSeen: json['LastSeen'] != null
          ? DateTime.tryParse(json['LastSeen'])
          : null,
      deleted: json['Deleted'] ?? false,
      notes: json['Notes'],
      balance: (json['Balance'] ?? 0).toDouble(),
      groupUuid: json['GroupUuid'] ?? '',
      userGroupMembershipEndDate: json['UserGroupMembershipEndDate'] != null
          ? DateTime.tryParse(json['UserGroupMembershipEndDate'])
          : null,
      locked: json['Locked'] ?? false,
      registeredAt: json['RegisteredAt'] != null
          ? DateTime.tryParse(json['RegisteredAt'])
          : null,
      postPayLimit: (json['PostPayLimit'] ?? 0).toDouble(),
      userCustomFields: parsedCustomFields,
      photoUrl: json['PhotoUrl'] ?? '',
      hasReminderNote: json['HasReminderNote'] ?? false,
      userGroupMembershipTrial: json['UserGroupMembershipTrial'] != null
          ? UserGroupMembershipTrial.fromJson(json['UserGroupMembershipTrial'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Uuid': uuid,
      'Username': username,
      'Email': email,
      'FirstName': firstName,
      'LastName': lastName,
      'CenterUuid': centerUuid,
      'Birthdate': birthdate?.toIso8601String(),
      'TimeRemaining': timeRemaining,
      'AccountStatus': accountStatus,
      'StudentId': studentId,
      'Phone': phone,
      'LastSeen': lastSeen?.toIso8601String(),
      'Deleted': deleted,
      'Notes': notes,
      'Balance': balance,
      'GroupUuid': groupUuid,
      'UserGroupMembershipEndDate': userGroupMembershipEndDate
          ?.toIso8601String(),
      'Locked': locked,
      'RegisteredAt': registeredAt?.toIso8601String(),
      'PostPayLimit': postPayLimit,
      'UserCustomFields': userCustomFields.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'PhotoUrl': photoUrl,
      'HasReminderNote': hasReminderNote,
      'UserGroupMembershipTrial': userGroupMembershipTrial?.toJson(),
    };
  }
}

class CustomField {
  final String fieldUuid;
  final String fieldType;
  final String fieldName;
  final FieldPermission webAdmin;
  final FieldPermission client;
  final bool isDefault;
  final String serializedValue;

  CustomField({
    required this.fieldUuid,
    required this.fieldType,
    required this.fieldName,
    required this.webAdmin,
    required this.client,
    required this.isDefault,
    required this.serializedValue,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      fieldUuid: json['FieldUuid'] ?? '',
      fieldType: json['FieldType'] ?? '',
      fieldName: json['FieldName'] ?? '',
      webAdmin: FieldPermission.fromJson(json['WebAdmin'] ?? {}),
      client: FieldPermission.fromJson(json['Client'] ?? {}),
      isDefault: json['IsDefault'] ?? false,
      serializedValue: json['SerializedValue'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FieldUuid': fieldUuid,
      'FieldType': fieldType,
      'FieldName': fieldName,
      'WebAdmin': webAdmin.toJson(),
      'Client': client.toJson(),
      'IsDefault': isDefault,
      'SerializedValue': serializedValue,
    };
  }
}

class FieldPermission {
  final String status;
  final bool allowChangeStatus;

  FieldPermission({required this.status, required this.allowChangeStatus});

  factory FieldPermission.fromJson(Map<String, dynamic> json) {
    return FieldPermission(
      status: json['Status'] ?? 'Hidden',
      allowChangeStatus: json['AllowChangeStatus'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'Status': status, 'AllowChangeStatus': allowChangeStatus};
  }
}

class UserGroupMembershipTrial {
  final String groupUuid;
  final DateTime? beginDate;
  final DateTime? endDate;
  final String paymentMethod;

  UserGroupMembershipTrial({
    required this.groupUuid,
    this.beginDate,
    this.endDate,
    required this.paymentMethod,
  });

  factory UserGroupMembershipTrial.fromJson(Map<String, dynamic> json) {
    return UserGroupMembershipTrial(
      groupUuid: json['GroupUuid'] ?? '',
      beginDate: json['BeginDate'] != null
          ? DateTime.tryParse(json['BeginDate'])
          : null,
      endDate: json['EndDate'] != null
          ? DateTime.tryParse(json['EndDate'])
          : null,
      paymentMethod: json['PaymentMethod'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GroupUuid': groupUuid,
      'BeginDate': beginDate?.toIso8601String(),
      'EndDate': endDate?.toIso8601String(),
      'PaymentMethod': paymentMethod,
    };
  }
}
