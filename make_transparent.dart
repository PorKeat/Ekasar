import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final empty = img.Image(width: 100, height: 100);
  // Filled with transparent color (0,0,0,0) by default in package:image, but let's be explicit
  img.fill(empty, color: img.ColorRgba8(0, 0, 0, 0));
  File('assets/icon_foreground.png').writeAsBytesSync(img.encodePng(empty));
  print('Transparent foreground created.');
}
