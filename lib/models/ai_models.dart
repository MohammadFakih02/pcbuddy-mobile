class LaptopAssessment {
  final String laptopName;
  final LaptopSpecs specs;
  final LaptopRatings ratings;
  final Map<String, FpsEstimates> fps;
  final String thermalPerformance;
  final String summary;

  LaptopAssessment({
    required this.laptopName,
    required this.specs,
    required this.ratings,
    required this.fps,
    required this.thermalPerformance,
    required this.summary,
  });

  factory LaptopAssessment.fromJson(Map<String, dynamic> json) {
    var fpsMap = <String, FpsEstimates>{};
    if (json['fps'] != null) {
      (json['fps'] as Map<String, dynamic>).forEach((key, value) {
        fpsMap[key] = FpsEstimates.fromJson(value);
      });
    }

    return LaptopAssessment(
      laptopName: json['laptopName'] ?? 'Unknown',
      specs: LaptopSpecs.fromJson(json['specs'] ?? {}),
      ratings: LaptopRatings.fromJson(json['ratings'] ?? {}),
      fps: fpsMap,
      thermalPerformance: json['thermalPerformance'] ?? 'Unknown',
      summary: json['summary'] ?? '',
    );
  }
}

class LaptopSpecs {
  final String cpu;
  final String gpu;
  final String ram;
  final String storage;
  final String display;

  LaptopSpecs({required this.cpu, required this.gpu, required this.ram, required this.storage, required this.display});

  factory LaptopSpecs.fromJson(Map<String, dynamic> json) {
    return LaptopSpecs(
      cpu: json['cpu'] ?? '-',
      gpu: json['gpu'] ?? '-',
      ram: json['ram'] ?? '-',
      storage: json['storage'] ?? '-',
      display: json['display'] ?? '-',
    );
  }
}

class LaptopRatings {
  final String overall;
  final String cpu;
  final String gpu;

  LaptopRatings({required this.overall, required this.cpu, required this.gpu});

  factory LaptopRatings.fromJson(Map<String, dynamic> json) {
    return LaptopRatings(
      overall: json['overall'].toString(),
      cpu: json['cpu'].toString(),
      gpu: json['gpu'].toString(),
    );
  }
}

class FpsEstimates {
  final int low;
  final int medium;
  final int high;
  final int ultra;

  FpsEstimates({required this.low, required this.medium, required this.high, required this.ultra});

  factory FpsEstimates.fromJson(Map<String, dynamic> json) {
    return FpsEstimates(
      low: json['low'] ?? 0,
      medium: json['medium'] ?? 0,
      high: json['high'] ?? 0,
      ultra: json['ultra'] ?? 0,
    );
  }
}