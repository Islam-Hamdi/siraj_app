import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // Navigate to auth after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // TODO: Check if user is logged in, then navigate accordingly
        // For now, navigate to auth
        context.go('/auth');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SirajColors.sirajBrown900,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO: Replace with actual logo SVG
              const Icon(
                Icons.lightbulb_outline,
                color: SirajColors.accentGold,
                size: 120,
              ),
              const SizedBox(height: 24),
              Text(
                'وجعلنا سراجاً وهاجاً',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w300,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Siraj',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: SirajColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

