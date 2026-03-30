import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../application/providers.dart';
import '../../data/services/ai_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _shockwaveController;

  @override
  void initState() {
    super.initState();
    _shockwaveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _shockwaveController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      ref.read(selectedImageProvider.notifier).setImage(pickedFile.path);
      ref.read(faceFeaturesProvider.notifier).analyze(pickedFile.path);
      ref.read(sadImageProvider.notifier).setImage(null);
      
      AiService.generateSadFace(pickedFile.path).then((sadPath) {
        if (sadPath != null && mounted) {
           ref.read(sadImageProvider.notifier).setImage(sadPath);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slapState = ref.watch(slapControllerProvider);
    final isSlapped = slapState.status == 'Slapped!';
    final imagePath = ref.watch(selectedImageProvider);
    final sadImagePath = ref.watch(sadImageProvider);
    final classicMode = ref.watch(classicModeProvider);

    ref.listen(slapControllerProvider, (previous, next) {
      if (next.status == 'Slapped!' && previous?.status != 'Slapped!') {
        _shockwaveController.forward(from: 0.0);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: isSlapped ? 2.0 : 1.5,
                colors: isSlapped 
                    ? [Colors.red.shade900, Colors.black]
                    : [const Color(0xFF1E1E2C), const Color(0xFF020202)],
              ),
            ),
          ),
          
          if (imagePath == null && !classicMode)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text("CHOOSE YOUR WEAPON", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                   const SizedBox(height: 60),
                   ElevatedButton.icon(
                      onPressed: () => _pickImage(ref),
                      icon: const Icon(Icons.add_a_photo, size: 30),
                      label: const Text('UPLOAD A VICTIM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                   ),
                   const SizedBox(height: 30),
                   const Text("OR", style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 30),
                   OutlinedButton.icon(
                      onPressed: () => ref.read(classicModeProvider.notifier).toggle(true),
                      icon: const Icon(Icons.sports_mma, size: 30, color: Colors.redAccent),
                      label: const Text('JUST HIT DEVICE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        side: const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                   ),
                ],
              ),
            )
          else ...[
            AnimatedBuilder(
              animation: _shockwaveController,
              builder: (context, child) {
                double impactScaleX = 1.0;
                double impactScaleY = 1.0;
                double offsetX = 0.0;
                double offsetY = 0.0;
                double rotation = 0.0;
                
                if (_shockwaveController.isAnimating) {
                  final bump = Curves.elasticOut.transform(_shockwaveController.value);
                  final compression = 1.0 - bump;
                  impactScaleX = 1.0 + compression * 0.8; 
                  impactScaleY = 1.0 - compression * 0.4; 
                  offsetX = (compression * 40.0) * (DateTime.now().millisecondsSinceEpoch % 3 == 0 ? 1 : -1);
                  offsetY = (compression * 40.0) * (DateTime.now().millisecondsSinceEpoch % 2 == 0 ? 1 : -1);
                  rotation = compression * 0.3; 
                }

                Widget renderTarget() {
                   if (classicMode) {
                      return Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                  colors: isSlapped ? [Colors.red, Colors.red.shade900] : [Colors.redAccent.withAlpha(100), Colors.black],
                              ),
                              border: Border.all(color: Colors.redAccent.withAlpha(100), width: 3),
                              boxShadow: [
                                  if (isSlapped) BoxShadow(color: Colors.redAccent.withAlpha(200), blurRadius: 100, spreadRadius: 30)
                              ],
                          ),
                          child: Center(
                             child: Text(isSlapped ? '💥 OUCH!' : 'HIT ME', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic)),
                          ),
                      );
                   } else {
                      final activePath = (isSlapped && sadImagePath != null) ? sadImagePath : imagePath;
                      return Container(
                        width: 320,
                        height: 480,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            if (isSlapped)
                              BoxShadow(color: Colors.redAccent.withAlpha(200), blurRadius: 100, spreadRadius: 30)
                          ],
                          image: DecorationImage(
                            image: FileImage(File(activePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: isSlapped 
                            ? Positioned.fill(
                                child: Container(color: Colors.redAccent.withAlpha((150 * (1-_shockwaveController.value)).toInt())),
                              )
                            : null,
                      );
                   }
                }

                return Transform.translate(
                  offset: Offset(offsetX, offsetY),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scaleX: impactScaleX,
                      scaleY: impactScaleY,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                           renderTarget(),
                           // Hand sweeps universally across both target modes
                           if (isSlapped && _shockwaveController.value < 0.4)
                                Positioned(
                                  top: classicMode ? 40 : 150,
                                  left: _shockwaveController.value < 0.25 ? (classicMode ? 250.0 : 320.0) - (_shockwaveController.value * 4 * 600) : -1000.0,
                                  child: Transform.rotate(
                                      angle: -_shockwaveController.value * 2,
                                      child: const Text('👋', style: TextStyle(fontSize: 160, shadows: [Shadow(color: Colors.black45, blurRadius: 40)]))
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
            
            Positioned(
              top: 60,
              right: 20,
              child: IconButton(
                 icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
                 onPressed: () {
                    ref.read(selectedImageProvider.notifier).setImage(null);
                    ref.read(sadImageProvider.notifier).setImage(null);
                    ref.read(classicModeProvider.notifier).toggle(false);
                 }
              ),
            ),
          ]
        ],
      ),
    );
  }
}
