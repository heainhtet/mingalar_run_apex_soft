import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/app_settings.dart';

class CustomThemeSwitch extends ConsumerStatefulWidget {
  const CustomThemeSwitch({super.key});

  @override
  ConsumerState<CustomThemeSwitch> createState() => _CustomThemeSwitchState();
}

class _CustomThemeSwitchState extends ConsumerState<CustomThemeSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const width = 74.0;
    const height = 34.0;
    const handleSize = 36.0;
    final isDark = ref.watch(appSettingsProvider).themeMode == ThemeMode.dark;

    return Semantics(
      label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref
              .read(appSettingsProvider.notifier)
              .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF1A2140),
                      Color(0xFF0B1023),
                      Color(0xFF151A2E),
                    ]
                  : const [
                      Color(0xFF87D9F5),
                      Color(0xFF4DC9F6),
                      Color(0xFF2FB0E8),
                    ],
            ),
            border: Border.all(color: Colors.white.withAlpha(46)),
          ),
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: isDark ? 1 : 0,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: FadeTransition(
                    opacity: _starController.drive(
                      Tween<double>(begin: 0.4, end: 1),
                    ),
                    child: const CustomPaint(painter: _StarPainter()),
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                alignment: isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: handleSize,
                  height: handleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.4),
                      radius: 1.1,
                      colors: isDark
                          ? const [Color(0xFFF5F3FF), Color(0xFFC9C6E0)]
                          : const [Color(0xFFFFE07A), Color(0xFFFFB340)],
                    ),
                    border: Border.all(color: Colors.white.withAlpha(128)),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
                    size: 22,
                    color: isDark
                        ? const Color(0xFF2B2D42)
                        : const Color(0xFFFFF3C4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(217);
    for (final (position, radius) in [
      (Offset(size.width * 0.15, size.height * 0.3), 1.6),
      (Offset(size.width * 0.32, size.height * 0.62), 1.2),
      (Offset(size.width * 0.52, size.height * 0.28), 1.4),
    ]) {
      canvas.drawCircle(position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => false;
}
