import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/micro_season.dart';
import '../services/season_service.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SeasonService seasonService = SeasonService();
  final AudioPlayer player = AudioPlayer();

  List<MicroSeason> seasons = [];
  int currentIndex = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final loadedSeasons = await seasonService.loadSeasons();
    final current = seasonService.getCurrentSeason(loadedSeasons);

    await NotificationService.instance.rescheduleAll(loadedSeasons);

    setState(() {
      seasons = loadedSeasons;
      currentIndex = loadedSeasons.indexWhere((s) => s.id == current.id);
      loading = false;
    });
  }

  Future<void> playAudio() async {
    final season = seasons[currentIndex];

    await player.setAsset(season.audioAsset);
    await player.play();
  }

  void previousSeason() {
    setState(() {
      currentIndex = currentIndex == 0 ? seasons.length - 1 : currentIndex - 1;
    });
  }

  void nextSeason() {
    setState(() {
      currentIndex = currentIndex == seasons.length - 1 ? 0 : currentIndex + 1;
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final season = seasons[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Japanese Micro Seasons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                season.imageAsset,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    season.japaneseName,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    season.romaji,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    season.englishName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  IconButton.filled(
                    icon: const Icon(Icons.volume_up),
                    onPressed: playAudio,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    season.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: previousSeason,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Previous'),
                      ),
                      ElevatedButton.icon(
                        onPressed: nextSeason,
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}