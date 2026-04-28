import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/micro_season.dart';

class SeasonService {
  Future<List<MicroSeason>> loadSeasons() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/japanese_72_microseasons_dataset.json',
    );

    final jsonData = json.decode(jsonString);
    final list = jsonData['microSeasons'] as List;

    return list.map((e) => MicroSeason.fromJson(e)).toList();
  }

  MicroSeason getCurrentSeason(List<MicroSeason> seasons) {
    final now = DateTime.now();
    final today = '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    return seasons.firstWhere(
      (season) => _isTodayInRange(today, season.startDate, season.endDate),
      orElse: () => seasons.first,
    );
  }

  bool _isTodayInRange(String today, String start, String end) {
    final t = int.parse(today);
    final s = int.parse(start);
    final e = int.parse(end);

    if (s <= e) {
      return t >= s && t <= e;
    }

    // Gestisce range che attraversano l'anno, es. 1230 - 0104
    return t >= s || t <= e;
  }
}