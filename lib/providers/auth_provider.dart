import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';

class AuthProvider with ChangeNotifier {
  AuthUser? _user;
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  
  bool _isLoading = false;
  bool _isSyncing = false;
  double _syncProgress = 0.0;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  double get syncProgress => _syncProgress;

  Future<void> _runSync() async {
    _isSyncing = true;
    _syncProgress = 0.0;
    notifyListeners();

    await _syncService.syncData(onProgress: (progress) {
      _syncProgress = progress;
      notifyListeners();
    });

    if (_syncProgress >= 1.0) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final savedUser = await DatabaseHelper.instance.getUser();
    if (savedUser != null) {
      _user = savedUser;
      notifyListeners();
      _runSync();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authUser = await _authService.login(email, password);
      _user = authUser;
      await DatabaseHelper.instance.saveUser(authUser);
      
      _isLoading = false;
      notifyListeners();

      await _runSync(); 

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final authUser = await _authService.register(username, email, password);
      _user = authUser;
      await DatabaseHelper.instance.saveUser(authUser);
      
      _isLoading = false;
      notifyListeners();

      await _runSync();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    await DatabaseHelper.instance.deleteUser();
    notifyListeners();
  }

Future<void> updateLocalUser({String? name, String? profilePicture, String? bio}) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      username: name,
      profilePicture: profilePicture,
      bio: bio,
    );
    await DatabaseHelper.instance.saveUser(_user!);
    notifyListeners();
  }
}