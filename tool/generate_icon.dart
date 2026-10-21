// Generates the Material Tracker launcher art: a white truck on dark green.
// Run with: dart run tool/generate_icon.dart
import 'dart:io';

import 'package:image/image.dart' as img;

final dark = img.ColorRgb8(0, 65, 46);
final accent = img.ColorRgb8(150, 191, 138);
final white = img.ColorRgb8(255, 255, 255);
final transparent = img.ColorRgba8(0, 0, 0, 0);

void drawTruck(img.Image canvas, {required double scale}) {
  final shift = (1024 - 1024 * scale) / 2;
  int x(num value) => (value * scale + shift).round();
  int size(num value) => (value * scale).round();

  void rect(num x1, num y1, num x2, num y2, img.Color color) => img.fillRect(
    canvas,
    x1: x(x1),
    y1: x(y1),
    x2: x(x2),
    y2: x(y2),
    color: color,
  );

  // Ground line
  rect(196, 792, 852, 812, accent);

  // Cargo box and cab
  rect(188, 396, 650, 646, white);
  rect(650, 470, 862, 646, white);

  // Cab window
  rect(690, 498, 806, 586, dark);

  // Chassis
  rect(174, 646, 874, 682, accent);

  // Wheels
  for (final center in [332, 726]) {
    img.fillCircle(
      canvas,
      x: x(center),
      y: x(712),
      radius: size(62),
      color: white,
    );
    img.fillCircle(
      canvas,
      x: x(center),
      y: x(712),
      radius: size(28),
      color: dark,
    );
  }

  // Load lines on the cargo box
  rect(230, 470, 596, 492, accent);
  rect(230, 540, 596, 562, accent);
}

img.Image render({required bool background}) {
  final canvas = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(canvas, color: background ? dark : transparent);
  drawTruck(canvas, scale: background ? 0.82 : 0.6);
  return canvas;
}

void main() {
  final directory = Directory('assets/icon')..createSync(recursive: true);
  File('${directory.path}/app_icon.png')
      .writeAsBytesSync(img.encodePng(render(background: true)));
  File('${directory.path}/app_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(render(background: false)));
  stdout.writeln('Icon written to ${directory.path}');
}
