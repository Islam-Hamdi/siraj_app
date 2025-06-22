import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FanarApiService {
  static const String _baseUrl = 'https://api.fanar.qa';
  static const String _apiKey = 'fmFrMl3wHnB9SFnb8bzxNFpGCVE18Wcz';

  // Chat completion endpoint
  Future<Map<String, dynamic>> chatCompletion({
    required List<Map<String, dynamic>> messages,
    String model = 'Fanar',
    int? maxTokens,
    double temperature = 0.7,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messages': messages,
          'model': model,
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw FanarApiException(
          'Chat completion failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw FanarApiException('Network error: $e');
    }
  }

  // Text-to-Speech endpoint
  Future<List<int>> textToSpeech({
    required String text,
    String model = 'Fanar-Aura-TTS-1',
    String voice = 'default',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/audio/speech'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'input': text,
          'voice': voice,
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw FanarApiException(
          'TTS failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw FanarApiException('Network error: $e');
    }
  }

  // Speech-to-Text endpoint
  Future<Map<String, dynamic>> speechToText({
    required File audioFile,
    String model = 'Fanar-Aura-STT-1',
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/v1/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.fields['model'] = model;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw FanarApiException(
          'STT failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw FanarApiException('Network error: $e');
    }
  }

  // Islamic RAG endpoint for Quran explanations
  Future<Map<String, dynamic>> islamicRagExplain({
    required String ayahText,
    required String ayahKey,
  }) async {
    final prompt = '''
في العربية، اشرح الآية $ayahKey ($ayahText) لمسلم جديد:
• سياق النزول (مكية/مدنية، القصة)
• ملخص التفسير (ابن كثير)
• معاني المفردات الرئيسية
• تأمل عملي واحد
''';

    return await chatCompletion(
      messages: [
        {
          'role': 'system',
          'content':
              'أنت مرشد إسلامي رحيم ومتفهم، تساعد المسلمين الجدد على فهم القرآن الكريم.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      model: 'Islamic-RAG',
    );
  }

  // General Islamic guidance chat
  Future<Map<String, dynamic>> islamicGuidanceChat({
    required String userMessage,
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content':
            '''أنت سراج، مرشد إسلامي رحيم ومتفهم. تساعد المسلمين الجدد والمهتمين بالإسلام في رحلتهم الروحية. 
        
أجب بطريقة:
- رحيمة ومتفهمة
- مبسطة وواضحة
- مدعومة بالأدلة من القرآن والسنة
- تشجع على التعلم والنمو الروحي
- تراعي أن المستخدم قد يكون مسلماً جديداً''',
      },
      ...(conversationHistory ?? []),
      {
        'role': 'user',
        'content': userMessage,
      },
    ];

    return await chatCompletion(
      messages: messages.cast<Map<String, dynamic>>(),
      model: 'Fanar',
    );
  }
}

class FanarApiException implements Exception {
  final String message;

  FanarApiException(this.message);

  @override
  String toString() => 'FanarApiException: $message';
}
