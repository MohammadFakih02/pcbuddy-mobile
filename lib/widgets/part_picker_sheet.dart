import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sync_models.dart';
import '../services/database_helper.dart';
import '../config/api_constants.dart';

class PartPickerSheet extends StatefulWidget {
  final String category;
  final Function(HardwareItem) onPartSelected;

  const PartPickerSheet({
    super.key,
    required this.category,
    required this.onPartSelected,
  });

  @override
  State<PartPickerSheet> createState() => _PartPickerSheetState();
}

class _PartPickerSheetState extends State<PartPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<HardwareItem> _parts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _limit = 20;
  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchParts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _fetchParts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _getTableName(String category) {
    switch (category) {
      case "CPU": return 'cpus';
      case "GPU": return 'gpus';
      case "Motherboard": return 'motherboards';
      case "RAM": return 'memory';
      case "Storage": return 'storage';
      case "Storage 2": return 'storage';
      case "PSU": return 'power_supplies';
      case "Case": return 'cases';
      default: return 'cpus';
    }
  }

  Future<void> _fetchParts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final tableName = _getTableName(widget.category);
    
    try {
      final newParts = await DatabaseHelper.instance.getItems(
        tableName,
        limit: _limit,
        offset: _currentPage * _limit,
        query: _searchQuery,
      );

      setState(() {
        _currentPage++;
        _parts.addAll(newParts);
        if (newParts.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      debugPrint("Error loading parts: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _parts.clear();
        _currentPage = 0;
        _hasMore = true;
      });
      _fetchParts();
    });
  }

  String _formatImage(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('http')) return url;
    return '${ApiConstants.baseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text("Select ${widget.category}", 
                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search ${widget.category}...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10),

          // List
          Expanded(
            child: _parts.isEmpty && !_isLoading
                ? const Center(child: Text("No parts found", style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _parts.length + (_hasMore ? 1 : 0),
                    separatorBuilder: (ctx, idx) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, index) {
                      if (index == _parts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final p = _parts[index];
                      final imgUrl = _formatImage(p.imageUrl);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: imgUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => const Icon(Icons.hardware, color: Colors.blueAccent, size: 24),
                                  ),
                                )
                              : const Icon(Icons.hardware, color: Colors.blueAccent, size: 24),
                        ),
                        title: Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        trailing: Text(
                          "\$${p.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                          ),
                        ),
                        onTap: () => widget.onPartSelected(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}