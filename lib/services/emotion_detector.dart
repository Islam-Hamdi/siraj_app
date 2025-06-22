
class EmotionDetector {
  // Simple emotion detection based on keywords
  // In a real implementation, you might use a more sophisticated ML model
  
  static const Map<String, List<String>> _emotionKeywords = {
    'happy': [
      'سعيد', 'فرح', 'مبسوط', 'رائع', 'جميل', 'ممتاز', 'حب', 'أحب',
      'happy', 'joy', 'great', 'wonderful', 'love', 'amazing', 'excellent'
    ],
    'sad': [
      'حزين', 'زعلان', 'متضايق', 'صعب', 'مؤلم', 'حزن',
      'sad', 'upset', 'difficult', 'painful', 'sorrow', 'grief'
    ],
    'angry': [
      'غاضب', 'زعلان', 'متضايق', 'غضب', 'مش عاجبني',
      'angry', 'mad', 'frustrated', 'annoyed', 'upset'
    ],
    'fear': [
      'خائف', 'خوف', 'قلق', 'متوتر', 'مرعوب',
      'afraid', 'fear', 'scared', 'worried', 'anxious', 'nervous'
    ],
    'surprise': [
      'مفاجأة', 'مندهش', 'متفاجئ', 'عجيب',
      'surprise', 'surprised', 'amazing', 'wow', 'incredible'
    ],
  };

  static String detectEmotion(String text) {
    if (text.isEmpty) return 'neutral';
    
    final lowerText = text.toLowerCase();
    final scores = <String, int>{};
    
    // Initialize scores
    for (final emotion in _emotionKeywords.keys) {
      scores[emotion] = 0;
    }
    
    // Count keyword matches
    for (final entry in _emotionKeywords.entries) {
      final emotion = entry.key;
      final keywords = entry.value;
      
      for (final keyword in keywords) {
        if (lowerText.contains(keyword.toLowerCase())) {
          scores[emotion] = (scores[emotion] ?? 0) + 1;
        }
      }
    }
    
    // Find emotion with highest score
    String detectedEmotion = 'neutral';
    int maxScore = 0;
    
    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        detectedEmotion = entry.key;
      }
    }
    
    return detectedEmotion;
  }

  // Detect emotion from conversation context
  static String detectEmotionFromContext(List<String> messages) {
    if (messages.isEmpty) return 'neutral';
    
    // Combine recent messages for context
    final recentMessages = messages.take(3).join(' ');
    return detectEmotion(recentMessages);
  }

  // Map emotions to avatar animations
  static String getAnimationForEmotion(String emotion) {
    const emotionAnimations = {
      'happy': 'laughing',
      'sad': 'crying',
      'angry': 'angry',
      'fear': 'terrified',
      'surprise': 'talking_2',
      'neutral': 'standingidle',
      'talking': 'talking_1',
    };
    
    return emotionAnimations[emotion] ?? 'standingidle';
  }

  // Get emoji for emotion
  static String getEmojiForEmotion(String emotion) {
    const emotionEmojis = {
      'happy': '😊',
      'sad': '😢',
      'angry': '😠',
      'fear': '😨',
      'surprise': '😲',
      'neutral': '😐',
      'talking': '🗣️',
    };
    
    return emotionEmojis[emotion] ?? '😐';
  }
}

