import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/micro_season.dart';
import '../services/notification_service.dart';
import '../services/season_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  TimeOfDay notificationTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  final SeasonService seasonService = SeasonService();

  Future<void> updateNotifications() async {
  final seasons = await seasonService.loadSeasons();

    if (notificationsEnabled) {
      await NotificationService.instance.rescheduleAll(seasons);
    } else {
      await NotificationService.instance.disableNotifications();
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

      final hour = prefs.getInt('notificationHour') ?? 8;
      final minute = prefs.getInt('notificationMinute') ?? 0;

      notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notificationsEnabled', notificationsEnabled);
    await prefs.setInt('notificationHour', notificationTime.hour);
    await prefs.setInt('notificationMinute', notificationTime.minute);
  }

  Future<void> pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );

    if (selected != null) {
     setState(() {
     notificationTime = selected;
    });

      await saveSettings();
      await updateNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = notificationTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable notifications'),
            subtitle: const Text('Notify when a new micro-season begins'),
            value: notificationsEnabled,
            onChanged: (value) async {
              setState(() {
              notificationsEnabled = value;
            });

            await saveSettings();
            await updateNotifications();
          },
          ),
         /* ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Test scheduled notification'),
                subtitle: const Text('Send in 1 minute'),
                onTap: () async {
                  debugPrint('TAP TEST SCHEDULED NOTIFICATION');

                  await NotificationService.instance.showScheduledTestNotification();
                },
              ),

          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Test notification'),
            subtitle: const Text('Send a notification now'),
            onTap: () async {
              await NotificationService.instance.showTestNotification();
            },
          ),*/

          ListTile(
            enabled: notificationsEnabled,
            title: const Text('Notification time'),
            subtitle: Text(formattedTime),
            trailing: const Icon(Icons.access_time),
            onTap: notificationsEnabled ? pickTime : null,
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Notifications Info'),
            subtitle: const Text(
               'If automatic notifications do not appear, please check your device settings.',
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Notifications Info'),
                  content: const Text(
                     'Notifications are delivered at the selected time.\n\n'
                      'If you do not receive them, please check that notifications are enabled for Shichijūni Kō and that battery restrictions are not limiting the app.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          )

        ],
      ),
    );
  }
}