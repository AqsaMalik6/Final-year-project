import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:measuremate/Screens/results/store_details.dart';
import '../../constants.dart';
import 'package:path_provider/path_provider.dart';

class DenimJeanMeasurementResult extends StatefulWidget {
  final Map<String, double> actualSizes;
  final Map<String, double> selectedMeasurements;
  final String selectedSize;
  final String capturedImagePath;

  DenimJeanMeasurementResult({
    super.key,
    required this.actualSizes,
    required this.selectedSize,
    required this.capturedImagePath,
    required this.selectedMeasurements,
  });

  @override
  _DenimJeanMeasurementResultState createState() =>
      _DenimJeanMeasurementResultState();
}

class _DenimJeanMeasurementResultState
    extends State<DenimJeanMeasurementResult> {
  bool isInches = true;
  String toTitleCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }


  double inchesToCm(double inches) => inches * 2.54;
  double cmToInches(double cm) => cm / 2.54;

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Measurement Results for Size ${widget.selectedSize}"),
          backgroundColor: kPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      File(widget.capturedImagePath),
                      key: UniqueKey(),
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      bottom: 10,
                      child: ToggleButtons(
                        isSelected: [isInches, !isInches],
                        onPressed: (index) {
                          setState(() {
                            isInches = index == 0;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        selectedColor: Colors.white,
                        fillColor: kPrimaryColor,
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text("Inches"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text("Centimeters"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     const Text(
                        //       "Name",
                        //       style: TextStyle(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //     Text(
                        //       isInches ? "Inches" : "Centimeters",
                        //       style: const TextStyle(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 2, child: Text("Measurement", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: Text("Selected (${isInches ? 'in' : 'cm'})", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                            Expanded(flex: 1, child: Text("Measured (${isInches ? 'in' : 'cm'})", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                            Expanded(flex: 1, child: Text("Difference", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                          ],
                        ),
                        const Divider(),
                        // ...widget.actualSizes.entries.map((entry) {
                        //   double value = entry.value;
                        //   return Padding(
                        //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text(
                        //           entry.key,
                        //           style: const TextStyle(fontSize: 16),
                        //         ),
                        //         Text(
                        //           isInches
                        //               ? value.toStringAsFixed(2)
                        //               : inchesToCm(value).toStringAsFixed(2),
                        //           style: const TextStyle(
                        //             fontSize: 16,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   );
                        // }).toList(),
                        ...widget.selectedMeasurements.entries.map((entry) {
                          final name = entry.key;
                          final selected = entry.value;
                          // final measured = widget.actualSizes[name] ?? 0.0;
                          final measured = widget.actualSizes[name] ??
                              widget.actualSizes[toTitleCase(name)] ??
                              0.0;

                          final difference = (measured - selected).abs();

                          print("Comparing $name | selected: $selected | measured: $measured");

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Name
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),

                                // Selected
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    isInches
                                        ? cmToInches(selected).toStringAsFixed(2)
                                        : selected.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Measured
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    isInches
                                      ? cmToInches(difference).toStringAsFixed(2)
                                        : difference.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Difference
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    isInches
                                        ? cmToInches(measured).toStringAsFixed(2)
                                        : measured.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),


                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        File imageFile = File(widget.capturedImagePath);
                        saveImageToGallery(imageFile.path);

                        await storeMeasurementData(
                          imageFile.path,
                          user.uid,
                          user.email!,
                          widget.actualSizes,
                          widget.selectedSize,
                          'Denim Jeans Sizes',
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        print("Error: $e");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Back"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
