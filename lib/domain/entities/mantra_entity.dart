import 'package:equatable/equatable.dart';

class MantraEntity extends Equatable {
  final String id;
  final String title;
  final String titleHindi;
  final String sanskritText;
  final String transliteration;
  final String translation;
  final String meaning;
  final String benefits;
  final String imageUrl;
  final String audioUrl;
  final String category;
  final List<String> chakras;
  final String idealTime;
  final int recommendedCount;

  const MantraEntity({
    required this.id,
    required this.title,
    required this.titleHindi,
    required this.sanskritText,
    required this.transliteration,
    required this.translation,
    required this.meaning,
    required this.benefits,
    required this.imageUrl,
    required this.audioUrl,
    required this.category,
    required this.chakras,
    required this.idealTime,
    required this.recommendedCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        titleHindi,
        category,
      ];
}
