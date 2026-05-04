import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/icon_full.jpg').readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;

  // Pad to 1350 to make the logo larger but not cropped
  final newSize = 1350;
  final padded = img.Image(width: newSize, height: newSize);
  final bgColor = image.getPixel(0, 0);
  img.fill(padded, color: bgColor);

  final offsetX = (newSize - image.width) ~/ 2;
  final offsetY = (newSize - image.height) ~/ 2;
  img.compositeImage(padded, image, dstX: offsetX, dstY: offsetY);

  File('assets/icon_padded.png').writeAsBytesSync(img.encodePng(padded));
  print('Successfully generated slightly padded icon.');
}
