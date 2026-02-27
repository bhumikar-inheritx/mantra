import '../../domain/entities/mantra_entity.dart';

class MantraModel extends MantraEntity {
  const MantraModel({
    required String id,
    required String title,
    required String titleHindi,
    required String sanskritText,
    required String transliteration,
    required String translation,
    required String meaning,
    required String benefits,
    required String imageUrl,
    required String audioUrl,
    required String category,
    required List<String> chakras,
    required String idealTime,
    required int recommendedCount,
  }) : super(
          id: id,
          title: title,
          titleHindi: titleHindi,
          sanskritText: sanskritText,
          transliteration: transliteration,
          translation: translation,
          meaning: meaning,
          benefits: benefits,
          imageUrl: imageUrl,
          audioUrl: audioUrl,
          category: category,
          chakras: chakras,
          idealTime: idealTime,
          recommendedCount: recommendedCount,
        );

  factory MantraModel.fromJson(Map<String, dynamic> json) {
    return MantraModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleHindi: json['titleHindi'] ?? '',
      sanskritText: json['sanskritText'] ?? '',
      transliteration: json['transliteration'] ?? '',
      translation: json['translation'] ?? '',
      meaning: json['meaning'] ?? '',
      benefits: json['benefits'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      category: json['category'] ?? '',
      chakras: List<String>.from(json['chakras'] ?? []),
      idealTime: json['idealTime'] ?? '',
      recommendedCount: json['recommendedCount'] ?? 108,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleHindi': titleHindi,
      'sanskritText': sanskritText,
      'transliteration': transliteration,
      'translation': translation,
      'meaning': meaning,
      'benefits': benefits,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'category': category,
      'chakras': chakras,
      'idealTime': idealTime,
      'recommendedCount': recommendedCount,
    };
  }
}
