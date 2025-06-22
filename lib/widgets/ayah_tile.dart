import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';

class AyahTile extends ConsumerWidget {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final VoidCallback onListen;
  final VoidCallback onAskSiraj;

  const AyahTile({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.onListen,
    required this.onAskSiraj,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Ayah Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: SirajColors.beige100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: SirajColors.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$ayahNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'الآية $ayahNumber',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: SirajColors.sirajBrown900,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: SirajColors.sirajBrown700,
                        size: 20,
                      ),
                      onPressed: onListen,
                      tooltip: 'استمع',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: SirajColors.accentGold,
                        size: 20,
                      ),
                      onPressed: onAskSiraj,
                      tooltip: 'اسأل سراج',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark_outline,
                        color: SirajColors.nude300,
                        size: 20,
                      ),
                      onPressed: () {
                        // Add bookmark functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حفظ الآية في العلامات المرجعية')),
                        );
                      },
                      tooltip: 'حفظ',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Ayah Text
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Arabic Text
                Text(
                  arabicText,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: SirajColors.sirajBrown900,
                        height: 2.0,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                
                const SizedBox(height: 16),
                
                // Action Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onListen,
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('استمع'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SirajColors.sirajBrown700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onAskSiraj,
                        icon: const Icon(Icons.psychology, size: 18),
                        label: const Text('اسأل سراج'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SirajColors.accentGold,
                          side: const BorderSide(color: SirajColors.accentGold),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

