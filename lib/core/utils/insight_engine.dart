import '../../data/models/insight_model.dart';

class InsightEngine {
  static const List<SpiritualInsight> _insights = [
    SpiritualInsight(
      title: "Mental Clarity",
      titleHindi: "मानसिक स्पष्टता",
      verse: "योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय।",
      translation: "Perform your duty equipoised, O Arjuna, abandoning all attachment to success or failure.",
      translationHindi: "हे धनंजय! सफलता और असफलता की आसक्ति को त्यागकर, समभाव में स्थित होकर अपने कर्तव्य का पालन करो।",
      context: "Focus on the process, not the result. This will calm your anxiety.",
      contextHindi: "परिणाम के बजाय प्रक्रिया पर ध्यान दें। इससे आपकी चिंता शांत होगी।",
    ),
    SpiritualInsight(
      title: "Overcoming Fear",
      titleHindi: "भय पर विजय",
      verse: "अभयं सत्त्वसंशुद्धिर्ज्ञानयोगव्यवस्थितिः।",
      translation: "Fearlessness, purification of one's existence, cultivation of spiritual knowledge...",
      translationHindi: "निर्भयता, अंतःकरण की शुद्धि, आध्यात्मिक ज्ञान का अनुशीलन...",
      context: "True strength comes from a pure heart and spiritual groundedness.",
      contextHindi: "सच्ची शक्ति शुद्ध हृदय और आध्यात्मिक आधार से आती है।",
    ),
    SpiritualInsight(
      title: "Abundance & Growth",
      titleHindi: "समृद्धि और विकास",
      verse: "शुचिनां श्रीमतां गेहे योगभ्रष्टोऽभिजायते।",
      translation: "One who falls from yoga is born into a house of the pure and prosperous.",
      translationHindi: "योग से विचलित व्यक्ति पवित्र और समृद्ध लोगों के घर में जन्म लेता है।",
      context: "Your spiritual efforts are never lost; they build your future prosperity.",
      contextHindi: "आपके आध्यात्मिक प्रयास कभी व्यर्थ नहीं जाते; वे आपकी भविष्य की समृद्धि का निर्माण करते हैं।",
    ),
    SpiritualInsight(
      title: "Inner Peace",
      titleHindi: "आंतरिक शांति",
      verse: "अशान्तस्य कुतः सुखम्।",
      translation: "For one who is not peaceful, how can there be happiness?",
      translationHindi: "अशांत व्यक्ति को सुख कहाँ मिल सकता है?",
      context: "Prioritize your inner stillness above all external goals.",
      contextHindi: "सभी बाहरी लक्ष्यों से ऊपर अपनी आंतरिक स्थिरता को प्राथमिकता दें।",
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
