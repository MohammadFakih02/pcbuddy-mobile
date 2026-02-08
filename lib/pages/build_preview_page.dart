import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/models/sync_models.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/ai_service.dart';
import 'package:pcbuddy/services/computer_service.dart';
import 'package:pcbuddy/pages/part_details_page.dart';

class BuildPreviewPage extends StatefulWidget {
  final Map<String, HardwareItem?> selectedParts;

  const BuildPreviewPage({super.key, required this.selectedParts});

  @override
  State<BuildPreviewPage> createState() => _BuildPreviewPageState();
}

class _BuildPreviewPageState extends State<BuildPreviewPage> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _analysisFuture;
  late TabController _tabController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _analysisFuture = _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchAllData() async {
    final token = context.read<AuthProvider>().user?.token ?? '';
    final aiService = AiService(token);

    final results = await Future.wait([
      aiService.checkCompatibility(widget.selectedParts),
      aiService.rateBuild(widget.selectedParts),
      aiService.getPerformance(widget.selectedParts),
    ]);

    return {
      'issues': results[0] as List<String>,
      'ratings': results[1],
      'fps': results[2],
    };
  }

  Future<void> _saveToProfile() async {
    setState(() => _isSaving = true);
    try {
      final token = context.read<AuthProvider>().user?.token ?? '';
      await ComputerService(token).saveBuild(widget.selectedParts);
      
      if (!mounted) return;

      await context.read<AuthProvider>().refreshSavedPC();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Build saved successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.selectedParts.values
        .where((p) => p != null)
        .fold(0.0, (sum, p) => sum + p!.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Build Analysis"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Overview & Performance"),
            Tab(text: "Parts List"),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("AI is analyzing your build...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Analysis Failed: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final issues = data['issues'] as List<String>;
          final ratings = data['ratings'];
          final fps = data['fps'];

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Estimate:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(issues, ratings, fps),
                    _buildPartsListTab(),
                  ],
                ),
              ),

              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveToProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.cloud_upload),
                      label: Text(_isSaving ? "Saving..." : "Save to Profile"),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(List<String> issues, Map<String, dynamic> ratings, Map<String, dynamic> fps) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCompatibilityCard(issues),
        const SizedBox(height: 20),

        const Text("AI Ratings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
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
              _buildScoreCircle("CPU", ratings['cpu']),
              _buildScoreCircle("GPU", ratings['gpu']),
              _buildScoreCircle("Overall", ratings['overall'], isMain: true),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text("Gaming Performance (1080p)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade900.withValues(alpha: 0.5), Theme.of(context).cardColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.videogame_asset, color: Colors.purpleAccent),
                  const SizedBox(width: 10),
                  Text("Cyberpunk 2077", style: TextStyle(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFpsMetric("Low", fps['low']),
                  _buildFpsMetric("Medium", fps['medium']),
                  _buildFpsMetric("High", fps['high']),
                  _buildFpsMetric("Ultra", fps['ultra']),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartsListTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: widget.selectedParts.entries.map((entry) {
        final part = entry.value;
        if (part == null) return const SizedBox.shrink();
        final heroTag = 'part_${entry.key}_${part.id}';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPartImage(part.imageUrl),
              ),
            ),
            title: Text(part.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text(entry.key, style: const TextStyle(color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "\$${part.price.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white30, size: 20)
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PartDetailsPage(
                    category: entry.key,
                    item: part,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompatibilityCard(List<String> issues) {
    bool isCompatible = issues.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompatible ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompatible ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompatible ? Icons.check_circle : Icons.warning_amber_rounded,
                color: isCompatible ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 10),
              Text(
                isCompatible ? "Compatibility Verified" : "Potential Issues Found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCompatible ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          if (!isCompatible) ...[
            const SizedBox(height: 10),
            ...issues.map((issue) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(color: Colors.orange)),
                  Expanded(child: Text(issue, style: const TextStyle(fontSize: 13, color: Colors.white70))),
                ],
              ),
            )),
          ]
        ],
      ),
    );
  }

  Widget _buildScoreCircle(String label, dynamic score, {bool isMain = false}) {
    final double value = (score is num ? score.toDouble() : 0.0);
    final Color color = value > 7 ? Colors.greenAccent : (value > 4 ? Colors.amber : Colors.redAccent);
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
                strokeCap: StrokeCap.round,
              ),
              Text(
                "$value",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMain ? 18 : 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildFpsMetric(String label, dynamic val) {
    return Column(
      children: [
        Text(
          "$val", 
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          "FPS", 
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPartImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 50, height: 50,
        color: Colors.grey[800],
        child: const Icon(Icons.hardware, size: 24, color: Colors.white54),
      );
    }
    
    final fullUrl = url.startsWith('http') ? url : '${ApiConstants.baseUrl}$url';
    return Image.network(
      fullUrl, 
      width: 50, 
      height: 50, 
      fit: BoxFit.cover,
      errorBuilder: (_,__,___) => Container(width: 50, height: 50, color: Colors.grey[800], child: const Icon(Icons.broken_image)),
    );
  }
}