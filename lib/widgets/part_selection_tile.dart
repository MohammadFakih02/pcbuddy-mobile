import 'package:flutter/material.dart';
import '../models/sync_models.dart';
import 'package:pcbuddy/config/api_constants.dart';

class PartSelectionTile extends StatelessWidget {
  final String category;
  final HardwareItem? selectedPart;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const PartSelectionTile({
    super.key,
    required this.category,
    this.selectedPart,
    required this.onTap,
    this.onClear,
  });

  String _formatImage(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('http')) return url;
    return '${ApiConstants.baseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedPart != null;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : Colors.white10,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 44, 
                height: 44,
                padding: isSelected && selectedPart?.imageUrl == null ? const EdgeInsets.all(10) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isSelected && selectedPart?.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _formatImage(selectedPart!.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(_getIconForCategory(category), color: theme.colorScheme.primary),
                        ),
                      )
                    : Icon(
                        _getIconForCategory(category),
                        color: isSelected ? theme.colorScheme.primary : Colors.white38,
                        size: 24,
                      ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSelected ? selectedPart!.name : "Select $category",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white38,
                      ),
                    ),
                    if (isSelected)
                      Text(
                        "\$${selectedPart!.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              if (isSelected && onClear != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: onClear,
                )
              else
                const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case "CPU": return Icons.memory;
      case "GPU": return Icons.developer_board;
      case "Motherboard": return Icons.dns;
      case "RAM": return Icons.sd_storage;
      case "Storage": return Icons.storage;
      case "PSU": return Icons.power;
      case "Case": return Icons.desktop_windows;
      default: return Icons.hardware;
    }
  }
}