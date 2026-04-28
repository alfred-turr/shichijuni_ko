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
  body: Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          season.imageAsset,
          fit: BoxFit.cover,
        ),
      ),

      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.75),
              ],
            ),
          ),
        ),
      ),

      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              Text(
                season.japaneseName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                season.romaji,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                season.englishName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                season.dateRange,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 20),

              IconButton(
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: playAudio,
              ),

              const SizedBox(height: 20),

              Text(
                season.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      onPressed: previousSeason,
                    ),
                  ),

                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: nextSeason,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }
}