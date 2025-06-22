import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/colors.dart';
import '../providers/chat_provider.dart';
import '../services/audio_service.dart';
import '../services/fanar_api.dart';

class AskSirajView extends ConsumerStatefulWidget {
  const AskSirajView({super.key});

  @override
  ConsumerState<AskSirajView> createState() => _AskSirajViewState();
}

class _AskSirajViewState extends ConsumerState<AskSirajView> {
  late WebViewController _webViewController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  bool _isAvatarReady = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('Avatar page loaded: $url');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleAvatarMessage(message.message);
        },
      )
      ..loadFlutterAsset('web/avatar/index.html');
  }

  void _handleAvatarMessage(String message) {
    // Handle messages from the 3D avatar
    if (message == 'avatarReady') {
      setState(() {
        _isAvatarReady = true;
      });
    }
  }

  void _sendMessageToAvatar(String type, Map<String, dynamic> data) {
    if (_isAvatarReady) {
      final jsCode = '''
        window.postMessage({
          type: '$type',
          data: ${data.toString().replaceAll("'", '"')}
        }, '*');
      ''';
      _webViewController.runJavaScript(jsCode);
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    
    // Add message to chat
    ref.read(chatProvider.notifier).sendMessage(message);
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleRecording() async {
    final audioService = ref.read(audioServiceProvider);
    
    if (_isRecording) {
      // Stop recording and transcribe
      try {
        final transcription = await audioService.stopRecordingAndTranscribe();
        if (transcription.isNotEmpty) {
          _messageController.text = transcription;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التسجيل: $e')),
        );
      }
    } else {
      // Start recording
      try {
        await audioService.startRecording();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في بدء التسجيل: $e')),
        );
        return;
      }
    }
    
    setState(() {
      _isRecording = !_isRecording;
    });
    ref.read(isRecordingProvider.notifier).state = _isRecording;
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    
    return Scaffold(
      backgroundColor: SirajColors.beige50,
      appBar: AppBar(
        title: const Text('اسأل سراج'),
        backgroundColor: SirajColors.beige50,
        foregroundColor: SirajColors.sirajBrown900,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 3D Avatar Section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    SirajColors.beige50,
                    SirajColors.beige100,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: WebViewWidget(controller: _webViewController),
              ),
            ),
          ),
          
          // Chat Section
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Starter Questions
                if (messages.isEmpty) _buildStarterQuestions(),
                
                // Chat Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                
                // Input Section
                _buildInputSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterQuestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أسئلة للبداية:',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: SirajColors.sirajBrown900,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: starterQuestions.map((question) {
              return GestureDetector(
                onTap: () {
                  ref.read(chatProvider.notifier).sendMessage(question);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: SirajColors.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SirajColors.accentGold),
                  ),
                  child: Text(
                    question,
                    style: const TextStyle(
                      color: SirajColors.sirajBrown700,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: SirajColors.accentGold,
              child: Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? SirajColors.sirajBrown700 : SirajColors.beige100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: message.isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              SirajColors.sirajBrown700,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'سراج يفكر...',
                          style: TextStyle(
                            color: SirajColors.sirajBrown700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      message.content,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : SirajColors.sirajBrown900,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: SirajColors.nude300,
              child: Icon(
                Icons.person,
                size: 16,
                color: SirajColors.sirajBrown700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: SirajColors.beige100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Microphone button
          GestureDetector(
            onTap: _toggleRecording,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : SirajColors.accentGold,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب سؤالك هنا...',
                hintStyle: TextStyle(color: SirajColors.sirajBrown700.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: SirajColors.sirajBrown900),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: SirajColors.sirajBrown700,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

