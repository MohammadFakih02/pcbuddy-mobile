import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/user_service.dart';
import 'package:pcbuddy/services/computer_service.dart';
import 'package:pcbuddy/models/sync_models.dart';
import 'package:pcbuddy/pages/build_page.dart';

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
  
  Map<String, HardwareItem?>? _userPC;
  bool _isLoadingPC = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadUserPC();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = context.read<AuthProvider>().user?.token ?? '';
      
      try {
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
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserPC() async {
    setState(() => _isLoadingPC = true);
    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) return;

      final service = ComputerService(user.token);
      final pc = await service.getUserPC(user.id);

      if (mounted) {
        setState(() {
          _userPC = pc;
        });
      }
    } catch (e) {
      debugPrint("Error loading PC: $e");
    } finally {
      if (mounted) setState(() => _isLoadingPC = false);
    }
  }

  void _editBuild() async {
    if (_userPC == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PCBuilderPage(initialParts: _userPC),
      ),
    );
    _loadUserPC();
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

          Align(
            alignment: Alignment.centerLeft, 
            child: Text("My Saved Build", 
              style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)
            )
          ),
          const SizedBox(height: 10),
          
          if (_isLoadingPC)
            const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ))
          else if (_userPC != null)
            _buildPcCard(context)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: const Text(
                "No build saved yet. Go create one!", 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.grey)
              ),
            ),

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

  Widget _buildPcCard(BuildContext context) {
    double total = _userPC!.values
        .where((p) => p != null)
        .fold(0, (sum, p) => sum + p!.price);
        
    String cpuName = _userPC!['CPU']?.name ?? "No CPU";
    String gpuName = _userPC!['GPU']?.name ?? "No GPU";

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(10)
          ),
          child: const Icon(Icons.computer, color: Colors.blueAccent),
        ),
        title: const Text("Custom PC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("$cpuName\n$gpuName", 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(fontSize: 12)
            ),
            const SizedBox(height: 4),
            Text("\$${total.toStringAsFixed(2)}", 
              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          ),
          onPressed: _editBuild, 
          child: const Text("Edit", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}