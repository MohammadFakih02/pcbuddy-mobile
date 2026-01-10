import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart'; // Import

class AuthProvider with ChangeNotifier {
  AuthUser? _user;
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  bool _isLoading = false;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> tryAutoLogin() async {
    final savedUser = await DatabaseHelper.instance.getUser();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
      _syncService.syncData(); 
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authUser = await _authService.login(email, password);
      _user = authUser;
      await DatabaseHelper.instance.saveUser(authUser);
      
      // Trigger Sync
      _syncService.syncData();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final authUser = await _authService.register(username, email, password);
      _user = authUser;
      await DatabaseHelper.instance.saveUser(authUser);
      _syncService.syncData();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await DatabaseHelper.instance.deleteUser();
    notifyListeners();
  }
}