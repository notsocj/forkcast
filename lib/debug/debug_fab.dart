import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'debug_config.dart';
import 'debug_screen_switcher.dart';

class DebugFloatingButton extends StatelessWidget {
  const DebugFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show if debug FAB is enabled
    if (!DebugConfig.showDebugFAB) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.white,
        heroTag: "debug_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DebugScreenSwitcher(),
            ),
          );
        },
        child: const Icon(Icons.bug_report, size: 20),
      ),
    );
  }
}

// Wrapper widget to easily add debug functionality to any screen
class DebugWrapper extends StatelessWidget {
  final Widget child;
  
  const DebugWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!DebugConfig.showDebugFAB) {
      return child;
    }

    return Stack(
      children: [
        child,
        const DebugFloatingButton(),
      ],
    );
  }
}