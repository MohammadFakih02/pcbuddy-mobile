import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/config/api_constants.dart';
import 'package:pcbuddy/models/sync_models.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/services/computer_service.dart';

class PartDetailsPage extends StatefulWidget {
  final String category;
  final HardwareItem item;

  const PartDetailsPage({
    super.key,
    required this.category,
    required this.item,
  });

  @override
  State<PartDetailsPage> createState() => _PartDetailsPageState();
}

class _PartDetailsPageState extends State<PartDetailsPage> {
  late Future<Map<String, dynamic>> _specsFuture;

  @override
  void initState() {
    super.initState();
    _specsFuture = _loadSpecs();
  }

  Future<Map<String, dynamic>> _loadSpecs() async {
    final token = context.read<AuthProvider>().user?.token ?? '';
    return ComputerService(
      token,
    ).fetchPartSpecs(widget.category, widget.item.id);
  }

  String _formatImage(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://placehold.co/400x400/png?text=Hardware';
    }
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('http')) return url;
    return '${ApiConstants.baseUrl}$url';
  }

  String _formatKey(String key) {
    if ([
      'id',
      'name',
      'price',
      'imageUrl',
      'productUrl',
      'type',
      'partType',
    ].contains(key)) {
      return '';
    }

    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .capitalize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: const Border(
                    bottom: BorderSide(color: Colors.white10),
                  ),
                ),
                child: Hero(
                  tag: 'part_${widget.item.id}',
                  child: Image.network(
                    _formatImage(widget.item.imageUrl),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.hardware,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${widget.item.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Technical Specifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),

                    FutureBuilder<Map<String, dynamic>>(
                      future: _specsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text(
                            "Could not load additional specs.",
                            style: TextStyle(color: Colors.grey),
                          );
                        }

                        final specs = snapshot.data!;

                        return Column(
                          children: specs.entries.map((entry) {
                            final key = _formatKey(entry.key);
                            if (key.isEmpty || entry.value == null) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      key,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      "${entry.value}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
