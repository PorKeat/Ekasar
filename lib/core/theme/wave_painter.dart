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
      offset: math.pi / 2, 
      heightOffset: 10, 
      amplitude: 25
    );

    _drawWave(
      canvas, 
      size, 
      color: AppColors.wavePrimary, 
      offset: 0, 
      heightOffset: 0, 
      amplitude: 20
    );
  }

  void _drawWave(
    Canvas canvas, 
    Size size, {
    required Color color, 
    required double offset, 
    required double heightOffset, 
    required double amplitude
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    
    // The base height for this wave, starting from the bottom of the available size
    final baseHeight = size.height - 40 + heightOffset; // 40 is padding for the amplitude

    path.lineTo(0, baseHeight);

    for (double i = 0; i <= size.width; i++) {
      final waveOffset = math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi) + offset);
      path.lineTo(i, baseHeight + waveOffset * amplitude);
    }

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class AnimatedWaveBackground extends StatefulWidget {
  final double height;

  const AnimatedWaveBackground({
    super.key, 
    required this.height,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(_controller.value),
            size: Size(double.infinity, widget.height),
          );
        },
      ),
    );
  }
}
// nit: clean up
