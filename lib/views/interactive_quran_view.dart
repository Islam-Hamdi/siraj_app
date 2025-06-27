import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;
import '../theme/colors.dart';
import '../services/fanar_api.dart';
import '../services/audio_service.dart';
import '../widgets/ayah_tile.dart';

class InteractiveQuranView extends ConsumerStatefulWidget {
  const InteractiveQuranView({super.key});

  @override
  ConsumerState<InteractiveQuranView> createState() => _InteractiveQuranViewState();
}

class _InteractiveQuranViewState extends ConsumerState<InteractiveQuranView> {
  int _currentSurah = 1; // Al-Fatiha
  final int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final FanarApiService _fanarApi = FanarApiService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SirajColors.beige50,
      appBar: AppBar(
        title: const Text(
          'القرآن الكريم',
          style: TextStyle(
            color: SirajColors.sirajBrown900,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: SirajColors.beige50,
        foregroundColor: SirajColors.sirajBrown900,
        elevation: 0,
        centerTitle: true,
        actions: [
  // Search the entire Quran (existing functionality)
  IconButton(
    icon: const Icon(Icons.search),
    tooltip: 'بحث في المصحف',
    onPressed: _showSearchDialog,
  ),

  // View bookmarks (existing functionality)
  IconButton(
    icon: const Icon(Icons.bookmark_outline),
    tooltip: 'العلامات المرجعية',
    onPressed: _showBookmarksDialog,
  ),

  // New: Surah Selector
  IconButton(
    icon: const Icon(Icons.menu_book), // You can also use Icons.list or Icons.search_rounded
    tooltip: 'اختر السورة',
    onPressed: _showSurahSelector,
  ),
],

      ),
      body: Column(
        children: [
          // Surah Header
          _buildSurahHeader(),
          
          // Ayah List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: quran.getVerseCount(_currentSurah),
              itemBuilder: (context, index) {
                final ayahNumber = index + 1;
                final ayahText = quran.getVerse(_currentSurah, ayahNumber);
                
                return AyahTile(
                  surahNumber: _currentSurah,
                  ayahNumber: ayahNumber,
                  arabicText: ayahText,
                  onListen: () => _listenToAyah(_currentSurah, ayahNumber, ayahText),
                  onAskSiraj: () => _askSirajAboutAyah(_currentSurah, ayahNumber, ayahText),
                  onPlayFanarAnswer: () => _playAyahExplanation(_currentSurah, ayahNumber, ayahText),
                );
              },
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildSurahHeader() {
    final surahName = quran.getSurahName(_currentSurah);
    final surahNameArabic = quran.getSurahNameArabic(_currentSurah);
    final verseCount = quran.getVerseCount(_currentSurah);
    final revelationType = quran.getPlaceOfRevelation(_currentSurah);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SirajColors.sirajBrown700,
            SirajColors.sirajBrown900,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SirajColors.sirajBrown900.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            surahNameArabic,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            surahName,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSurahInfo('السورة', '$_currentSurah'),
              _buildSurahInfo('الآيات', '$verseCount'),
              _buildSurahInfo('النزول', revelationType == 'Meccan' ? 'مكية' : 'مدنية'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurahInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: SirajColors.accentGold,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
      ],
    );
  }

  void _playAyahExplanation(int surah, int ayah, String text) async {
    try {
      final audioService = ref.read(audioServiceProvider);
      
      // Get explanation from FANAR API
      final response = await _fanarApi.islamicRagExplain(
        ayahText: text,
        ayahKey: '$surah:$ayah',
      );
      
      final explanation = response['choices']?[0]?['message']?['content'] ?? 
                         'عذراً، لم أتمكن من الحصول على شرح للآية في الوقت الحالي.';
      
      // Use playLongTts for explanations which can be long
      if (explanation.length > 500) {
        await audioService.playLongTts(explanation);
      } else {
        await audioService.playTextToSpeech(explanation);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تشغيل شرح الآية: $e')),
      );
    }
  }

  void _listenToAyah(int surah, int ayah, String text) async {
    try {
      final audioService = ref.read(audioServiceProvider);
      await audioService.playTextToSpeech(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تشغيل الصوت: $e')),
      );
    }
  }

  void _askSirajAboutAyah(int surah, int ayah, String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AskSirajBottomSheet(
        surahNumber: surah,
        ayahNumber: ayah,
        ayahText: text,
      ),
    );
  }

  void _showSurahSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SirajColors.beige50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SurahSelectorBottomSheet(
        currentSurah: _currentSurah,
        onSurahSelected: (surah) {
          setState(() {
            _currentSurah = surah;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

 void _showSearchDialog() {
  String query = '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('البحث في القرآن'),
      content: TextField(
        decoration: const InputDecoration(
          hintText: 'ابحث عن آية أو كلمة...',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          query = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _performSearch(query); // 🔍 Call actual search logic
          },
          child: const Text('بحث'),
        ),
      ],
    ),
  );
}

  void _performSearch(String query) {
  final lowerQuery = query.trim().toLowerCase();
  List<Map<String, dynamic>> matches = [];

  for (int surah = 1; surah <= 114; surah++) {
    int verseCount = quran.getVerseCount(surah);
    for (int ayah = 1; ayah <= verseCount; ayah++) {
      final text = quran.getVerse(surah, ayah);
      if (text.contains(query)) {
        matches.add({
          'surah': surah,
          'ayah': ayah,
          'text': text,
        });
      }
    }
  }

  if (matches.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لم يتم العثور على نتائج')),
    );
    return;
  }

  // Show result in a dialog or navigate to a results page
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('نتائج البحث'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final result = matches[index];
            return ListTile(
              title: Text(result['text']),
              subtitle: Text(
                'سورة ${quran.getSurahNameArabic(result['surah'])} - آية ${result['ayah']}',
              ),
              onTap: () {
                setState(() {
                  _currentSurah = result['surah'];
                });
                Navigator.pop(context); // close results dialog
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    ),
  );
}


  void _showBookmarksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('العلامات المرجعية'),
        content: const Text('لا توجد علامات مرجعية محفوظة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}

class SurahSelectorBottomSheet extends StatelessWidget {
  final int currentSurah;
  final Function(int) onSurahSelected;

  const SurahSelectorBottomSheet({
    super.key,
    required this.currentSurah,
    required this.onSurahSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SirajColors.nude300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'اختر السورة',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: SirajColors.sirajBrown900,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 114, // Total number of surahs
              itemBuilder: (context, index) {
                final surahNumber = index + 1;
                final surahName = quran.getSurahName(surahNumber);
                final surahNameArabic = quran.getSurahNameArabic(surahNumber);
                final verseCount = quran.getVerseCount(surahNumber);
                final isSelected = surahNumber == currentSurah;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? SirajColors.accentGold : SirajColors.beige100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$surahNumber',
                        style: TextStyle(
                          color: isSelected ? Colors.white : SirajColors.sirajBrown700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    surahNameArabic,
                    style: const TextStyle(
                      color: SirajColors.sirajBrown900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '$surahName • $verseCount آية',
                    style: const TextStyle(
                      color: SirajColors.sirajBrown700,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: SirajColors.accentGold.withOpacity(0.1),
                  onTap: () => onSurahSelected(surahNumber),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AskSirajBottomSheet extends ConsumerStatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;

  const AskSirajBottomSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
  });

  @override
  ConsumerState<AskSirajBottomSheet> createState() => _AskSirajBottomSheetState();
}

class _AskSirajBottomSheetState extends ConsumerState<AskSirajBottomSheet> {
  final TextEditingController _questionController = TextEditingController();
  final FanarApiService _fanarApi = FanarApiService();
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
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SirajColors.nude300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'اسأل سراج عن الآية',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: SirajColors.sirajBrown900,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سورة ${quran.getSurahNameArabic(widget.surahNumber)} - الآية ${widget.ayahNumber}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: SirajColors.sirajBrown700,
                      ),
                ),
              ],
            ),
          ),
          
          // Ayah Text
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SirajColors.beige100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SirajColors.accentGold.withOpacity(0.3)),
            ),
            child: Text(
              widget.ayahText,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: SirajColors.sirajBrown900,
                    height: 1.8,
                    fontSize: 18,
                    fontFamily: 'AmiriQuran',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Question Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: 'اسأل سؤالاً عن هذه الآية...',
                hintStyle: TextStyle(color: SirajColors.sirajBrown700.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: SirajColors.accentGold,
                  ),
                  onPressed: _askQuestion,
                ),
              ),
              maxLines: 3,
              onSubmitted: (_) => _askQuestion(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Response Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(SirajColors.accentGold),
                          ),
                          SizedBox(height: 16),
                          Text('سراج يفكر في إجابتك...'),
                        ],
                      ),
                    )
                  : _response != null
                      ? Column(
                          children: [
                            // Response text
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  _response!,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: SirajColors.sirajBrown900,
                                        height: 1.6,
                                  ),
                                ),
                              ),
                            ),
                            // Audio controls
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _playFanarAnswer(_response!),
                                  icon: const Icon(Icons.volume_up, size: 18),
                                  label: const Text('استمع للإجابة'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SirajColors.accentGold,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: SirajColors.nude300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'اسأل سؤالاً عن الآية وسيجيبك سراج',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: SirajColors.nude300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _playFanarAnswer(String text) async {
    try {
      final audioService = ref.read(audioServiceProvider);
      
      // Use playLongTts for FANAR's answers which can be long
      if (text.length > 500) {
        await audioService.playLongTts(text);
      } else {
        await audioService.playTextToSpeech(text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تشغيل الصوت: $e')),
      );
    }
  }

  void _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final contextMessage = '''
      السؤال عن الآية رقم ${widget.ayahNumber} من سورة ${quran.getSurahNameArabic(widget.surahNumber)}:
      "${widget.ayahText}"
      
      السؤال: $question
      
      يرجى تقديم تفسير مفصل ومفيد للآية والإجابة على السؤال.
      ''';

      final response = await _fanarApi.islamicGuidanceChat(
        userMessage: contextMessage,
      );

      final aiResponse = response['choices']?[0]?['message']?['content'] ?? 
                        'عذراً، لم أتمكن من الإجابة على سؤالك في الوقت الحالي.';

      setState(() {
        _response = aiResponse;
        _isLoading = false;
      });

      _questionController.clear();
    } catch (e) {
      setState(() {
        _response = 'عذراً، حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}

