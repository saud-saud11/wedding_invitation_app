import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _currentUser;
  EventModel? _currentEvent;

  UserModel? get currentUser => _currentUser;
  EventModel? get currentEvent => _currentEvent;

  bool get isLoggedIn => _currentUser != null;

  bool login(String username, String password) {
    final user = MockDataService.login(username, password);
    if (user != null) {
      _currentUser = user;
      _currentEvent = MockDataService.getEventByHostId(user.id);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _currentEvent = null;
    notifyListeners();
  }

  void refreshEvent() {
    if (_currentUser != null) {
      _currentEvent = MockDataService.getEventByHostId(_currentUser!.id);
      notifyListeners();
    }
  }

  void updateEvent(EventModel event) {
    MockDataService.saveEvent(event);
    _currentEvent = event;
    notifyListeners();
  }
}
