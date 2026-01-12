import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/models/sync_models.dart';

class ComputerService {
  final String token;

  ComputerService(this.token);

  Future<void> saveBuild(Map<String, HardwareItem?> parts, {bool addToProfile = true}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/computer/save');

    final body = {
      'cpuId': parts['CPU']?.id,
      'gpuId': parts['GPU']?.id,
      'memoryId': parts['RAM']?.id,
      'storageId': parts['Storage']?.id,
      'motherboardId': parts['Motherboard']?.id,
      'powerSupplyId': parts['PSU']?.id,
      'caseId': parts['Case']?.id,
      'addToProfile': addToProfile,
      'rating': null
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save build: ${response.body}');
      }
    } catch (e) {
      // Re-throw to handle in UI
      throw Exception('Network error: $e');
    }
  }
}