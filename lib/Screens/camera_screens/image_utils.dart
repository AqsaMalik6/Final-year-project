import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:opencv_core/opencv.dart' as cv;

cv.Mat convertYUV420ToImage(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final img.Image imgBuffer = img.Image(width: width, height: height);

  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;

  final Uint8List yPlane = image.planes[0].bytes;
  final Uint8List uPlane = image.planes[1].bytes;
  final Uint8List vPlane = image.planes[2].bytes;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * width + x;
      final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

      final int yValue = yPlane[yIndex] & 0xFF;
      final int uValue = uPlane[uvIndex] & 0xFF;
      final int vValue = vPlane[uvIndex] & 0xFF;

      final int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
      final int g =
          (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
              .clamp(0, 255)
              .toInt();
      final int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

      imgBuffer.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // Convert `imgBuffer` to a List<List<List<int>>> (3D List) for OpenCV
  List<List<List<int>>> rgbData = List.generate(
      height,
      (y) => List.generate(width, (x) {
            img.Pixel pixel = imgBuffer.getPixel(x, y);
            return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
          }));

  return cv.Mat.from3DList(rgbData, cv.MatType.CV_8UC3);
}
