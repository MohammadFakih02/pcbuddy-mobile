import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';
import '../models/sync_models.dart';
import 'database_helper.dart';

class SyncService {
  static const String _lastSyncKey = 'last_sync_timestamp';

  Future<void> syncData({Function(double)? onProgress}) async {
    try {
      onProgress?.call(0.1); 

      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_lastSyncKey);

      String url = '${ApiConstants.baseUrl}/api/sync/reference-data';
      if (lastSync != null) {
        url += '?lastSync=$lastSync';
      }

      print('🔄 Syncing from: $url');

      final response = await http.get(Uri.parse(url));
      
      onProgress?.call(0.3);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final syncResponse = SyncResponse.fromJson(data);

        await _processUpdates(syncResponse, onProgress);

        await prefs.setString(_lastSyncKey, syncResponse.version);
        print('✅ Sync Complete.');
      } else if (response.statusCode == 304) {
        print('✅ Data already up to date.');
      } else {
        print('❌ Sync Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Sync Error: $e');
    } finally {
      onProgress?.call(1.0);
    }
  }

  Future<void> _processUpdates(SyncResponse data, Function(double)? onProgress) async {
    final db = DatabaseHelper.instance;
    double currentProgress = 0.3;
    double step = 0.08;

    Future<void> runBatch(String table, List items, Function batchFunc) async {
      if (items.isNotEmpty) {
        await batchFunc(table, items);
      }
      currentProgress += step;
      onProgress?.call(currentProgress);
    }

    await runBatch('cpus', data.cpus, db.processSyncBatch);
    await runBatch('gpus', data.gpus, db.processSyncBatch);
    await runBatch('memory', data.memory, db.processSyncBatch);
    await runBatch('storage', data.storage, db.processSyncBatch);
    await runBatch('motherboards', data.motherboards, db.processSyncBatch);
    await runBatch('power_supplies', data.powerSupplies, db.processSyncBatch);
    await runBatch('cases', data.cases, db.processSyncBatch);
    
    if (data.prebuilts.isNotEmpty) {
      await db.processPrebuiltBatch(data.prebuilts);
    }
    currentProgress += step;
    onProgress?.call(currentProgress);
  }
}