import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _currentUser;
  EventModel? _currentEvent;
  bool _loading = false;
  String? _errorMsg;

  UserModel? get currentUser => _currentUser;
  EventModel? get currentEvent => _currentEvent;
  bool get isLoggedIn => _currentUser != null;
  bool get loading => _loading;
  String? get errorMsg => _errorMsg;

  /// استعادة الجلسة عند فتح التطبيق
  Future<void> restoreSession() async {
    _loading = true;
    notifyListeners();
    try {
      final user = await FirebaseService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _currentEvent = await FirebaseService.getEventByHostId(user.id);
      }
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  /// تسجيل دخول بالبريد وكلمة المرور
  Future<bool> login(String email, String password) async {
    _errorMsg = null;
    _loading = true;
    notifyListeners();
    try {
      final user = await FirebaseService.loginHost(email, password);
      if (user != null) {
        _currentUser = user;
        _currentEvent = await FirebaseService.getEventByHostId(user.id);
        notifyListeners();
        return true;
      }
      _errorMsg = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      return false;
    } catch (e) {
      _errorMsg = 'خطأ في تسجيل الدخول: ${_parseError(e)}';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// إنشاء حساب داعي جديد
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _errorMsg = null;
    _loading = true;
    notifyListeners();
    try {
      final user = await FirebaseService.registerHost(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (user != null) {
        _currentUser = user;
        _currentEvent = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMsg = 'خطأ في إنشاء الحساب: ${_parseError(e)}';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await FirebaseService.logout();
    _currentUser = null;
    _currentEvent = null;
    notifyListeners();
  }

  Future<void> refreshEvent() async {
    if (_currentUser == null) return;
    _currentEvent = await FirebaseService.getEventByHostId(_currentUser!.id);
    notifyListeners();
  }

  Future<void> updateEvent(EventModel event) async {
    await FirebaseService.saveEvent(event);
    _currentEvent = event;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('user-not-found')) return 'المستخدم غير موجود';
    if (msg.contains('wrong-password')) return 'كلمة المرور غير صحيحة';
    if (msg.contains('email-already-in-use')) return 'البريد مستخدم مسبقاً';
    if (msg.contains('invalid-email')) return 'البريد الإلكتروني غير صحيح';
    if (msg.contains('weak-password')) return 'كلمة المرور ضعيفة جداً';
    return 'حدث خطأ غير متوقع';
  }
}
