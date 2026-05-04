import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final empty = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(empty, color: img.ColorRgba8(0, 0, 0, 0));
  File('assets/icon_foreground.png').writeAsBytesSync(img.encodePng(empty));
  print('Transparent foreground created at 1024x1024.');
}
