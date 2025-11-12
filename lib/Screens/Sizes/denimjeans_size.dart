import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:measuremate/Screens/camera_screens/camera_page.dart';
import '../../constants.dart';
import 'package:measuremate/Screens/camera_screens/DenimJeanCameraScreen.dart';

class DenimJeansSize extends StatelessWidget {
  const DenimJeansSize({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> jeansSizes = ['28', '30', '32', '34', '36', '38', '40'];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "DENIM JEANS SIZE",
            style: TextStyle(
                color: Colors.white,
                // fontFamily: 'CeraPro',
                letterSpacing: 3.5,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: kPrimaryColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: jeansSizes.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: kPrimaryLightColor,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        jeansSizes[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        _showInputDialog(context, jeansSizes[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context, String selectedSize) {
    final TextEditingController waistController = TextEditingController();
    final TextEditingController frontRiseController = TextEditingController();
    final TextEditingController hipController = TextEditingController();
    final TextEditingController thighController = TextEditingController();

    final Map<String, double> measurements = {
      "waist": 30.0,
      "outseam": 25.0,
      "length": 40.0,
      // "thigh": 24.0,
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Enter measurements \nfor size $selectedSize",
            style: const TextStyle(fontSize: 20),
            // style: TextStyle(fontFamily: 'CeraPro'),
          ),
          content: SingleChildScrollView(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: waistController,
                          // style: TextStyle(fontFamily: 'CeraPro'),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "Waist ",
                            hintText: "Enter waist in cm",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          // style: TextStyle(fontFamily: 'CeraPro'),
                          controller: frontRiseController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "inseam ",
                            hintText: "Enter front rise in cm",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          // style: TextStyle(fontFamily: 'CeraPro'),
                          controller: hipController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "length ",
                            hintText: "Enter length in cm",
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 16.0),
                      //   child: TextField(
                      //     style: TextStyle(fontFamily: 'CeraPro'),
                      //     controller: thighController,
                      //     keyboardType: TextInputType.numberWithOptions(decimal: true),
                      //     decoration: InputDecoration(
                      //       labelText: "Thigh (Ideal: ${measurements['thigh']} cm)",
                      //       hintText: "Enter thigh in cm",
                      //     ),
                      //   ),
                      // ),
                    ],
                  ))),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                    final waist = double.tryParse(waistController.text);
                    final inseam = double.tryParse(frontRiseController.text);
                    final length = double.tryParse(hipController.text);
                    // final thigh = double.tryParse(thighController.text);

                    if (waist != null && inseam != null && length != null
                        // thigh != null
                        ) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Measurements confirmed!',
                            // style: TextStyle(fontFamily: 'CeraPro'),
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      final measurements = {
                        "waist": waist,
                        "inseam": inseam,
                        "length": length,
                        // "thigh": thigh,
                      };
                      final cameras = await availableCameras();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraPage(
                            type: 'jeans',
                            actualSize: measurements,
                            selectedSize: selectedSize,
                            selectedMeasurements: measurements,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter valid measurements!',
                            // style: TextStyle(fontFamily: 'CeraPro'),
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
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
            ),
          ],
        );
      },
    );
  }
}
