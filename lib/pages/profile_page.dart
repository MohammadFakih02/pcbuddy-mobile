import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = context.read<AuthProvider>().user?.token ?? '';
      
      final remoteUser = await UserService(token).getProfile();
      
      _nameController.text = remoteUser.username; 
      _bioController.text = remoteUser.bio ?? ''; 
      
      setState(() {
        _profilePicUrl = remoteUser.profilePicture;
      });

      if (mounted) {
        await context.read<AuthProvider>().updateLocalUser(
          name: remoteUser.username,
          profilePicture: remoteUser.profilePicture,
          bio: remoteUser.bio
        );
      }
    } catch (e) {
      final localUser = context.read<AuthProvider>().user;
      if (localUser != null) {
        _nameController.text = localUser.username;
        _bioController.text = localUser.bio ?? '';
        setState(() {
          _profilePicUrl = localUser.profilePicture;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final token = context.read<AuthProvider>().user?.token ?? '';
      await UserService(token).updateProfile(
        _nameController.text.trim(),
        _bioController.text.trim(),
      );
      
      if (mounted) {
        await context.read<AuthProvider>().updateLocalUser(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final token = context.read<AuthProvider>().user?.token ?? '';
        
        final newUrl = await UserService(token).uploadProfilePicture(File(pickedFile.path));

        setState(() {
          _profilePicUrl = newUrl;
        });
        
        if (mounted) {
          // Update Global Provider
          await context.read<AuthProvider>().updateLocalUser(
            profilePicture: newUrl,
          );
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  ImageProvider _getImage() {
    if (_profilePicUrl != null && _profilePicUrl!.isNotEmpty) {
      if (_profilePicUrl!.startsWith('http')) {
        return NetworkImage(_profilePicUrl!);
      }
      return NetworkImage('${ApiConstants.baseUrl}$_profilePicUrl');
    }
    return const NetworkImage('https://placehold.co/150x150/png?text=User');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    // REMOVED SCAFFOLD AND APPBAR
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: _getImage(),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
          
          const SizedBox(height: 32),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Display Name",
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 20),

          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Bio",
              hintText: "Tell us about your PC building journey...",
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}