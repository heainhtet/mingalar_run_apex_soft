import 'dart:io';

import 'package:image/image.dart' as image;

const _sourcePath = 'assets/appLogo.png';
const _outputDirectory = 'assets/branding';
final _brandBlue = image.ColorRgb8(0, 73, 255);
final _transparent = image.ColorRgba8(0, 0, 0, 0);

void main() {
  final source = image.decodePng(File(_sourcePath).readAsBytesSync());
  if (source == null) {
    throw StateError('Unable to decode $_sourcePath');
  }

  Directory(_outputDirectory).createSync(recursive: true);

  _writeCompositedAsset(
    source: source,
    canvasSize: 1024,
    logoSize: 820,
    background: _brandBlue,
    outputPath: '$_outputDirectory/app_icon.png',
  );
  _writeCompositedAsset(
    source: source,
    canvasSize: 1024,
    logoSize: 620,
    background: _transparent,
    outputPath: '$_outputDirectory/app_icon_foreground.png',
  );
  _writeCompositedAsset(
    source: source,
    canvasSize: 1152,
    logoSize: 720,
    background: _transparent,
    outputPath: '$_outputDirectory/app_logo_native.png',
  );
  _writeCompositedAsset(
    source: source,
    canvasSize: 1024,
    logoSize: 940,
    background: _transparent,
    outputPath: '$_outputDirectory/app_logo_display.png',
  );
  _writeSplashBackground('$_outputDirectory/native_splash_background.png');
}

void _writeCompositedAsset({
  required image.Image source,
  required int canvasSize,
  required int logoSize,
  required image.Color background,
  required String outputPath,
}) {
  final canvas = image.Image(
    width: canvasSize,
    height: canvasSize,
    numChannels: 4,
  );
  image.fill(canvas, color: background);

  final logo = image.copyResize(
    source,
    width: logoSize,
    height: logoSize,
    interpolation: image.Interpolation.cubic,
  );
  final offset = (canvasSize - logoSize) ~/ 2;
  image.compositeImage(canvas, logo, dstX: offset, dstY: offset);

  File(outputPath).writeAsBytesSync(image.encodePng(canvas, level: 9));
}

void _writeSplashBackground(String outputPath) {
  const width = 1200;
  const height = 2400;
  final background = image.Image(width: width, height: height);

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final progress = ((x / width) + (y / height)) / 2;
      final red = _lerpChannel(0x00, 0x19, progress);
      final green = _lerpChannel(0x49, 0x3C, progress);
      final blue = _lerpChannel(0xFF, 0xB8, progress);
      background.setPixelRgba(x, y, red, green, blue, 255);
    }
  }

  final ringColor = image.ColorRgba8(255, 255, 255, 18);
  for (final radius in [310, 470, 650]) {
    image.drawCircle(
      background,
      x: width ~/ 2,
      y: (height * 0.46).round(),
      radius: radius,
      color: ringColor,
      antialias: true,
    );
  }

  File(outputPath).writeAsBytesSync(image.encodePng(background, level: 9));
}

int _lerpChannel(int start, int end, double progress) {
  return (start + ((end - start) * progress)).round().clamp(0, 255);
}
