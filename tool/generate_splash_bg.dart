// Run once before flutter_native_splash:create
//   dart run tool/generate_splash_bg.dart
//
// Reads assets/images/splash_bg.jpg, applies a medium Gaussian blur,
// and writes assets/images/splash_bg_blur.jpg for use as the native
// splash background.

import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  const input  = 'assets/images/splash_bg.jpg';
  const output = 'assets/images/splash_bg_blur.jpg';

  stdout.write('Reading $input ... ');
  final bytes = await File(input).readAsBytes();
  final image = img.decodeJpg(bytes);
  if (image == null) {
    stderr.writeln('ERROR: could not decode $input');
    exit(1);
  }
  stdout.writeln('${image.width}x${image.height}');

  stdout.write('Blurring (radius 10) ... ');
  final blurred = img.gaussianBlur(image, radius: 10);
  stdout.writeln('done');

  stdout.write('Saving $output ... ');
  await File(output).writeAsBytes(img.encodeJpg(blurred, quality: 88));
  stdout.writeln('done');
}
