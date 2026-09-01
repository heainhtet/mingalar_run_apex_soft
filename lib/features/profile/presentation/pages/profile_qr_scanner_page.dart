import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/common/widgets/app_confirmation_dialog.dart';
import '../../../../core/common/widgets/app_flushbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/scanned_profile_dialog.dart';

@RoutePage()
class ProfileQrScannerPage extends StatefulWidget {
  const ProfileQrScannerPage({super.key});

  @override
  State<ProfileQrScannerPage> createState() => _ProfileQrScannerPageState();
}

class _ProfileQrScannerPageState extends State<ProfileQrScannerPage> {
  late final MobileScannerController _controller;
  bool _handlingScan = false;
  bool _handlingCameraError = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.runGradientEnd,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _handleCapture,
              errorBuilder: (context, error) {
                _handleCameraError(error);
                return const SizedBox.expand();
              },
            ),
          ),
          const Positioned.fill(child: _ScannerOverlay()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
              child: Column(
                children: [
                  _ScannerHeader(
                    onBack: context.router.maybePop,
                    onTorch: _controller.toggleTorch,
                  ),
                  const Spacer(),
                  const _ScannerInstructions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCapture(BarcodeCapture capture) async {
    if (_handlingScan || capture.barcodes.isEmpty) return;
    final rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null) return;

    _handlingScan = true;
    final profile = UserProfile.tryParseQrPayload(rawValue);
    if (profile == null) {
      if (mounted) {
        AppFlushbar.error(context, 'profileScreen.invalidQr'.tr());
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      _handlingScan = false;
      return;
    }

    await _controller.stop();
    if (mounted) await showScannedProfileDialog(context, profile: profile);
    if (mounted) await _controller.start();
    _handlingScan = false;
  }

  void _handleCameraError(MobileScannerException error) {
    if (_handlingCameraError) return;
    _handlingCameraError = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final openSettings = await showAppConfirmationDialog(
        context,
        title: 'profileScreen.cameraAccessTitle'.tr(),
        message: 'profileScreen.cameraUnavailable'.tr(),
        cancelLabel: 'runScreen.cancel'.tr(),
        confirmLabel: 'runScreen.openSettings'.tr(),
        icon: Icons.camera_alt_outlined,
        confirmColor: AppColors.primaryButtonColor,
      );
      if (openSettings) await openAppSettings();
      if (mounted) await context.router.maybePop();
    });
  }
}

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader({required this.onBack, required this.onTorch});

  final VoidCallback onBack;
  final VoidCallback onTorch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ScannerAction(icon: Icons.arrow_back_rounded, onPressed: onBack),
        Expanded(
          child: Text(
            'profileScreen.scanQr'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.semiBold().white
                .s(20)
                .copyWith(color: AppColors.defaultPrimaryText, height: 1.2),
          ),
        ),
        _ScannerAction(icon: Icons.flash_on_rounded, onPressed: onTorch),
      ],
    );
  }
}

class _ScannerAction extends StatelessWidget {
  const _ScannerAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.black.withAlpha(90),
        foregroundColor: AppColors.defaultPrimaryText,
      ),
      icon: Icon(icon),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _ScannerOverlayPainter()));
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width * 0.68;
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.44),
      width: side,
      height: side,
    );
    final overlay = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlay, Paint()..color = AppColors.black.withAlpha(145));

    final border = Paint()
      ..color = AppColors.tabIndicatorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(24)),
      border,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerInstructions extends StatelessWidget {
  const _ScannerInstructions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'profileScreen.scanQrHint'.tr(),
        textAlign: TextAlign.center,
        style: AppTextStyles.regular()
            .s(13)
            .copyWith(color: AppColors.cardDescriptionText, height: 1.4),
      ),
    );
  }
}
