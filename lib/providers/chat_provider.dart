import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fanar_api.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final FanarApiService _fanarApi = FanarApiService();
  
  ChatNotifier() : super([]);

  // Add a user message and get AI response
  Future<void> sendMessage(String message) async {
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMessage];

    // Add loading message for AI response
    final loadingMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_loading',
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    
    state = [...state, loadingMessage];

    try {
      // Get conversation history for context
      final conversationHistory = state
          .where((msg) => !msg.isLoading && msg.id != userMessage.id)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.content,
              })
          .toList();

      // Get AI response
      final response = await _fanarApi.islamicGuidanceChat(
        userMessage: message,
        conversationHistory: conversationHistory,
      );

      final aiContent = response['choices']?[0]?['message']?['content'] ?? 'عذراً، لم أتمكن من فهم سؤالك.';

      // Replace loading message with actual response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiContent,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = [
        ...state.where((msg) => msg.id != loadingMessage.id),
        aiMessage,
      ];
    } catch (e) {
      // Replace loading message with error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'عذراً، حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = [
        ...state.where((msg) => msg.id != loadingMessage.id),
        errorMessage,
      ];
    }
  }

  // Clear chat history
  void clearChat() {
    state = [];
  }

  // Add predefined starter messages
  void addStarterMessage(String message) {
    sendMessage(message);
  }
}

// Providers
final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

// Starter questions
final starterQuestions = [
  'ما أهداف هذا التطبيق؟',
  'كيف أبدأ الصلاة؟',
  'ما معنى الإسلام؟',
];

