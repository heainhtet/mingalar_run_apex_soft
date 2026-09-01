import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_state_provider.dart';
import '../../services/theme_preference_service.dart';

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

  void _setTheme(WidgetRef ref, ThemeMode mode) {
    HapticFeedback.lightImpact();
    ref.read(themeModeProvider.notifier).state = mode;
    ThemePreferencesService.saveThemeIndex(mode.index);
  }

  @override
  Widget build(BuildContext context) {
    const double width = 74.0;
    const double height = 34.0;
    const double handleSize = 36.0;
    const double padding = 3.0;

    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Semantics(
      label: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
      button: true,
      child: GestureDetector(
        onTap: () =>
            _setTheme(ref, isDarkMode ? ThemeMode.light : ThemeMode.dark),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? const [
                      Color(0xFF1A2140),
                      Color(0xFF0B1023),
                      Color(0xFF151A2E),
                    ]
                  : [
                      const Color(0xFF87D9F5),
                      const Color(0xFF4DC9F6),
                      const Color(0xFF2FB0E8),
                    ],
            ),

            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(padding),
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: isDarkMode ? 1 : 0,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: FadeTransition(
                    opacity: _starController.drive(Tween(begin: 0.4, end: 1.0)),
                    child: const CustomPaint(painter: _StarPainter()),
                  ),
                ),
              ),

              AnimatedAlign(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                alignment: isDarkMode
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
                      colors: isDarkMode
                          ? const [Color(0xFFF5F3FF), Color(0xFFC9C6E0)]
                          : [
                              Color(0xFFFFE07A).withAlpha(0),
                              Color(0xFFFFB340).withAlpha(0),
                            ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          RotationTransition(
                            turns: Tween(
                              begin: 0.6,
                              end: 0.0,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                      child: isDarkMode
                          ? const Icon(
                              Icons.dark_mode_rounded,
                              key: ValueKey('moon'),
                              size: 22,
                              color: Color(0xFF2B2D42),
                            )
                          : const Icon(
                              Icons.wb_sunny_rounded,
                              key: ValueKey('sun'),
                              size: 22,
                              color: Color(0xFFFFF3C4),
                            ),
                    ),
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
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final starPositions = [
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.32, size.height * 0.62),
      Offset(size.width * 0.52, size.height * 0.28),
    ];
    final radii = [1.6, 1.2, 1.4];
    for (var i = 0; i < starPositions.length; i++) {
      canvas.drawCircle(starPositions[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => false;
}
