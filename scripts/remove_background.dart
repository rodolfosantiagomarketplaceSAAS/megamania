import 'dart:io';
import 'package:image/image.dart' as img;

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run scripts/remove_background.dart <image_path>');
    exit(1);
  }
  
  final file = File(args[0]);
  if (!file.existsSync()) {
    print('Error: File not found: ${args[0]}');
    exit(1);
  }
  
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Error: Failed to decode image: ${args[0]}');
    exit(1);
  }
  
  print('Processing ${args[0]} (${image.width}x${image.height})...');
  int count = 0;
  for (final pixel in image) {
    // Check if pixel is close to black (RGB < 18)
    if (pixel.r < 18 && pixel.g < 18 && pixel.b < 18) {
      pixel.a = 0;
      count++;
    }
  }
  
  final outputBytes = img.encodePng(image);
  file.writeAsBytesSync(outputBytes);
  print('Done! Replaced $count black pixels with transparent pixels.');
}
