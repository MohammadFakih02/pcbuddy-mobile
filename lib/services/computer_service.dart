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
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, HardwareItem?>?> getUserPC(int userId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/computer/user-pc/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        HardwareItem? parse(dynamic item) {
          if (item == null) return null;
          return HardwareItem.fromJson(item);
        }

        return {
          "CPU": parse(data['cpu']),
          "GPU": parse(data['gpu']),
          "Motherboard": parse(data['motherboard']),
          "RAM": parse(data['memory']),
          "Storage": parse(data['storage']),
          "PSU": parse(data['powerSupply']),
          "Case": parse(data['case']),
        };
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load PC: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }
}