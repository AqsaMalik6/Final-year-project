import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:measuremate/Screens/camera_screens/camera_page.dart';
import '../../constants.dart';
import 'package:measuremate/Screens/camera_screens/SweatshirtCameraScreen.dart';

class SweatshirtSize extends StatefulWidget {
  const SweatshirtSize({super.key});

  @override
  _SweatshirtSizeState createState() => _SweatshirtSizeState();
}

class _SweatshirtSizeState extends State<SweatshirtSize> {
  List<Map<String, dynamic>> sweatshirtSizes = [
    {
      'size': 'EXTRA SMALL',
      'measurements': {
        'Chest': 86,
        'Sweatshirt Length': 64,
        'Sleeve Length': 55,
        'Shoulder Width': 38
      }
    },
    {
      'size': 'SMALL',
      'measurements': {
        'Chest': 92,
        'Sweatshirt Length': 66,
        'Sleeve Length': 57,
        'Shoulder Width': 40
      }
    },
    {
      'size': 'MEDIUM',
      'measurements': {
        'Chest': 100,
        'Sweatshirt Length': 68,
        'Sleeve Length': 59,
        'Shoulder Width': 42
      }
    },
    {
      'size': 'LARGE',
      'measurements': {
        'Chest': 108,
        'Sweatshirt Length': 70,
        'Sleeve Length': 61,
        'Shoulder Width': 44
      }
    },
    {
      'size': 'EXTRA LARGE',
      'measurements': {
        'Chest': 116,
        'Sweatshirt Length': 72,
        'Sleeve Length': 63,
        'Shoulder Width': 46
      }
    },
    {
      'size': 'DOUBLE XL',
      'measurements': {
        'Chest': 124,
        'Sweatshirt Length': 74,
        'Sleeve Length': 65,
        'Shoulder Width': 48
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "SWEATSHIRT SIZE",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'CeraPro',
                letterSpacing: 3.5),
          ),
          backgroundColor: kPrimaryColor,
        ),
        body: sweatshirtSizes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: sweatshirtSizes.length,
                          itemBuilder: (context, index) {
                            var sizeData = sweatshirtSizes[index];
                            String size = sizeData['size'];
                            Map<String, dynamic> measurements =
                                sizeData['measurements'];
                            return GestureDetector(
                              onTap: () {
                                _showInputDialog(context, size, measurements);
                              },
                              child: Card(
                                color: kPrimaryLightColor,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    size,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      // fontFamily: 'CeraPro',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _showInputDialog(
      BuildContext context, String size, Map<String, dynamic> measurements) {
    Map<String, TextEditingController> controllers = {
      for (var key in measurements.keys) key: TextEditingController()
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Measurements for $size",
              style: const TextStyle(fontSize: 20)),
              // style: TextStyle(fontFamily: 'CeraPro')),
            content: SingleChildScrollView(
            child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,  // Optional: make it a bit narrower
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: measurements.keys.map((point) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: controllers[point],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+(\.\d{0,2})?$')),
                  ],
                  decoration: InputDecoration(
                    labelText: "$point : ",
                    hintText: "Enter $point in cm",
                  ),
                ),
              );
            }).toList(),
          ))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                    // fontFamily: 'CeraPro',
                    fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Map<String, double?> actualSizes = {
                  for (var key in controllers.keys)
                    key: double.tryParse(controllers[key]!.text)
                };

                if (actualSizes.values.any((size) => size == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                      "Please enter valid measurements.",
                      // style: TextStyle(fontFamily: 'CeraPro'),
                    )),
                  );
                  return;
                }

                final cameras = await availableCameras();

                double? chestMeasurement = actualSizes['Chest'];

                if (chestMeasurement != null) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => CameraPage(
                  //       type: 'sweat',
                  //       actualSize: actualSizes,
                  //       selectedSize: size,
                  //     ),
                  //   ),
                  // );
                  Map<String, double> selectedMeasurements = {
                    for (var entry in actualSizes.entries) entry.key: entry.value!
                  };


                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => CameraPage(
                  //       type: 'sweat',
                  //       actualSize: actualSizes,
                  //       selectedSize: size,
                  //       selectedMeasurements: actualSizes,
                  //     ),
                  //   ),
                  // );
                  final cameras = await availableCameras();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraPage(
                        type: 'sweat',
                        actualSize: selectedMeasurements,
                        selectedSize: size,
                        selectedMeasurements: selectedMeasurements,
                      ),
                    ),
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                      "Chest measurement is required.",
                      // style: TextStyle(fontFamily: 'CeraPro'),
                    )),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text(
                "Confirm",
                // style: TextStyle(fontFamily: 'CeraPro'),
              ),
            ),
          ],
        );
      },
    );
  }
}
