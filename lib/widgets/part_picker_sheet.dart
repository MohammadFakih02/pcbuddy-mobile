
import 'package:flutter/material.dart';
import 'package:pcbuddy/pages/build_page.dart';

class PartPickerSheet extends StatelessWidget{
  final String category;
  final List<PCPart> availableParts;
  final Function(PCPart) onPartSelected;
  
    const PartPickerSheet({
    super.key,
    required this.category,
    required this.availableParts,
    required this.onPartSelected,
  });
  @override
  Widget build(BuildContext context) {
    final filteredParts = availableParts.where((p) => p.type == category).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle for the bottom sheet
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text("Choose $category", 
               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: filteredParts.isEmpty
                ? const Center(child: Text("No items found for this category."))
                : ListView.builder(
                    itemCount: filteredParts.length,
                    itemBuilder: (context, index) {
                      final p = filteredParts[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        title: Text(p.name),
                        subtitle: Text(p.brand, style: TextStyle(color: Colors.grey[500])),
                        trailing: Text(p.price, 
                                 style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                        onTap: () => onPartSelected(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}