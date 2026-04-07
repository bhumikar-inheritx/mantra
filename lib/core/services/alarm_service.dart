import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  Future<void> scheduleAlarm({
    required int id,
    required DateTime dateTime,
    required String assetAudioPath,
    required String title,
    required String body,
    bool loopAudio = true,
    bool vibrate = true,
    double volume = 1.0,
    bool fadeDuration = false,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: assetAudioPath,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volumeSettings: fadeDuration
          ? VolumeSettings.fade(
              volume: volume,
              fadeDuration: const Duration(seconds: 5),
              volumeEnforced: true,
            )
          : VolumeSettings.fixed(
              volume: volume,
              volumeEnforced: true,
            ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop',
        icon: 'launcher_icon',
      ),
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
  }

  Future<bool> isRinging(int id) async {
    return Alarm.isRinging(id);
  }

  Future<List<AlarmSettings>> getAlarms() async {
    return await Alarm.getAlarms();
  }

  Stream<AlarmSettings>? get onRing => Alarm.ringStream.stream;
}
