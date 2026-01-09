import 'package:flutter/material.dart';
import 'package:pcbuddy/pages/build_page.dart';

class PartSelectionTile extends StatelessWidget {
  final String category;
  final PCPart? selectedPart;
  final VoidCallback onTap;

  const PartSelectionTile({
    super.key,
    required this.category,
    this.selectedPart,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedPart != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.white10,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForCategory(category),
                  color: isSelected ? Colors.blueAccent : Colors.white38,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category,style: TextStyle(fontSize:12,color: Colors.grey[400])),
                    Text(
                      isSelected ? selectedPart!.name : "select $category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected? Colors.white : Colors.white38,
                      )
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

  IconData _getIconForCategory(String category) {
    switch (category) {
      case "CPU":
        return Icons.memory;
      case "GPU":
        return Icons.developer_board;
      case "Motherboard":
        return Icons.developer_board;
      case "RAM":
        return Icons.storage;
      case "Storage":
        return Icons.save;
      case "PSU":
        return Icons.power;
      case "Case":
        return Icons.vibration;
      default:
        return Icons.settings_input_component;
    }
  }
}
