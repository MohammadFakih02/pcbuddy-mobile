import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/models/auth_user.dart';

class UserService {
  final String token;

  UserService(this.token);

  // Get Profile Data
  Future<AuthUser> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return AuthUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // Update Name/Bio
  Future<void> updateProfile(String name, String bio) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'bio': bio,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  // Upload Profile Picture
  Future<String> uploadProfilePicture(File imageFile) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/users/profile-picture');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    
    // Attach the file
    request.files.add(await http.MultipartFile.fromPath(
      'file', // Matches backend parameter: [FromForm] IFormFile file
      imageFile.path,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['profilePicture']; // Return new URL
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }
}