import 'package:flutter/material.dart';

class HomeFeatureChallengeCard extends StatelessWidget {
  const HomeFeatureChallengeCard({
    super.key,
    required this.assetPath,
    this.onTap,
  });

  static const size = Size(370, 185);

  final String assetPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: Ink.image(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
          child: InkWell(onTap: onTap),
        ),
      ),
    );
  }
}
