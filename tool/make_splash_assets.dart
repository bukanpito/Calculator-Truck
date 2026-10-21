// Builds native splash art (Android + iOS) from the adaptive foreground.
// Run with: dart run tool/make_splash_assets.dart
import 'dart:io';

import 'package:image/image.dart' as img;

img.Image trimmedArt() {
  final source = img.decodePng(
    File('assets/icon/app_icon_foreground.png').readAsBytesSync(),
  )!;
  var left = source.width, right = 0, top = source.height, bottom = 0;
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      if (source.getPixel(x, y).a > 8) {
        if (x < left) left = x;
        if (x > right) right = x;
        if (y < top) top = y;
        if (y > bottom) bottom = y;
      }
    }
  }
  return img.copyCrop(
    source,
    x: left,
    y: top,
    width: right - left + 1,
    height: bottom - top + 1,
  );
}

void write(String path, img.Image art, int width) {
  final resized = img.copyResize(
    art,
    width: width,
    height: (art.height * width / art.width).round(),
    interpolation: img.Interpolation.average,
  );
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(resized));
  stdout.writeln('$path (${resized.width}x${resized.height})');
}

void main() {
  final art = trimmedArt();
  const buckets = {
    'mdpi': 128,
    'hdpi': 192,
    'xhdpi': 256,
    'xxhdpi': 384,
    'xxxhdpi': 512,
  };
  for (final entry in buckets.entries) {
    write(
      'android/app/src/main/res/drawable-${entry.key}/launch_logo.png',
      art,
      entry.value,
    );
  }
  const ios = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
  write('$ios/LaunchImage.png', art, 168);
  write('$ios/LaunchImage@2x.png', art, 336);
  write('$ios/LaunchImage@3x.png', art, 504);
}
