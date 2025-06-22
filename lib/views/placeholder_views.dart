import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../theme/colors.dart';
import '../services/fanar_api.dart';
import '../services/audio_service.dart';

class ListenBottomSheet extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final AudioService audioService;
  final FanarApiService fanarApi;

  const ListenBottomSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.audioService,
    required this.fanarApi,
  });

  @override
  State<ListenBottomSheet> createState() => _ListenBottomSheetState();
}

class _ListenBottomSheetState extends State<ListenBottomSheet> {
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: SirajColors.beige50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SirajColors.nude300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'استماع للآية',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: SirajColors.sirajBrown900,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: SirajColors.sirajBrown900.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'سورة ${quran.getSurahName(widget.surahNumber)} - الآية ${widget.ayahNumber}',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: SirajColors.sirajBrown900,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.arabicText,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                color: SirajColors.sirajBrown900,
                                height: 2.0,
                                fontFamily: 'Amiri',
                              ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                        label: _isPlaying ? 'إيقاف' : 'تشغيل',
                        onPressed: _togglePlayback,
                        isLoading: _isLoading,
                      ),
                      _buildActionButton(
                        icon: Icons.download,
                        label: 'تحميل',
                        onPressed: _downloadAudio,
                      ),
                      _buildActionButton(
                        icon: Icons.share,
                        label: 'مشاركة',
                        onPressed: _shareAyah,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: SirajColors.accentGold,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: SirajColors.sirajBrown700,
              ),
        ),
      ],
    );
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await widget.audioService.stopPlayback();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });

      try {
        // Use Fanar API to generate TTS for the ayah
        await widget.audioService.playTextToSpeech(widget.arabicText);

        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في تشغيل الصوت: $e')),
          );
        }
      }
    }
  }

  void _downloadAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة ميزة التحميل قريباً')),
    );
  }

  void _shareAyah() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الآية')),
    );
  }
}

class AskSirajBottomSheet extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final FanarApiService fanarApi;

  const AskSirajBottomSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.fanarApi,
  });

  @override
  State<AskSirajBottomSheet> createState() => _AskSirajBottomSheetState();
}

class _AskSirajBottomSheetState extends State<AskSirajBottomSheet> {
  final TextEditingController _questionController = TextEditingController();
  String? _response;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: SirajColors.beige50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SirajColors.nude300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'اسأل سراج عن الآية',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: SirajColors.sirajBrown900,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: SirajColors.sirajBrown900.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سورة ${quran.getSurahName(widget.surahNumber)} - الآية ${widget.ayahNumber}',
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: SirajColors.sirajBrown900,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.arabicText,
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: SirajColors.sirajBrown900,
                                    height: 1.8,
                                  ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'اكتب سؤالك عن هذه الآية...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        onPressed: _isLoading ? null : _askQuestion,
                      ),
                    ),
                    maxLines: 3,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  if (_response != null)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: SirajColors.sirajBrown900.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.psychology,
                                    color: SirajColors.accentGold,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'إجابة سراج:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: SirajColors.sirajBrown900,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _response!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: SirajColors.sirajBrown900,
                                      height: 1.6,
                                    ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final context = 'الآية: ${widget.arabicText}\nالسؤال: $question';
      final response = await widget.fanarApi.chatCompletion(
        messages: [
          {'role': 'user', 'content': context}
        ],
        model: 'Islamic-RAG',
      );

      setState(() {
        _response = response["choices"][0]["message"]
            ["content"]; // Extract the string content
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحصول على الإجابة: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
