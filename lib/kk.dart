// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:image/image.dart' as img;

// double calculateLaplacianVariance(Uint8List bytes, int width, int height) {
//   final image = img.decodeImage(bytes)!;
//   final grayImage = img.grayscale(image);
//   final laplacianKernel = [
//     [0, 1, 0],
//     [1, -4, 1],
//     [0, 1, 0]
//   ];

//   double sum = 0.0;
//   int count = 0;

//   for (int y = 1; y < height - 1; y++) {
//     for (int x = 1; x < width - 1; x++) {
//       double pixel = 0.0;
//       for (int j = -1; j <= 1; j++) {
//         for (int i = -1; i <= 1; i++) {
//           final grayValue = grayImage.getPixel(x + i, y + j);
//           pixel += (grayValue & 0xFF) * laplacianKernel[j + 1][i + 1];
//         }
//       }
//       sum += pixel * pixel;
//       count++;
//     }
//   }

//   return sum / count;
// }

