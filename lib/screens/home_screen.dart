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

  final AudioPlayer backgroundPlayer = AudioPlayer();
  bool isBackgroundMusicPlaying = true;

  List<MicroSeason> seasons = [];
  int currentIndex = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
    startBackgroundMusic();
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

  Future<void> startBackgroundMusic() async {
    try {
      await backgroundPlayer.setAsset('assets/audio/background/shizuka_na_kisetsu.mp3');
      await backgroundPlayer.setLoopMode(LoopMode.one);
      await backgroundPlayer.setVolume(0.35);
      await backgroundPlayer.play();
    } catch (e) {
      debugPrint('Errore musica background: $e');
    }
  }

  Future<void> toggleBackgroundMusic() async {
  if (backgroundPlayer.playing) {
    await backgroundPlayer.pause();
    setState(() {
      isBackgroundMusicPlaying = false;
    });
  } else {
    await backgroundPlayer.play();
    setState(() {
      isBackgroundMusicPlaying = true;
    });
  }
}

  Future<void> playAudio() async {
    final season = seasons[currentIndex];
    debugPrint('AUDIO ASSET: ${season.audioAsset}');
    debugPrint('SEASON ID: ${season.id}');
    try {
      await player.stop();
      await player.setAsset(season.audioAsset);
      await player.play();
    } catch (e) {
      debugPrint('Errore audio pronuncia: $e');
    }
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
    backgroundPlayer.dispose();
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
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                season.englishName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
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

              /*Text(
                season.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),*/

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
    floatingActionButton: FloatingActionButton(
    backgroundColor: Colors.black54,
    foregroundColor: Colors.white,
    onPressed: toggleBackgroundMusic,
    child: Icon(
      isBackgroundMusicPlaying
          ? Icons.music_note
          : Icons.music_off,
    ),
  ),
);
  }
}