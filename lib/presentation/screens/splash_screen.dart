import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    // Extremely fast, punchy 1.4-second duration
    _controller = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 1400) 
    );
    
    // Sync the "punch.mp3" to fire exactly upon the gravitational impact (t = 0.22 => 300ms)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _audioPlayer.play(AssetSource('sounds/punch.mp3'));
    });
    
    _controller.forward();

    // Out transition seamlessly matches the timing
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          
          double dropY = -400.0;
          double scale = 1.0;
          
          if (t < 0.2) {
             // Fierce gravitational acceleration drop
             double factor = t / 0.2;
             dropY = -400 + (400 * factor * factor * factor);
          } else {
             // Rest
             dropY = 0.0;
          }

          if (t >= 0.2 && t <= 0.6) {
             // Extremely heavy elastic collision bounce from hitting the rigid text below
             double impact = 1.0 - ((t - 0.2) / 0.4);
             scale = 1.0 + (math.sin(impact * math.pi * 3) * 0.2 * (impact * impact));
          }

          // A volumetric background blood-red flash triggered at exact impact
          Color bgColor = const Color(0xFF030303);
          if (t > 0.15 && t < 0.8) {
             double flash = 1.0;
             if (t < 0.2) {
                 flash = (t - 0.15) / 0.05; // rapid ramp
             } else {
                 flash = 1.0 - ((t - 0.2) / 0.6); // slow exponential decay
             }
             bgColor = Color.lerp(const Color(0xFF030303), Colors.red.shade900, flash)!;
          }
          
          return Container(
            color: bgColor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // The Dropping Core Mass
                      Transform.translate(
                         offset: Offset(0, dropY),
                         child: Transform.scale(
                            scale: scale,
                            child: const Text('👋', style: TextStyle(fontSize: 100, shadows: [Shadow(color: Colors.black54, blurRadius: 20)])),
                         ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // The Title explicitly slammed into view at impact
                      if (t >= 0.2)
                        Opacity(
                          // Strobe in
                          opacity: t < 0.3 ? (t - 0.2) / 0.1 : 1.0,
                          child: Transform.scale(
                            // Squash and settle in
                            scale: t < 0.4 ? 1.4 - (0.4 * ((t - 0.2) / 0.2)) : 1.0,
                            child: const Text(
                              'SLAP THE SHIT\nOUT OF IT!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4.0,
                                height: 1.2,
                                shadows: [Shadow(color: Colors.redAccent, blurRadius: 30)]
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ]
            ),
          );
        },
      ),
    );
  }
}
