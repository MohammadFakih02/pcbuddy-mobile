import 'package:flutter/material.dart';
import '../widgets/part_selection_tile.dart'; // Ensure these paths match your project
import '../widgets/part_picker_sheet.dart';

class PCBuilderPage extends StatefulWidget {
  const PCBuilderPage({super.key});

  @override
  State<PCBuilderPage> createState() => _PCBuilderPageState();
}

class _PCBuilderPageState extends State<PCBuilderPage> {
  final Map<String, PCPart?> _selectedParts = {
    "CPU": null,
    "GPU": null,
    "Motherboard": null,
    "RAM": null,
    "Storage": null,
    "PSU": null,
    "Case": null,
  };

  final List<PCPart> _availableParts = [
    PCPart(name: "Ryzen 7 7800X3D", brand: "AMD", price: "\$399", type: "CPU"),
    PCPart(name: "Intel i9-14900K", brand: "Intel", price: "\$589", type: "CPU"),
    PCPart(name: "RTX 4080 Super", brand: "NVIDIA", price: "\$999", type: "GPU"),
    PCPart(name: "RX 7900 XTX", brand: "AMD", price: "\$929", type: "GPU"),
  ];

  double _calculateTotal() {
    double total = 0;
    _selectedParts.forEach((key, part) {
      if (part != null) {
        total += double.tryParse(part.price.replaceAll('\$', '')) ?? 0;
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
        availableParts: _availableParts,
        onPartSelected: (part) {
          setState(() => _selectedParts[category] = part);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Build"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Estimated Total",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                ..._selectedParts.keys.map((category) {
                  return PartSelectionTile(
                    category: category,
                    selectedPart: _selectedParts[category],
                    onTap: () => _openPartPicker(category),
                  );
                })
              ],
            ),
          ),

          // 4. Persistent Action Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: totalPrice > 0 ? () {
              } : null,
              child: const Text(
                "Analyze Build",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PCPart {
  final String name;
  final String brand;
  final String price;
  final String type;

  PCPart({
    required this.name,
    required this.brand,
    required this.price,
    required this.type,
  });
}