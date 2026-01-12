import 'package:flutter/material.dart';
import 'package:pcbuddy/models/ai_models.dart';

class LaptopResultPage extends StatelessWidget {
  final LaptopAssessment assessment;

  const LaptopResultPage({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assessment Result")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            assessment.laptopName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Ratings Row
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreCircle("CPU", assessment.ratings.cpu),
                _buildScoreCircle("GPU", assessment.ratings.gpu),
                _buildScoreCircle("Overall", assessment.ratings.overall, isMain: true),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Specs Card
          Card(
            color: Theme.of(context).cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Specifications (Detected)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(color: Colors.white10),
                  _specRow("CPU", assessment.specs.cpu),
                  _specRow("GPU", assessment.specs.gpu),
                  _specRow("RAM", assessment.specs.ram),
                  _specRow("Screen", assessment.specs.display),
                  _specRow("Storage", assessment.specs.storage),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Thermals
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.thermostat, color: Colors.redAccent, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Thermal Performance", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(assessment.thermalPerformance, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Gaming FPS
          const Text("Estimated Gaming FPS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...assessment.fps.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fpsVal("Low", entry.value.low),
                        _fpsVal("Med", entry.value.medium),
                        _fpsVal("High", entry.value.high),
                        _fpsVal("Ultra", entry.value.ultra),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          
          // Summary (Fixed Padding)
          const Text("AI Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              assessment.summary, 
              style: const TextStyle(height: 1.5, color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _fpsVal(String label, int fps) {
    return Column(
      children: [
        Text("$fps", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildScoreCircle(String label, String score, {bool isMain = false}) {
    String cleanScore = score.split('/')[0]; 
    
    final double value = double.tryParse(cleanScore.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    
    final Color color = value > 7 ? Colors.green : (value > 4 ? Colors.amber : Colors.red);
    final double size = isMain ? 70 : 55;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value / 10,
                backgroundColor: Colors.grey[800],
                color: color,
                strokeWidth: isMain ? 6 : 4,
              ),
              Text(
                "${value.toStringAsFixed(0)}/10",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMain ? 14 : 11)
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}