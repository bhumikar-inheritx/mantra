import 'package:flutter/material.dart';

class SankalpProvider extends ChangeNotifier {
  int _selectedTarget = 108;

  final List<int> _targets = [11, 21, 54, 108];

  int get selectedTarget => _selectedTarget;
  List<int> get targets => _targets;

  void setSelectedTarget(int target) {
    _selectedTarget = target;
    notifyListeners();
  }
}
