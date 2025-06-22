import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/colors.dart';

class PrayerTimesCard extends ConsumerStatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  ConsumerState<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends ConsumerState<PrayerTimesCard> {
  Map<String, dynamic>? prayerTimes;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      // Using Doha, Qatar as default location
      final response = await http.get(
        Uri.parse('https://api.aladhan.com/v1/timingsByCity?city=Doha&country=Qatar&method=2'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          prayerTimes = data['data']['timings'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _getNextPrayer() {
    if (prayerTimes == null) return 'الفجر';
    
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final arabicNames = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    
    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayerTimes![prayers[i]];
      final parts = prayerTime.split(':');
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      
      if (prayerDateTime.isAfter(now)) {
        return arabicNames[i];
      }
    }
    
    return arabicNames[0]; // Next day Fajr
  }

  String _getTimeUntilNextPrayer() {
    if (prayerTimes == null) return '';
    
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    
    for (final prayer in prayers) {
      final prayerTime = prayerTimes![prayer];
      final parts = prayerTime.split(':');
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      
      if (prayerDateTime.isAfter(now)) {
        final difference = prayerDateTime.difference(now);
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        
        if (hours > 0) {
          return '$hours س $minutes د';
        } else {
          return '$minutes د';
        }
      }
    }
    
    // Next day Fajr
    final fajrTime = prayerTimes!['Fajr'];
    final parts = fajrTime.split(':');
    final nextFajr = DateTime(
      now.year,
      now.month,
      now.day + 1,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    
    final difference = nextFajr.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    return '$hours س $minutes د';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    if (error != null) {
      return _buildErrorCard();
    }

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
                  Icons.access_time,
                  color: SirajColors.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'مواقيت الصلاة',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: SirajColors.sirajBrown900,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Next Prayer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SirajColors.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SirajColors.accentGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الصلاة القادمة',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: SirajColors.sirajBrown700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getNextPrayer(),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: SirajColors.sirajBrown900,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'بعد',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: SirajColors.sirajBrown700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTimeUntilNextPrayer(),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: SirajColors.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.explore,
                  color: SirajColors.accentGold,
                  size: 24,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // All Prayer Times
          _buildPrayerTimesList(),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    final prayers = [
      {'name': 'الفجر', 'key': 'Fajr'},
      {'name': 'الظهر', 'key': 'Dhuhr'},
      {'name': 'العصر', 'key': 'Asr'},
      {'name': 'المغرب', 'key': 'Maghrib'},
      {'name': 'العشاء', 'key': 'Isha'},
    ];

    return Column(
      children: prayers.map((prayer) {
        final time = prayerTimes![prayer['key']];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prayer['name']!,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: SirajColors.sirajBrown900,
                    ),
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: SirajColors.sirajBrown700,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SirajColors.beige100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SirajColors.accentGold),
          ),
          const SizedBox(width: 16),
          Text(
            'جاري تحميل مواقيت الصلاة...',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: SirajColors.sirajBrown700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SirajColors.beige100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: SirajColors.errorRed,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'خطأ في تحميل مواقيت الصلاة',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: SirajColors.sirajBrown700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

