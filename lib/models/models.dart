// ─── Models ─────────────────────────────────────────────────────────────────

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
}

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
}

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
}

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
}
