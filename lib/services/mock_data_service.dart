import '../models/models.dart';

class MockDataService {
  // ── Demo Users ──────────────────────────────────────────────────────────────
  static final List<UserModel> demoUsers = [
    const UserModel(
      id: 'host_001',
      username: 'host1',
      password: '1234',
      displayName: 'محمد الأحمد',
      role: 'host',
    ),
    const UserModel(
      id: 'host_002',
      username: 'host2',
      password: '1234',
      displayName: 'خالد العمري',
      role: 'host',
    ),
  ];

  // ── Events ───────────────────────────────────────────────────────────────────
  static final List<EventModel> _events = [
    EventModel(
      id: 'event_001',
      hostId: 'host_001',
      groomName: 'أحمد',
      brideName: 'فاطمة',
      eventDate: DateTime(2026, 6, 15, 20, 0),
      location: 'قاعة الفردوس - الرياض',
      welcomeMessage: 'نسعد بدعوتكم لحفل زفاف نجلينا',
      inviteCode: 'WEDDING_001',
    ),
    EventModel(
      id: 'event_002',
      hostId: 'host_002',
      groomName: 'سعد',
      brideName: 'نورة',
      eventDate: DateTime(2026, 7, 20, 20, 30),
      location: 'قاعة النخيل - جدة',
      welcomeMessage: 'يسرنا دعوتكم لمشاركتنا فرحة زفاف ابننا',
      inviteCode: 'WEDDING_002',
    ),
  ];

  // ── Gifts ────────────────────────────────────────────────────────────────────
  static final List<GiftModel> _gifts = [
    GiftModel(
      id: 'g1', eventId: 'event_001', guestName: 'عبدالله السالم',
      amount: 500, sentAt: DateTime.now().subtract(const Duration(days: 2)),
      message: 'بالرفاه والبنين',
    ),
    GiftModel(
      id: 'g2', eventId: 'event_001', guestName: 'سارة المطيري',
      amount: 300, sentAt: DateTime.now().subtract(const Duration(days: 1)),
      message: 'ألف مبروك',
    ),
    GiftModel(
      id: 'g3', eventId: 'event_001', guestName: 'فيصل الزهراني',
      amount: 1000, sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      message: 'مبروك وبالتوفيق',
    ),
    GiftModel(
      id: 'g4', eventId: 'event_002', guestName: 'محمد القحطاني',
      amount: 750, sentAt: DateTime.now().subtract(const Duration(days: 3)),
      message: 'تهانينا الحارة',
    ),
  ];

  // ── Guests ───────────────────────────────────────────────────────────────────
  static final List<GuestModel> _guests = [
    GuestModel(
      id: 'gu1', eventId: 'event_001', guestName: 'عبدالله السالم',
      confirmed: true, declined: false, apologyMessage: '',
      confirmedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GuestModel(
      id: 'gu2', eventId: 'event_001', guestName: 'سارة المطيري',
      confirmed: true, declined: false, apologyMessage: '',
      confirmedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GuestModel(
      id: 'gu3', eventId: 'event_001', guestName: 'ريم العنزي',
      confirmed: false, declined: true,
      apologyMessage: 'آسف لوجود ارتباط سابق، بالرفاه والبنين',
      confirmedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    GuestModel(
      id: 'gu4', eventId: 'event_001', guestName: 'نواف الشمري',
      confirmed: false, declined: false, apologyMessage: '',
      confirmedAt: DateTime.now(),
    ),
    GuestModel(
      id: 'gu5', eventId: 'event_002', guestName: 'محمد القحطاني',
      confirmed: true, declined: false, apologyMessage: '',
      confirmedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];


  // ── Public Methods ───────────────────────────────────────────────────────────

  static UserModel? login(String username, String password) {
    try {
      return demoUsers.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  static EventModel? getEventByHostId(String hostId) {
    try {
      return _events.firstWhere((e) => e.hostId == hostId);
    } catch (_) {
      return null;
    }
  }

  static EventModel? getEventByInviteCode(String code) {
    try {
      return _events.firstWhere((e) => e.inviteCode == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  static List<GiftModel> getGiftsForEvent(String eventId) {
    return _gifts.where((g) => g.eventId == eventId).toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  static double getTotalGifts(String eventId) {
    return getGiftsForEvent(eventId).fold(0, (sum, g) => sum + g.amount);
  }

  static List<GuestModel> getGuestsForEvent(String eventId) {
    return _guests.where((g) => g.eventId == eventId).toList();
  }

  static int getConfirmedCount(String eventId) {
    return getGuestsForEvent(eventId).where((g) => g.confirmed && !g.declined).length;
  }

  static int getDeclinedCount(String eventId) {
    return getGuestsForEvent(eventId).where((g) => g.declined).length;
  }

  static void addGift(GiftModel gift) {
    _gifts.add(gift);
  }

  static void addGuest(GuestModel guest) {
    // Check not already in list
    final exists = _guests.any(
      (g) => g.eventId == guest.eventId && g.guestName == guest.guestName,
    );
    if (!exists) {
      _guests.add(guest);
    }
  }

  static void saveEvent(EventModel event) {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx >= 0) {
      _events[idx] = event;
    } else {
      _events.add(event);
    }
  }
}
