import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:opencv_core/opencv.dart' as cv;
import 'image_utils.dart';

enum _Codes {
  init,
  busy,
  ready,
  detect,
  result, capture,
}

class _Command {
  const _Command(this.code, {this.args});

  final _Codes code;
  final List<Object>? args;
}

class Detector {
  Detector._(
    this._isolate,
  );

  final Isolate _isolate;
  late final SendPort _sendPort;
  bool _isReady = false;

  final StreamController<Map<String, dynamic>> resultsStream =
      StreamController<Map<String, dynamic>>();

  static Future<Detector> start() async {
    final ReceivePort receivePort = ReceivePort();

    final Isolate isolate =
        await Isolate.spawn(_DetectorServer._run, receivePort.sendPort);

    final Detector result = Detector._(
      isolate,
      // await _loadModel(),
      // await _loadLabels(),
    );
    receivePort.listen((message) {
      result._handleCommand(message as _Command);
    });
    return result;
  }

  void processFrame(Map<String, dynamic> data) {
    if (_isReady) {
      _sendPort.send(_Command(_Codes.detect, args: [data]));
    }
  }

  void processStillImage(XFile capturedImage) {
    if (_isReady) {
      _sendPort.send(_Command(_Codes.capture, args: [capturedImage]));
    }
  }

  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.args?[0] as SendPort;
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(_Command(_Codes.init, args: [
          rootIsolateToken,
        ]));
      case _Codes.ready:
        _isReady = true;
      case _Codes.busy:
        _isReady = false;
      case _Codes.result:
        _isReady = true;
        resultsStream.add(command.args?[0] as Map<String, dynamic>);
      default:
        debugPrint('Detector unrecognized command: ${command.code}');
    }
  }

  void stop() {
    _isolate.kill();
  }
}

class _DetectorServer {
  _DetectorServer(this._sendPort);
  final SendPort _sendPort;

  static void _run(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    final _DetectorServer server = _DetectorServer(sendPort);
    receivePort.listen((message) async {
      final _Command command = message as _Command;
      await server._handleCommand(command);
    });

    sendPort.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }

  Future<void> _handleCommand(_Command command) async {
    switch (command.code) {
      case _Codes.init:
        RootIsolateToken rootIsolateToken =
            command.args?[0] as RootIsolateToken;

        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

        _sendPort.send(const _Command(_Codes.ready));
      case _Codes.detect:
        _sendPort.send(const _Command(_Codes.busy));
        _convertCameraImage(command.args?[0] as Map<String, dynamic>);

      default:
        debugPrint('_DetectorService unrecognized command ${command.code}');
    }
  }

  void _convertCameraImage(Map<String, dynamic> data) async {
    Map<String, dynamic> results = {};
    if (Platform.isAndroid) {
      var image = convertYUV420ToImage(data['image'] as CameraImage);
      results = await pickAndProcessImage(image, data['type']);
    }

    _sendPort.send(_Command(_Codes.result, args: [results]));
  }

  Future<Map<String, dynamic>> pickAndProcessImage(
      cv.Mat image, String type) async {
    List<cv.VecPoint> _contours = [];
    List<Map<String, double>> measurmenmts = [];
    try {
      cv.Mat src = await cv.cvtColorAsync(image, cv.COLOR_RGB2GRAY);
      src = await cv.rotateAsync(src, cv.ROTATE_90_CLOCKWISE);
      // Ensure conversion to uint8 (CV_8UC1)

      cv.Mat gray = cv.Mat.zeros(src.rows, src.cols, cv.MatType.CV_8UC1);
      gray = await src.convertToAsync(cv.MatType.CV_8UC1);
      // Apply Gaussian blur
      cv.Mat blurred = await cv.gaussianBlurAsync(gray, (7, 7), 0);

      // Apply adaptive threshold
      cv.Mat thresh = await cv.adaptiveThresholdAsync(blurred, 255,
          cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY_INV, 11, 2);
      var contours = await cv.findContoursAsync(
          thresh, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);

      var sortedContours = sortContoursByArea(contours.$1);

      for (var contour in sortedContours) {
        cv.Rect rect = cv.boundingRect(contour);
        double aspectRatio = rect.height / rect.width;
        // print("${cv.contourArea(contour)},$aspectRatio");
        if (type == 'sweat') {
          if (aspectRatio > 0.4 &&
              aspectRatio <= 1.8 &&
              cv.contourArea(contour) > 1000) {
            _contours.add(contour);
            double pixelToCmRatio = 0.1;
            double chestWidth = (rect.width * pixelToCmRatio) * 0.9;
            double sweatshirtLength = (rect.height * pixelToCmRatio) * 0.1;
            double sleeveLength = (rect.height * 0.5) * pixelToCmRatio;
            double shoulderWidth = (rect.width * 0.4) * pixelToCmRatio;

            measurmenmts.add({
              "Chest Width": chestWidth,
              "Sweatshirt Length": sweatshirtLength,
              "Sleeve Length": sleeveLength,
              "Shoulder Width": shoulderWidth,
            });
          }
        } else if (type == 'jeans'){
          if (aspectRatio > 0.4 &&
              aspectRatio < 1.8 &&
              cv.contourArea(contour) > 500) {
            _contours.add(contour);

            double pixelToCmRatio = 0.1;
            double waist = (rect.height * pixelToCmRatio - 23) * 0.75;
            double inseam = (rect.height * pixelToCmRatio - 23) * 0.95;
            double length = (rect.height) * pixelToCmRatio - 23.5;

            measurmenmts.add({
              "Waist": waist,
              "Inseam": inseam,
              "Length": length,
            });
          }
        }
      }

      return {
        "contours": serializeContours(_contours, image.width, image.height),
        "measurments": measurmenmts
      };
    } catch (e) {
      print("Error processing image: $e");
      return {};
    }
  }

  List<cv.VecPoint> sortContoursByArea(cv.VecVecPoint contours) {
    List<cv.VecPoint> contoursList = List<cv.VecPoint>.from(contours);

    contoursList.sort((a, b) {
      double areaA = cv.contourArea(a);
      double areaB = cv.contourArea(b);
      return areaB.compareTo(areaA); // Sorting in descending order
    });

    return contoursList;
  }
}

// Convert contours to a serializable format
List<List<Map<String, double>>> serializeContours(
    List<cv.VecPoint> contours, int width, int heigth) {
  return contours.map((contour) {
    return contour.map((point) {
      return {
        "x": point.x.toDouble() / width,
        "y": point.y.toDouble() / heigth
      };
    }).toList();
  }).toList();
}
