import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/icon_padded.png').readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) return;

  final width = image.width;
  final height = image.height;
  final centerX = width / 2;
  final centerY = height / 2;
  // We want the circle radius to be large enough to contain the logo, but small enough to chop off the square corners.
  // The safe zone is 72dp out of 108dp. 
  // A circle with radius = width/2 will just touch the edges.
  final radius = width / 2;

  // Create a new image that supports alpha
  final circleImage = img.Image(width: width, height: height, numChannels: 4);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final distanceSquared = dx * dx + dy * dy;

      if (distanceSquared <= radius * radius) {
        // Inside the circle, copy the pixel
        circleImage.setPixel(x, y, image.getPixel(x, y));
      } else {
        // Outside the circle, make it transparent
        circleImage.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
      }
    }
  }

  File('assets/icon_circle.png').writeAsBytesSync(img.encodePng(circleImage));
  print('Successfully created circle foreground.');
}
