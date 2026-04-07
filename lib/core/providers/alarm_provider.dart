import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

import '../../../data/models/mantra_model.dart';
import '../services/alarm_service.dart';

class AlarmProvider extends ChangeNotifier {
  final AlarmService _alarmService = AlarmService();
  List<AlarmSettings> _alarms = [];
  MantraModel? _selectedMantra;
  DateTime _selectedTime = DateTime.now().add(const Duration(minutes: 1));

  List<AlarmSettings> get alarms => _alarms;
  MantraModel? get selectedMantra => _selectedMantra;
  DateTime get selectedTime => _selectedTime;

  AlarmProvider() {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    _alarms = await _alarmService.getAlarms();
    notifyListeners();
  }

  void setSelectedMantra(MantraModel mantra) {
    _selectedMantra = mantra;
    notifyListeners();
  }

  void setSelectedTime(DateTime time) {
    _selectedTime = time;
    notifyListeners();
  }

  Future<void> scheduleAlarm({
    required String title,
    required String body,
  }) async {
    if (_selectedMantra == null) return;

    final id = DateTime.now().millisecondsSinceEpoch % 10000;
    await _alarmService.scheduleAlarm(
      id: id,
      dateTime: _selectedTime,
      assetAudioPath: _selectedMantra!.audioUrl,
      title: title,
      body: body,
    );
    _loadAlarms();
  }

  Future<void> stopAlarm(int id) async {
    await _alarmService.stopAlarm(id);
    _loadAlarms();
  }
}
