import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String username;
  final String password;
  final String displayName;
  final String role; // 'host' or 'guest'

  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.displayName,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
        'username': username,
        'displayName': displayName,
        'role': role,
      };

  factory UserModel.fromMap(String id, Map<String, dynamic> m) => UserModel(
        id: id,
        username: m['username'] ?? '',
        password: '',
        displayName: m['displayName'] ?? '',
        role: m['role'] ?? 'host',
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class EventModel {
  final String id;
  final String hostId;
  final String groomName;
  final String brideName;
  final DateTime eventDate;
  final String location;
  final String welcomeMessage;
  final String inviteCode;

  EventModel({
    required this.id,
    required this.hostId,
    required this.groomName,
    required this.brideName,
    required this.eventDate,
    required this.location,
    required this.welcomeMessage,
    required this.inviteCode,
  });

  String get fullTitle => '$groomName & $brideName';

  Map<String, dynamic> toMap() => {
        'hostId': hostId,
        'groomName': groomName,
        'brideName': brideName,
        'eventDate': Timestamp.fromDate(eventDate),
        'location': location,
        'welcomeMessage': welcomeMessage,
        'inviteCode': inviteCode,
      };

  factory EventModel.fromMap(String id, Map<String, dynamic> m) => EventModel(
        id: id,
        hostId: m['hostId'] ?? '',
        groomName: m['groomName'] ?? '',
        brideName: m['brideName'] ?? '',
        eventDate: (m['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        location: m['location'] ?? '',
        welcomeMessage: m['welcomeMessage'] ?? '',
        inviteCode: m['inviteCode'] ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class GiftModel {
  final String id;
  final String eventId;
  final String guestName;
  final double amount;
  final DateTime sentAt;
  final String message;

  GiftModel({
    required this.id,
    required this.eventId,
    required this.guestName,
    required this.amount,
    required this.sentAt,
    required this.message,
  });

  Map<String, dynamic> toMap() => {
        'eventId': eventId,
        'guestName': guestName,
        'amount': amount,
        'sentAt': Timestamp.fromDate(sentAt),
        'message': message,
      };

  factory GiftModel.fromMap(String id, Map<String, dynamic> m) => GiftModel(
        id: id,
        eventId: m['eventId'] ?? '',
        guestName: m['guestName'] ?? '',
        amount: (m['amount'] as num?)?.toDouble() ?? 0,
        sentAt: (m['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        message: m['message'] ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class GuestModel {
  final String id;
  final String eventId;
  final String guestName;
  final bool confirmed;
  final bool declined;
  final String apologyMessage;
  final DateTime confirmedAt;

  GuestModel({
    required this.id,
    required this.eventId,
    required this.guestName,
    required this.confirmed,
    this.declined = false,
    this.apologyMessage = '',
    required this.confirmedAt,
  });

  Map<String, dynamic> toMap() => {
        'eventId': eventId,
        'guestName': guestName,
        'confirmed': confirmed,
        'declined': declined,
        'apologyMessage': apologyMessage,
        'confirmedAt': Timestamp.fromDate(confirmedAt),
      };

  factory GuestModel.fromMap(String id, Map<String, dynamic> m) => GuestModel(
        id: id,
        eventId: m['eventId'] ?? '',
        guestName: m['guestName'] ?? '',
        confirmed: m['confirmed'] ?? false,
        declined: m['declined'] ?? false,
        apologyMessage: m['apologyMessage'] ?? '',
        confirmedAt: (m['confirmedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
