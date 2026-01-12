import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/models/sync_models.dart';

class AiService {
  final String token;

  AiService(this.token);

  Future<Map<String, HardwareItem?>> generateBuild(String prompt) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/ai/generate-pc'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final data = json['response'];
        return _mapBackendResponseToHardwareMap(data);
      }
    }
    throw Exception('Failed to generate build');
  }

  // 2. Rate PC
  Future<Map<String, dynamic>> rateBuild(Map<String, HardwareItem?> parts) async {
    final body = _createFullSystemRequest(parts);
    
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/ai/rate-pc'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return json['response'];
      }
    }
    return {'cpu': 0, 'gpu': 0, 'overall': 0};
  }

  Future<Map<String, dynamic>> getPerformance(Map<String, HardwareItem?> parts) async {
    final body = {
      'cpu': parts['CPU']?.name ?? 'Unknown CPU',
      'gpu': parts['GPU']?.name ?? 'Unknown GPU',
      'ram': parts['RAM']?.name ?? '16GB RAM',
      'gameName': 'Cyberpunk 2077'
    };

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/ai/performance'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return json['response'];
      }
    }
    return {'low': 0, 'medium': 0, 'high': 0, 'ultra': 0};
  }


  Map<String, HardwareItem?> _mapBackendResponseToHardwareMap(Map<String, dynamic> data) {
    HardwareItem? parse(dynamic item) => item != null ? HardwareItem.fromJson(item) : null;

    return {
      "CPU": parse(data['cpu']),
      "GPU": parse(data['gpu']),
      "Motherboard": parse(data['motherboard']),
      "RAM": parse(data['memory']),
      "Storage": parse(data['storage']),
      "PSU": parse(data['powerSupply']),
      "Case": parse(data['case']),
    };
  }

  Future<List<String>> checkCompatibility(Map<String, HardwareItem?> parts) async {
    final body = _createFullSystemRequest(parts);

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/ai/check-compatibility'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['response'] != null) {
        final issuesList = json['response']['compatibilityIssues'] as List?;
        if (issuesList == null || issuesList.isEmpty) return [];

        return issuesList.map<String>((issue) => issue['issue'].toString()).toList();
      }
    }
    return [];
  }

  Map<String, String> _createFullSystemRequest(Map<String, HardwareItem?> parts) {
    return {
      'cpu': parts['CPU']?.name ?? '',
      'gpu': parts['GPU']?.name ?? '',
      'ram': parts['RAM']?.name ?? '',
      'motherboard': parts['Motherboard']?.name ?? '',
      'psu': parts['PSU']?.name ?? '',
      'case': parts['Case']?.name ?? '',
      'storage': parts['Storage']?.name ?? '',
      'ssd': '',
      'hdd': ''
    };
  }
}