import 'package:equatable/equatable.dart';
import '../../../data/models/mantra_model.dart';

enum ChantMode {
  audio,
  manual,
}

class ChantingSession extends Equatable {
  final MantraModel mantra;
  final int targetCount;
  final DateTime startTime;
  final ChantMode mode;

  const ChantingSession({
    required this.mantra,
    required this.targetCount,
    required this.startTime,
    required this.mode,
  });

  @override
  List<Object?> get props => [mantra, targetCount, startTime, mode];

  ChantingSession copyWith({
    MantraModel? mantra,
    int? targetCount,
    DateTime? startTime,
    ChantMode? mode,
  }) {
    return ChantingSession(
      mantra: mantra ?? this.mantra,
      targetCount: targetCount ?? this.targetCount,
      startTime: startTime ?? this.startTime,
      mode: mode ?? this.mode,
    );
  }
}
