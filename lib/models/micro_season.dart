class MicroSeason {
  final int id;
  final String japaneseName;
  final String romaji;
  final String englishName;
  final String description;
  final String startDate;
  final String endDate;
  final String imageAsset;
  final String audioAsset;

  MicroSeason({
    required this.id,
    required this.japaneseName,
    required this.romaji,
    required this.englishName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.imageAsset,
    required this.audioAsset,
  });

  factory MicroSeason.fromJson(Map<String, dynamic> json) {
    return MicroSeason(
      id: json['id'],
      japaneseName: json['japaneseName'],
      romaji: json['romaji'],
      englishName: json['englishName'],
      description: json['description'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      imageAsset: json['imageAsset'],
      audioAsset: json['audioAsset'],
    );
  }
}