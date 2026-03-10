import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/audio_player_provider.dart';
import '../../chanting/providers/audio_chant_provider.dart';
import '../../chanting/providers/practice_session_provider.dart';
import '../providers/mini_player_provider.dart';
import 'mini_player_widget.dart';

class GlobalMiniPlayerWrapper extends StatelessWidget {
  final Widget child;

  const GlobalMiniPlayerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
