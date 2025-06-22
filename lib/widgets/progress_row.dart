import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';

class ProgressRow extends ConsumerWidget {
  const ProgressRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رحلتك التعليمية',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: SirajColors.sirajBrown900,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        
        // Quran Progress
        _buildQuranProgress(context),
        const SizedBox(height: 16),
        
        // Achievements
        _buildAchievements(context),
      ],
    );
  }

  Widget _buildQuranProgress(BuildContext context) {
    const currentJuz = 3;
    const totalJuz = 30;
    const progress = currentJuz / totalJuz;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SirajColors.beige100,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SirajColors.sirajBrown700.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.book_outlined,
                  color: SirajColors.sirajBrown700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'رحلة القرآن الكريم',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: SirajColors.sirajBrown900,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الجزء الحالي: $currentJuz من $totalJuz',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: SirajColors.sirajBrown700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: SirajColors.nude300.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(SirajColors.sirajBrown700),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: SirajColors.sirajBrown700,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'استمر في القراءة لتكمل رحلتك مع كتاب الله',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: SirajColors.sirajBrown700.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    final achievements = [
      {
        'title': 'قارئ مبتدئ',
        'description': 'أكملت الجزء الأول',
        'icon': Icons.star,
        'color': SirajColors.accentGold,
        'unlocked': true,
      },
      {
        'title': 'مثابر',
        'description': 'قرأت لمدة 7 أيام متتالية',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'unlocked': true,
      },
      {
        'title': 'متعلم',
        'description': 'سألت 10 أسئلة لسراج',
        'icon': Icons.psychology,
        'color': SirajColors.sirajBrown700,
        'unlocked': true,
      },
      {
        'title': 'حافظ',
        'description': 'احفظ 5 آيات',
        'icon': Icons.memory,
        'color': SirajColors.nude300,
        'unlocked': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SirajColors.beige100,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SirajColors.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: SirajColors.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'الإنجازات',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: SirajColors.sirajBrown900,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: achievements.map((achievement) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: achievement['unlocked'] as bool
                      ? (achievement['color'] as Color).withOpacity(0.1)
                      : SirajColors.nude300.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: achievement['unlocked'] as bool
                        ? (achievement['color'] as Color).withOpacity(0.3)
                        : SirajColors.nude300.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      achievement['icon'] as IconData,
                      color: achievement['unlocked'] as bool
                          ? achievement['color'] as Color
                          : SirajColors.nude300,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement['title'] as String,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: achievement['unlocked'] as bool
                                ? SirajColors.sirajBrown900
                                : SirajColors.nude300,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: achievement['unlocked'] as bool
                                ? SirajColors.sirajBrown700
                                : SirajColors.nude300,
                            fontSize: 10,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

