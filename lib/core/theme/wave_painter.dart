import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_colors.dart';

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw from back to front
    _drawWave(
      canvas, 
      size, 
      color: AppColors.waveTertiary.withOpacity(0.4), 
      offset: math.pi, 
      heightOffset: 20, 
      amplitude: 30
    );

    _drawWave(
      canvas, 
      size, 
      color: AppColors.waveSecondary.withOpacity(0.6), 
