import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/ai_service.dart';
import 'package:pcbuddy/pages/build_preview_page.dart';

class AIBuildPage extends StatefulWidget {
  const AIBuildPage({super.key});

  @override
  State<AIBuildPage> createState() => _AIBuildPageState();
}

class _AIBuildPageState extends State<AIBuildPage> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;

  void _generateBuild() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final token = context.read<AuthProvider>().user?.token ?? '';
      final aiService = AiService(token);
      final generatedParts = await aiService.generateBuild(text);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuildPreviewPage(selectedParts: generatedParts),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Build Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              "Describe your dream PC",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "e.g., 'Gaming PC for Cyberpunk under \$1500' or 'White workstation for video editing'",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter your prompt here...",
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateBuild,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Generate Build", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}