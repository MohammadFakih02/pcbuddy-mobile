class PrebuiltItem {
  final int id;
  final String name;
  final double price;
  final double rating;
  final String? imageUrl;
  final bool isDeleted;

  PrebuiltItem({
    required this.id, 
    required this.name, 
    required this.price, 
    required this.rating,
    this.imageUrl,
    required this.isDeleted
  });

  factory PrebuiltItem.fromJson(Map<String, dynamic> json) {
    return PrebuiltItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }
}

class HardwareItem {
  final int id;
  final String name;
  final double price;
  final bool isDeleted;

  HardwareItem({required this.id, required this.name, required this.price, required this.isDeleted});

  factory HardwareItem.fromJson(Map<String, dynamic> json) {
    return HardwareItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}

class SyncResponse {
  final List<HardwareItem> cpus;
  final List<HardwareItem> gpus;
  final List<HardwareItem> memory;
  final List<HardwareItem> storage;
  final List<HardwareItem> motherboards;
  final List<HardwareItem> powerSupplies;
  final List<HardwareItem> cases;
  final List<PrebuiltItem> prebuilts;
  final String version;

  SyncResponse({
    required this.cpus,
    required this.gpus,
    required this.memory,
    required this.storage,
    required this.motherboards,
    required this.powerSupplies,
    required this.cases,
    required this.prebuilts,
    required this.version,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    List<HardwareItem> parseList(String key) {
      return (json[key] as List?)?.map((i) => HardwareItem.fromJson(i)).toList() ?? [];
    }
    
    List<PrebuiltItem> parsePrebuilts(String key) {
      return (json[key] as List?)?.map((i) => PrebuiltItem.fromJson(i)).toList() ?? [];
    }

    return SyncResponse(
      cpus: parseList('cpus'),
      gpus: parseList('gpus'),
      memory: parseList('memories'),
      storage: parseList('storages'),
      motherboards: parseList('motherboards'),
      powerSupplies: parseList('powerSupplies'),
      cases: parseList('cases'),
      prebuilts: parsePrebuilts('prebuilts'),
      version: json['version'],
    );
  }
}