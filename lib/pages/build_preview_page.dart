import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/models/sync_models.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/ai_service.dart';

class BuildPreviewPage extends StatefulWidget {
  final Map<String, HardwareItem?> selectedParts;

  const BuildPreviewPage({super.key, required this.selectedParts});

  @override
  State<BuildPreviewPage> createState() => _BuildPreviewPageState();
}

class _BuildPreviewPageState extends State<BuildPreviewPage> {
  late Future<Map<String, dynamic>> _aiAnalysisFuture;

  @override
  void initState() {
    super.initState();
    _aiAnalysisFuture = _fetchAIAnalysis();
  }

  Future<Map<String, dynamic>> _fetchAIAnalysis() async {
    final token = context.read<AuthProvider>().user?.token ?? '';
    final aiService = AiService(token);

    // Run parallel requests for speed
    final results = await Future.wait([
      aiService.rateBuild(widget.selectedParts),
      aiService.getPerformance(widget.selectedParts),
    ]);

    return {
      'ratings': results[0],
      'fps': results[1],
    };
  }

  double _calculateTotal() {
    return widget.selectedParts.values
        .where((p) => p != null)
        .fold(0.0, (sum, p) => sum + p!.price);
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();

    return Scaffold(
      appBar: AppBar(title: const Text("Build Summary")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Total Price
          Text(
            "Total Price: \$${total.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 2. AI Analysis Section
          FutureBuilder<Map<String, dynamic>>(
            future: _aiAnalysisFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Card(
                  color: Colors.red.withOpacity(0.1),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Could not load AI Analysis"),
                  ),
                );
              }

              final ratings = snapshot.data!['ratings'];
              final fps = snapshot.data!['fps'];

              return Column(
                children: [
                  _buildRatingCard(ratings),
                  const SizedBox(height: 16),
                  _buildFpsCard(fps),
                ],
              );
            },
          ),

          const SizedBox(height: 20),
          const Text("Components", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // 3. Parts List
          ...widget.selectedParts.entries.map((entry) {
            final part = entry.value;
            if (part == null) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: _buildPartImage(part.imageUrl),
                title: Text(part.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(entry.key),
                trailing: Text("\$${part.price.toStringAsFixed(2)}"),
              ),
            );
          }),
          
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement Save to Profile API logic here
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Build Saved to Profile!")));
            }, 
            icon: const Icon(Icons.save), 
            label: const Text("Save to Profile"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> ratings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _scoreCircle("CPU", ratings['cpu']),
          _scoreCircle("GPU", ratings['gpu']),
          _scoreCircle("Overall", ratings['overall']),
        ],
      ),
    );
  }

  Widget _scoreCircle(String label, dynamic score) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: (score is num ? score : 0) / 10,
              backgroundColor: Colors.grey[800],
              color: Colors.amber,
              strokeWidth: 6,
            ),
            Text(
              "${score ?? '?'}", 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFpsCard(Map<String, dynamic> fps) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Estimated Performance (1080p)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Cyberpunk 2077", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _fpsMetric("Low", fps['low']),
                _fpsMetric("Med", fps['medium']),
                _fpsMetric("High", fps['high']),
                _fpsMetric("Ultra", fps['ultra']),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _fpsMetric(String label, dynamic val) {
    return Column(
      children: [
        Text("$val", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPartImage(String? url) {
    if (url == null || url.isEmpty) return const Icon(Icons.hardware);
    final fullUrl = url.startsWith('http') ? url : '${ApiConstants.baseUrl}$url';
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(fullUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image)),
    );
  }
}