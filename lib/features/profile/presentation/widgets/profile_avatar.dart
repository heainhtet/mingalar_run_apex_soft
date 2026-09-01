import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.avatarPath,
    required this.size,
    this.onTap,
    this.showEditIndicator = false,
  });

  final String? avatarPath;
  final double size;
  final VoidCallback? onTap;
  final bool showEditIndicator;

  @override
  Widget build(BuildContext context) {
    final avatar = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.tabIndicatorColor,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: _AvatarImage(path: avatarPath, size: size),
        ),
      ),
    );

    final content = showEditIndicator
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: -2,
                bottom: -2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryButtonColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.defaultPrimaryText,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          )
        : avatar;

    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: 'Profile picture',
      child: InkResponse(onTap: onTap, radius: size / 1.5, child: content),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.path, required this.size});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) return _fallback();
    return Image.file(
      File(path!),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() {
    return Icon(
      Icons.person_outline_rounded,
      color: AppColors.defaultPrimaryText,
      size: size * 0.62,
    );
  }
}
