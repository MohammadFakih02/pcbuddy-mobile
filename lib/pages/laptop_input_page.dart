import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/ai_service.dart';
import 'package:pcbuddy/pages/laptop_result_page.dart';

class LaptopInputPage extends StatefulWidget {
  const LaptopInputPage({super.key});

  @override
  State<LaptopInputPage> createState() => _LaptopInputPageState();
}

class _LaptopInputPageState extends State<LaptopInputPage> {
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _isLoading = false;

  void _analyzeLaptop() async {
    if (_nameController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final token = context.read<AuthProvider>().user?.token ?? '';
      final aiService = AiService(token);

      final result = await aiService.assessLaptop(
        _nameController.text.trim(),
        _detailsController.text.trim(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LaptopResultPage(assessment: result)),
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(
                Icons.laptop_chromebook,
                size: 80,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                "Check a Laptop's Performance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Enter a model name to get specs, thermal ratings, and gaming FPS estimates.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Laptop Name (Required)",
                  hintText: "e.g. ASUS Zephyrus G14 2024",
                  prefixIcon: Icon(Icons.computer),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _detailsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Additional Details (Optional)",
                  hintText: "e.g. RTX 4060 version, 32GB RAM",
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _analyzeLaptop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth:
                                2.5,
                          ),
                        )
                      : const Text(
                          "Generate Build",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
