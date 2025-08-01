import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_colors.dart';

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
