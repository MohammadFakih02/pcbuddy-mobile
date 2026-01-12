import 'package:flutter/material.dart';
import '../models/sync_models.dart';
import '../widgets/part_selection_tile.dart';
import '../widgets/part_picker_sheet.dart';
import '../pages/build_preview_page.dart';

class PCBuilderPage extends StatefulWidget {
  // 1. Add optional parameter
  final Map<String, HardwareItem?>? initialParts;

  const PCBuilderPage({super.key, this.initialParts});

  @override
  State<PCBuilderPage> createState() => _PCBuilderPageState();
}

class _PCBuilderPageState extends State<PCBuilderPage> {
  late Map<String, HardwareItem?> _selectedParts;

  @override
  void initState() {
    super.initState();
    _selectedParts = widget.initialParts ?? {
      "CPU": null,
      "GPU": null,
      "Motherboard": null,
      "RAM": null,
      "Storage": null,
      "PSU": null,
      "Case": null,
    };
  }

  double _calculateTotal() {
    double total = 0;
    _selectedParts.forEach((key, part) {
      if (part != null) {
        total += part.price;
      }
    });
    return total;
  }

  void _openPartPicker(String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
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

  void _clearPart(String category) {
    setState(() {
      _selectedParts[category] = null;
    });
  }

  void _analyzeBuild() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildPreviewPage(selectedParts: _selectedParts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotal();

    return Scaffold(
      appBar: widget.initialParts != null 
        ? AppBar(title: const Text("Edit Build"), centerTitle: true)
        : null, 
        
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total Price Display
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

                // Part List
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

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: totalPrice > 0 ? Colors.greenAccent.shade700 : Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
              ),
              onPressed: totalPrice > 0 ? _analyzeBuild : null,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined),
                  SizedBox(width: 8),
                  Text(
                    "Analyze & Preview",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}