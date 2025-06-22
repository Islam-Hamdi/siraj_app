import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../views/home_view.dart';
import '../views/compass_view.dart';
import '../views/community_feed_view.dart';
import '../views/avatar_view.dart';
import '../views/interactive_quran_view.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 2; // Start with Home in the middle

  final List<Widget> _pages = [
    const CompassView(),
    const InteractiveQuranView(),
    const HomeView(),
    const AskSirajView(),
    const CommunityFeedView(),
  ];

  final List<IconData> _icons = [
    CupertinoIcons.compass,
    CupertinoIcons.book,
    CupertinoIcons.house_fill,
    CupertinoIcons.chat_bubble,
    CupertinoIcons.person_2,
  ];

  final List<String> _labels = [
    'القبلة',
    'القرآن',
    'الرئيسية',
    'سراج',
    'المجتمع',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SirajColors.beige50,
      body: Stack(
        children: [
          // Main content
          Positioned.fill(
            child: _pages[_currentIndex],
          ),
          
          // Custom bottom navigation bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 34,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: SirajColors.beige100,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: SirajColors.sirajBrown900.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_icons.length, (index) {
          final isSelected = index == _currentIndex;
          final isCenter = index == 2; // Home button in center
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCenter ? 60 : 50,
              height: isCenter ? 60 : 50,
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isCenter ? SirajColors.accentGold : SirajColors.sirajBrown700)
                    : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected && isCenter ? [
                  BoxShadow(
                    color: SirajColors.accentGold.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icons[index],
                    size: isCenter ? 28 : 24,
                    color: isSelected 
                        ? Colors.white 
                        : SirajColors.sirajBrown700,
                  ),
                  if (!isCenter && isSelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      _labels[index],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

