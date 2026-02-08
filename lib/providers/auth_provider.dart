import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../models/sync_models.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../services/computer_service.dart';

class AuthProvider with ChangeNotifier {
  AuthUser? _user;
  Map<String, HardwareItem?>? _savedPC;

  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  
  bool _isLoading = false;
  bool _isSyncing = false;
  double _syncProgress = 0.0;

  AuthUser? get user => _user;
  Map<String, HardwareItem?>? get savedPC => _savedPC;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  double get syncProgress => _syncProgress;

  Future<void> refreshSavedPC() async {
    if (_user == null) return;
    try {
      final computerService = ComputerService(_user!.token);
      _savedPC = await computerService.getUserPC(_user!.id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing PC: $e");
    }
  }

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
      refreshSavedPC();
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
      refreshSavedPC();

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
      refreshSavedPC();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    _savedPC = null;
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