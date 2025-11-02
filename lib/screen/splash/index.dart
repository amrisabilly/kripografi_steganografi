import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: -20.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut),
    );

    _animationController.repeat(reverse: true);

    // Navigate to login screen after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/login');
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF002C4B), Color(0xFF095C94)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo dengan animasi bouncing
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: const Image(
                      image: AssetImage("assets/images/logo_apl.png"),
                      width: 350,
                      height: 350,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),

              const SizedBox(height: 5),

              // Divider
              Container(
                width: 120,
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFFFDB634),
                      Color(0xFFFDCF7B),
                      Color(0xFFFDB634),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Spacer(flex: 2),

              // App name dengan gradient
              ShaderMask(
                shaderCallback:
                    (bounds) => const LinearGradient(
                      colors: [Color(0xFFFDCF7B), Color(0xFFFDB634)],
                    ).createShader(bounds),
                child: const Text(
                  'CryptoGuard',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              const Text(
                'Secure Your Digital World',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFDCF7B),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 30),

              // Loading section
              const Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFDCF7B),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
