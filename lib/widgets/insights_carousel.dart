import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';

class InsightsCarousel extends ConsumerStatefulWidget {
  const InsightsCarousel({super.key});

  @override
  ConsumerState<InsightsCarousel> createState() => _InsightsCarouselState();
}

class _InsightsCarouselState extends ConsumerState<InsightsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> insights = [
    {
      'title': 'حديث اليوم',
      'content': 'قال رسول الله ﷺ: "إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى"',
      'source': 'صحيح البخاري',
      'type': 'hadith',
      'color': SirajColors.accentGold,
    },
    {
      'title': 'آية للتأمل',
      'content': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ',
      'source': 'سورة الطلاق: 2-3',
      'type': 'quran',
      'color': SirajColors.sirajBrown700,
    },
    {
      'title': 'فائدة إيمانية',
      'content': 'الصبر مفتاح الفرج، والدعاء سلاح المؤمن، والتوكل على الله طمأنينة القلب',
      'source': 'حكمة إسلامية',
      'type': 'wisdom',
      'color': SirajColors.nude300,
    },
    {
      'title': 'دعاء مستجاب',
      'content': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'source': 'سورة البقرة: 201',
      'type': 'dua',
      'color': SirajColors.sirajBrown900,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll every 5 seconds
    Future.delayed(const Duration(seconds: 5), _autoScroll);
  }

  void _autoScroll() {
    if (mounted) {
      setState(() {
        _currentPage = (_currentPage + 1) % insights.length;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 5), _autoScroll);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'hadith':
        return Icons.format_quote;
      case 'quran':
        return Icons.book;
      case 'wisdom':
        return Icons.lightbulb_outline;
      case 'dua':
        return Icons.favorite_outline;
      default:
        return Icons.star_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إشراقات روحية',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: SirajColors.sirajBrown900,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      insight['color'] as Color,
                      (insight['color'] as Color).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (insight['color'] as Color).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconForType(insight['type']),
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          insight['title'],
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Expanded(
                      child: Text(
                        insight['content'],
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              height: 1.6,
                              fontSize: 16,
                            ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      insight['source'],
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            insights.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? SirajColors.accentGold
                    : SirajColors.nude300.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

