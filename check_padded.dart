import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/icon_padded.png').readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;
  print('Size: ${image.width} x ${image.height}');
  print('Center pixel: ${image.getPixel(1024, 1024).toString()}');
}
