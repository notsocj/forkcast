import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProgressPill extends StatelessWidget {
  final int current;
  final int total;
  final double width;

  const ProgressPill({
    Key? key,
    required this.current,
    required this.total,
    this.width = 220,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (total > 0) ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background track (subtle)
            Positioned.fill(
              child: Container(
                color: AppColors.lightGray,
              ),
            ),
            // Foreground progress with gradient and glow
            FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.successGreen,
                      AppColors.successGreen.withOpacity(0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successGreen.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
            // Optional subtle inner highlight at the leading edge
            Positioned(
              left: (width * progress) - 8 < 0 ? 0 : (width * progress) - 8,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
