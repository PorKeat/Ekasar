import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/icon_circle_seamless.png').readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;
  print('Size: ${image.width} x ${image.height}');
  print('Center pixel: ${image.getPixel(image.width~/2, image.height~/2).toString()}');
}
