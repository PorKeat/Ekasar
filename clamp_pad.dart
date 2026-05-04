import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/icon_full.jpg').readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;

  final origW = image.width;
  final origH = image.height;
  
  // Pad from 1024 to 1350
  final newSize = 1350;
  final padded = img.Image(width: newSize, height: newSize, numChannels: 3);

  final offsetX = (newSize - origW) ~/ 2;
  final offsetY = (newSize - origH) ~/ 2;

  for (int y = 0; y < newSize; y++) {
    for (int x = 0; x < newSize; x++) {
      // Map to original coordinates
      int srcX = x - offsetX;
      int srcY = y - offsetY;

      // Clamp to edge
      if (srcX < 0) srcX = 0;
      if (srcX >= origW) srcX = origW - 1;
      if (srcY < 0) srcY = 0;
      if (srcY >= origH) srcY = origH - 1;

      // Set pixel
      padded.setPixel(x, y, image.getPixel(srcX, srcY));
    }
  }

  File('assets/icon_padded_seamless.png').writeAsBytesSync(img.encodePng(padded));
  print('Successfully created seamlessly clamped padded icon.');
}
