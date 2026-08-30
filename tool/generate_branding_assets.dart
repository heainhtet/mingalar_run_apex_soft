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
    logoSize: 600,
    background: _transparent,
    outputPath: '$_outputDirectory/app_logo_splash.png',
  );
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
