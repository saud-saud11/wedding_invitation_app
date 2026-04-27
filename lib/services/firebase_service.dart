import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

/// Firebase service — يستبدل MockDataService بالكامل
class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // ── Collections ──────────────────────────────────────────────────────────────
  static CollectionReference get _usersCol => _db.collection('users');
  static CollectionReference get _eventsCol => _db.collection('events');

  // ── Auth ─────────────────────────────────────────────────────────────────────

  static User? get currentFirebaseUser => _auth.currentUser;

  /// تسجيل داعي جديد
  static Future<UserModel?> registerHost({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
    final uid = cred.user!.uid;
    final user = UserModel(
      id: uid,
      username: email,
      password: '',
      displayName: displayName,
      role: 'host',
    );
    await _usersCol.doc(uid).set(user.toMap());
    return user;
  }

  /// تسجيل دخول الداعي
  static Future<UserModel?> loginHost(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email, password: password);
    final uid = cred.user!.uid;
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()! as Map<String, dynamic>);
  }

  /// تسجيل الخروج
  static Future<void> logout() => _auth.signOut();

  /// جلب بيانات المستخدم الحالي
  static Future<UserModel?> getCurrentUser() async {
    final fb = _auth.currentUser;
    if (fb == null) return null;
    final doc = await _usersCol.doc(fb.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()! as Map<String, dynamic>);
  }

  // ── Events ────────────────────────────────────────────────────────────────────

  /// إنشاء أو تحديث مناسبة
  static Future<EventModel> saveEvent(EventModel event) async {
    final data = event.toMap();
    await _eventsCol.doc(event.id).set(data, SetOptions(merge: true));
    return event;
  }

  /// جلب مناسبة الداعي
  static Future<EventModel?> getEventByHostId(String hostId) async {
    final q = await _eventsCol
        .where('hostId', isEqualTo: hostId)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return EventModel.fromMap(q.docs.first.id,
        q.docs.first.data()! as Map<String, dynamic>);
  }

  /// جلب مناسبة برمز الدعوة
  static Future<EventModel?> getEventByInviteCode(String code) async {
    final q = await _eventsCol
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return EventModel.fromMap(q.docs.first.id,
        q.docs.first.data()! as Map<String, dynamic>);
  }

  // ── Gifts ─────────────────────────────────────────────────────────────────────

  /// Stream للعانيات (تحديث لحظي)
  static Stream<List<GiftModel>> giftsStream(String eventId) {
    return _eventsCol
        .doc(eventId)
        .collection('gifts')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GiftModel.fromMap(d.id, d.data()))
            .toList());
  }

  /// إضافة عانية
  static Future<void> addGift(GiftModel gift) async {
    await _eventsCol
        .doc(gift.eventId)
        .collection('gifts')
        .doc(gift.id)
        .set(gift.toMap());
  }

  /// مجموع العانيات
  static Future<double> getTotalGifts(String eventId) async {
    final snap = await _eventsCol.doc(eventId).collection('gifts').get();
    return snap.docs.fold<double>(
        0.0, (total, d) => total + ((d.data()['amount'] as num?)?.toDouble() ?? 0));
  }

  // ── Guests ────────────────────────────────────────────────────────────────────

  /// Stream للمدعوين (تحديث لحظي)
  static Stream<List<GuestModel>> guestsStream(String eventId) {
    return _eventsCol
        .doc(eventId)
        .collection('guests')
        .orderBy('confirmedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GuestModel.fromMap(d.id, d.data()))
            .toList());
  }

  /// إضافة أو تحديث ضيف
  static Future<void> addGuest(GuestModel guest) async {
    // منع التكرار بنفس الاسم
    final existing = await _eventsCol
        .doc(guest.eventId)
        .collection('guests')
        .where('guestName', isEqualTo: guest.guestName)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update(guest.toMap());
    } else {
      await _eventsCol
          .doc(guest.eventId)
          .collection('guests')
          .doc(guest.id)
          .set(guest.toMap());
    }
  }

  /// عدد المؤكدين
  static Future<int> getConfirmedCount(String eventId) async {
    final snap = await _eventsCol
        .doc(eventId)
        .collection('guests')
        .where('confirmed', isEqualTo: true)
        .where('declined', isEqualTo: false)
        .get();
    return snap.docs.length;
  }
}
