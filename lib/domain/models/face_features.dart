import 'dart:math';
import 'dart:ui';

class FaceFeatures {
  final Point<int>? leftEye;
  final Point<int>? rightEye;
  final Point<int>? bottomMouth;
  final Rect boundingBox;
  final int imageWidth;
  final int imageHeight;

  FaceFeatures({
    required this.leftEye,
    required this.rightEye,
    required this.bottomMouth,
    required this.boundingBox,
    required this.imageWidth,
    required this.imageHeight,
  });
}
