import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';
import '../models/sync_models.dart';
import 'database_helper.dart';

class SyncService {
  static const String _lastSyncKey = 'last_sync_timestamp';

  Future<void> syncData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_lastSyncKey);

      String url = '${ApiConstants.baseUrl}/api/sync/reference-data';
      if (lastSync != null) {
        url += '?lastSync=$lastSync';
      }

      print('🔄 Syncing from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final syncResponse = SyncResponse.fromJson(data);

        await _processUpdates(syncResponse);

        await prefs.setString(_lastSyncKey, syncResponse.version);
        print('✅ Sync Complete. New Version: ${syncResponse.version}');
      } else if (response.statusCode == 304) {
        print('✅ Data already up to date.');
      } else {
        print('❌ Sync Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Sync Error: $e');
    }
  }

  Future<void> _processUpdates(SyncResponse data) async {
    final db = DatabaseHelper.instance;

    await Future.wait([
      if (data.cpus.isNotEmpty) db.processSyncBatch('cpus', data.cpus),
      if (data.gpus.isNotEmpty) db.processSyncBatch('gpus', data.gpus),
      if (data.memory.isNotEmpty) db.processSyncBatch('memory', data.memory),
      if (data.storage.isNotEmpty) db.processSyncBatch('storage', data.storage),
      if (data.motherboards.isNotEmpty) db.processSyncBatch('motherboards', data.motherboards),
      if (data.powerSupplies.isNotEmpty) db.processSyncBatch('power_supplies', data.powerSupplies),
      if (data.cases.isNotEmpty) db.processSyncBatch('cases', data.cases),
    ]);
  }
}