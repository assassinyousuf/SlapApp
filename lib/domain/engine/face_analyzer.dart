import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/face_features.dart';

class FaceAnalyzer {
  static final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    )
  );

  static Future<FaceFeatures?> analyzeFace(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      
      // Decode image size accurately
      final bytes = await File(imagePath).readAsBytes();
      final image = await decodeImageFromList(bytes);
      
      final faces = await _detector.processImage(inputImage);
      if (faces.isEmpty) return null;
      
      final face = faces.first;
      
      final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
      final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;
      final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth]?.position;
      
      return FaceFeatures(
        leftEye: leftEye != null ? Point(leftEye.x, leftEye.y) : null,
        rightEye: rightEye != null ? Point(rightEye.x, rightEye.y) : null,
        bottomMouth: bottomMouth != null ? Point(bottomMouth.x, bottomMouth.y) : null,
        boundingBox: face.boundingBox,
        imageWidth: image.width,
        imageHeight: image.height,
      );
    } catch (e) {
      return null;
    }
  }
}
