import 'package:flutter/material.dart';
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/models/sync_models.dart';
import 'package:pcbuddy/services/database_helper.dart'; // Import DB

class PrebuiltDetailsPage extends StatefulWidget {
  final PrebuiltItem pcBuild;

  const PrebuiltDetailsPage({super.key, required this.pcBuild});

  @override
  State<PrebuiltDetailsPage> createState() => _PrebuiltDetailsPageState();
}

class _PrebuiltDetailsPageState extends State<PrebuiltDetailsPage> {
  Map<String, HardwareItem?>? _parts;
  bool _isLoadingParts = true;

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  Future<void> _loadParts() async {
    final parts = await DatabaseHelper.instance.getPrebuiltParts(
      widget.pcBuild,
    );
    if (mounted) {
      setState(() {
        _parts = parts;
        _isLoadingParts = false;
      });
    }
  }

  String _formatImage(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://placehold.co/400x400/png?text=PC';
    }
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('http')) return url;
    return '${ApiConstants.baseUrl}$url';
  }

  String _getTier() {
    if (widget.pcBuild.price > 2500) return "Ultra Enthusiast";
    if (widget.pcBuild.price > 1500) return "High-End Gaming";
    if (widget.pcBuild.price > 800) return "Mid-Range Beast";
    return "Budget Friendly";
  }

  Color _getTierColor() {
    if (widget.pcBuild.price > 2500) return Colors.purpleAccent;
    if (widget.pcBuild.price > 1500) return Colors.orangeAccent;
    if (widget.pcBuild.price > 800) return Colors.blueAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pcBuild = widget.pcBuild;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'prebuilt_${pcBuild.id}',
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_formatImage(pcBuild.imageUrl)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            theme.scaffoldBackgroundColor,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getTierColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getTierColor()),
                      ),
                      child: Text(
                        _getTier().toUpperCase(),
                        style: TextStyle(
                          color: _getTierColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            pcBuild.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pcBuild.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "\$${pcBuild.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      "Specifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isLoadingParts)
                      const Center(child: CircularProgressIndicator())
                    else if (_parts == null)
                      const Text("Could not load parts.")
                    else
                      Column(
                        children: [
                          _buildSpecRow(
                            Icons.memory,
                            "Processor",
                            _parts!['CPU']?.name ?? "N/A",
                          ),
                          _buildSpecRow(
                            Icons.developer_board,
                            "Graphics",
                            _parts!['GPU']?.name ?? "N/A",
                          ),
                          _buildSpecRow(
                            Icons.sd_storage,
                            "Memory",
                            _parts!['RAM']?.name ?? "N/A",
                          ),
                          _buildSpecRow(
                            Icons.storage,
                            "Storage",
                            _parts!['Storage']?.name ?? "N/A",
                          ),
                          _buildSpecRow(
                            Icons.dns,
                            "Motherboard",
                            _parts!['Motherboard']?.name ?? "N/A",
                          ),
                          _buildSpecRow(
                            Icons.power,
                            "Power Supply",
                            _parts!['PSU']?.name ?? "N/A",
                          ),
                          _buildSpecRow(
                            Icons.desktop_windows,
                            "Case",
                            _parts!['Case']?.name ?? "N/A",
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Added to Cart!")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Buy Now",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border),
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
