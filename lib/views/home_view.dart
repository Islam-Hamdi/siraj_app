import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../widgets/prayer_times_card.dart';
import '../widgets/progress_row.dart';
import '../widgets/insights_carousel.dart';
import 'profile_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SirajColors.beige50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            snap: false,
            backgroundColor: SirajColors.beige50,
            foregroundColor: SirajColors.sirajBrown900,
            elevation: 0,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'أهلاً وسهلاً' ,
                style: TextStyle(
                  color: SirajColors.sirajBrown900,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to profile
                    Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const ProfileView()),
  );
                  },
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: SirajColors.accentGold,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Message
                _buildWelcomeCard(context),
                const SizedBox(height: 20),
                
                // Prayer Times Card
                const PrayerTimesCard(),
                const SizedBox(height: 20),
                
                // Progress Row
                const ProgressRow(),
                const SizedBox(height: 20),
                
                // Insights Carousel
                const InsightsCarousel(),
                const SizedBox(height: 20),
                
                // Quick Actions
                _buildQuickActions(context),
                const SizedBox(height: 100), // Bottom padding for navigation bar
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SirajColors.accentGold,
            SirajColors.accentGold.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SirajColors.accentGold.withOpacity(0.3),
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
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'رحلتك الروحية',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'نحن هنا لنرافقك في رحلتك لفهم الإسلام وتعميق إيمانك. ابدأ اليوم بخطوة جديدة نحو النور.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'title': 'اسأل سراج',
        'subtitle': 'احصل على إجابات إسلامية',
        'icon': Icons.chat_bubble_outline,
        'color': SirajColors.sirajBrown700,
      },
      {
        'title': 'القرآن التفاعلي',
        'subtitle': 'اقرأ واستمع وتعلم',
        'icon': Icons.book_outlined,
        'color': SirajColors.accentGold,
      },
      {
        'title': 'اتجاه القبلة',
        'subtitle': 'اعرف اتجاه الصلاة',
        'icon': Icons.explore_outlined,
        'color': SirajColors.nude300,
      },
      {
        'title': 'المجتمع',
        'subtitle': 'تواصل مع المسلمين',
        'icon': Icons.people_outline,
        'color': SirajColors.sirajBrown900,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: SirajColors.sirajBrown900,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: () {
                // Handle navigation based on action
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SirajColors.beige100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (action['color'] as Color).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      size: 32,
                      color: action['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: SirajColors.sirajBrown900,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action['subtitle'] as String,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: SirajColors.sirajBrown700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

