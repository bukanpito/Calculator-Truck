// Prepares launcher art from the user-edited assets/icon/app_icon.png:
// keeps the icon square and builds a padded adaptive foreground.
// Run with: dart run tool/prepare_icon.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

final dark = img.ColorRgb8(0, 65, 46);

bool isBackground(img.Pixel pixel) =>
    (pixel.r - 0).abs() <= 8 &&
    (pixel.g - 65).abs() <= 8 &&
    (pixel.b - 46).abs() <= 8;

void main() {
  final source = img.decodePng(File('assets/icon/app_icon.png').readAsBytesSync())!;

  // Make a square 1024x1024 icon, padding with the brand green.
  final side = math.max(source.width, source.height);
  final square = img.Image(width: side, height: side, numChannels: 4);
  img.fill(square, color: dark);
  img.compositeImage(
    square,
    source,
    dstX: (side - source.width) ~/ 2,
    dstY: (side - source.height) ~/ 2,
  );
  final icon = img.copyResize(square, width: 1024, height: 1024);
  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(icon));

  // Find the artwork bounds so the adaptive foreground can be centered.
  var left = icon.width, right = 0, top = icon.height, bottom = 0;
  for (var y = 0; y < icon.height; y++) {
    for (var x = 0; x < icon.width; x++) {
      if (!isBackground(icon.getPixel(x, y))) {
        left = math.min(left, x);
        right = math.max(right, x);
        top = math.min(top, y);
        bottom = math.max(bottom, y);
      }
    }
  }
  final art = img.copyCrop(
    icon,
    x: left,
    y: top,
    width: right - left + 1,
    height: bottom - top + 1,
  );

  // Safe zone: keep the truck inside the center ~68% of the layer.
  final target = (1024 * 0.68).round();
  final scale = target / art.width;
  final resized = img.copyResize(
    art,
    width: target,
    height: (art.height * scale).round(),
    interpolation: img.Interpolation.average,
  );
  final foreground = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(foreground, color: img.ColorRgba8(0, 0, 0, 0));
  img.compositeImage(
    foreground,
    resized,
    dstX: (1024 - resized.width) ~/ 2,
    dstY: (1024 - resized.height) ~/ 2,
  );
  // Key out the green background so only the truck remains.
  for (final pixel in foreground) {
    if (isBackground(pixel)) pixel.a = 0;
  }
  File('assets/icon/app_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(foreground));

  stdout.writeln('art bounds: $left,$top ${right - left + 1}x${bottom - top + 1}');
  stdout.writeln('icon + foreground written');
}
