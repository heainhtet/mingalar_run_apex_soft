import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BottomNavItemContent extends StatelessWidget {
  const BottomNavItemContent({
    super.key,
    required this.icon,
    required this.label,
    required this.labelStyle,
  });

  final Widget icon;
  final String label;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const Gap(2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ],
        ),
      ),
    );
  }
}
