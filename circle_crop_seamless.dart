import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/icon_padded_seamless.png').readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;

  final width = image.width;
  final height = image.height;
  final centerX = width / 2;
  final centerY = height / 2;
  final radius = width / 2;

  final circleImage = img.Image(width: width, height: height, numChannels: 4);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final distanceSquared = dx * dx + dy * dy;

      if (distanceSquared <= radius * radius) {
        circleImage.setPixel(x, y, image.getPixel(x, y));
      } else {
        circleImage.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
      }
    }
  }

  File('assets/icon_circle_seamless.png').writeAsBytesSync(img.encodePng(circleImage));
  print('Successfully created seamless circle foreground.');
}
