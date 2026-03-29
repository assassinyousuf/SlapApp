// ignore_for_file: deprecated_member_use, unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _shockwaveController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _shockwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _shockwaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slapState = ref.watch(slapControllerProvider);
    final isSlapped = slapState.status == 'Slapped!';

    if (isSlapped) {
      _shockwaveController.forward(from: 0.0);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E), // Deep cinematic background
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Deep Radial Background Gradient (Depth Cue)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF1E1E2C), Color(0xFF020202)],
              ),
            ),
          ),
          
          // Outer Shockwave Ripples (Fades outwards heavily blurred)
          AnimatedBuilder(
            animation: _shockwaveController,
            builder: (context, child) {
              final scale = 1.0 + (_shockwaveController.value * 5.0);
              final opacity = 1.0 - _shockwaveController.value;
              
              if (_shockwaveController.value == 0) return const SizedBox.shrink();
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(opacity * 0.8),
                      width: 15 * opacity,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(opacity * 0.5),
                        blurRadius: 60,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          // Main Hyper-Realistic Glowing Orb
          AnimatedBuilder(
            animation: Listenable.merge([_breathingController, _shockwaveController]),
            builder: (context, child) {
              // Smooth liquid drifting/breathing offsets
              final hoverOffset = Curves.easeInOutSine.transform(_breathingController.value) * 30 - 15;
              final breathScale = 1.0 + (Curves.easeInOutSine.transform(_breathingController.value) * 0.04);
              
              // Extreme physical impact (squash-and-stretch kinematics)
              double impactScaleX = 1.0;
              double impactScaleY = 1.0;
              double innerGlowIntense = 0.5;
              
              if (_shockwaveController.isAnimating) {
                // Highly elastic ripple effect
                final bounce = Curves.elasticOut.transform(_shockwaveController.value);
                final compression = 1.0 - bounce; 
                
                impactScaleX = 1.0 + compression * 0.6; // widely distorts on hit
                impactScaleY = 1.0 - compression * 0.4; // crushes downward flat
                innerGlowIntense = 1.0 - (_shockwaveController.value * 0.5);
              }

              return Transform.translate(
                offset: Offset(0, hoverOffset),
                child: Transform.scale(
                  scale: breathScale,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scale(impactScaleX, impactScaleY, 1.0),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSlapped
                              ? [
                                  Colors.orange.shade300,
                                  Colors.red.shade900,
                                  Colors.black,
                                ]
                              : [
                                  const Color(0xFF6A5ACD), // Bright Periwinkle
                                  const Color(0xFF191970), // Midnight Blue
                                  Colors.black,
                                ],
                          stops: const [0.1, 0.7, 1.0], // Emulates volumetric shadow curve
                        ),
                        boxShadow: [
                          // Radiant colored inner plasma glow
                          BoxShadow(
                            color: isSlapped
                                ? Colors.redAccent.withOpacity(innerGlowIntense)
                                : const Color(0xFF4B42F5).withOpacity(0.5),
                            blurRadius: isSlapped ? 150 : 80,
                            spreadRadius: isSlapped ? 40 : 10,
                          ),
                          // Dark 3D occlusion shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.9),
                            blurRadius: 30,
                            offset: const Offset(15, 25), // Strong directional lighting cast
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glassmorphic / Liquid Specular Highlight (Rim lighting)
                          Positioned(
                            top: 25,
                            left: 40,
                            child: Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.7),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          
                          // Chromatic Aberration Underlayer
                          if (isSlapped)
                            Positioned(
                              top: 92,
                              left: 88,
                              child: Icon(
                                Icons.bolt_rounded,
                                size: 100,
                                color: Colors.cyanAccent.withOpacity(0.8),
                              ),
                            ),
                            
                          // Core Luminous Icon
                          Icon(
                            isSlapped ? Icons.bolt_rounded : Icons.fingerprint_rounded,
                            size: 100,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: isSlapped ? Colors.yellowAccent : Colors.cyanAccent,
                                blurRadius: isSlapped ? 40 : 20,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Futuristic Status Text Overlay
          Positioned(
            bottom: 80,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: isSlapped 
                  ? const Text(
                      'IMPACT DETECTED',
                      key: ValueKey('IMPACT'),
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                        shadows: [
                          Shadow(color: Colors.red, blurRadius: 20)
                        ]
                      ),
                    )
                  : const Text(
                      'READY FOR SLAP',
                      key: ValueKey('ARMED'),
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
