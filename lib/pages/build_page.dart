import 'package:flutter/material.dart';
import '../models/sync_models.dart';
import '../widgets/part_selection_tile.dart';
import '../widgets/part_picker_sheet.dart';

class PCBuilderPage extends StatefulWidget {
  const PCBuilderPage({super.key});

  @override
  State<PCBuilderPage> createState() => _PCBuilderPageState();
}

class _PCBuilderPageState extends State<PCBuilderPage> {
  // Using the HardwareItem model from sync_models.dart
  final Map<String, HardwareItem?> _selectedParts = {
    "CPU": null,
    "GPU": null,
    "Motherboard": null,
    "RAM": null,
    "Storage": null,
    "PSU": null,
    "Case": null,
  };

  // Helper: Sum up prices
  double _calculateTotal() {
    double total = 0;
    _selectedParts.forEach((key, part) {
      if (part != null) {
        total += part.price;
      }
    });
    return total;
  }

  // Open the Sheet
  void _openPartPicker(String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Needed for taller sheets
      backgroundColor: Colors.transparent,
      builder: (context) => PartPickerSheet(
        category: category,
        onPartSelected: (part) {
          setState(() => _selectedParts[category] = part);
          Navigator.pop(context);
        },
      ),
    );
  }

  // Clear specific slot
  void _clearPart(String category) {
    setState(() {
      _selectedParts[category] = null;
    });
  }

  void _saveBuild() {
    // TODO: Implement API call to save build
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Build Saving not implemented yet"))
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotal();

    return Scaffold(
      // Ensure body is behind navbar if transparent, but here standard
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Total Price Card
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Estimated Total",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9), 
                          fontSize: 14, 
                          letterSpacing: 1
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Part List
                // We use .keys.map to iterate through categories
                ..._selectedParts.keys.map((category) {
                  return PartSelectionTile(
                    category: category,
                    selectedPart: _selectedParts[category],
                    onTap: () => _openPartPicker(category),
                    onClear: () => _clearPart(category),
                  );
                }),
              ],
            ),
          ),

          // 3. Save Button (Pinned to bottom)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: totalPrice > 0 ? Colors.green : Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: totalPrice > 0 ? _saveBuild : null,
              child: const Text(
                "Save Configuration",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}