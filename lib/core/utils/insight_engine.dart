import '../../data/models/insight_model.dart';

class InsightEngine {
  static const List<SpiritualInsight> _insights = [
    SpiritualInsight(
      title: "Mental Clarity",
      verse: "योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय।",
      translation: "Perform your duty equipoised, O Arjuna, abandoning all attachment to success or failure.",
      context: "Focus on the process, not the result. This will calm your anxiety.",
    ),
    SpiritualInsight(
      title: "Overcoming Fear",
      verse: "अभयं सत्त्वसंशुद्धिर्ज्ञानयोगव्यवस्थितिः।",
      translation: "Fearlessness, purification of one's existence, cultivation of spiritual knowledge...",
      context: "True strength comes from a pure heart and spiritual groundedness.",
    ),
    SpiritualInsight(
      title: "Abundance & Growth",
      verse: "शुचिनां श्रीमतां गेहे योगभ्रष्टोऽभिजायते।",
      translation: "One who falls from yoga is born into a house of the pure and prosperous.",
      context: "Your spiritual efforts are never lost; they build your future prosperity.",
    ),
    SpiritualInsight(
      title: "Inner Peace",
      verse: "अशान्तस्य कुतः सुखम्।",
      translation: "For one who is not peaceful, how can there be happiness?",
      context: "Prioritize your inner stillness above all external goals.",
    ),
  ];

  static SpiritualInsight getInsight(String? mood, String? goal, String? deity) {
    // Intelligent mapping logic
    if (mood == 'Stress' || mood == 'Confusion') {
      return _insights[0]; // Mental Clarity
    } else if (mood == 'Fear') {
      return _insights[1]; // Overcoming Fear
    } else if (goal == 'Money' || goal == 'Success') {
      return _insights[2]; // Abundance
    } else {
      return _insights[3]; // Inner Peace (Default)
    }
  }
}
