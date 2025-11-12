import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:measuremate/Screens/results/store_details.dart';
import 'package:measuremate/components/firebase_storage.dart';
import 'package:measuremate/components/save_to';
import '../../constants.dart';

class SweatshirtMeasurementResult extends StatefulWidget {
  final Map<String, double?> actualSize;
  final Map<String, double?> selectedMeasurements;
  final String selectedSize;
  final String capturedImagePath;

  SweatshirtMeasurementResult({
    super.key,
    required this.actualSize,
    required this.selectedSize,
    required this.capturedImagePath,
    required this.selectedMeasurements
  });

  @override
  _SweatshirtMeasurementResultState createState() =>
      _SweatshirtMeasurementResultState();
}

class _SweatshirtMeasurementResultState
    extends State<SweatshirtMeasurementResult> {
  bool isInches = true;
  final double measuredSize = 29.0;

  // Conversion functions for inches and cm
  double inchesToCm(double inches) => inches * 2.54;
  double cmToInches(double cm) => cm / 2.54;

//   // Function to upload image to Firebase Storage
//   Future<String> uploadImage(File imageFile) async {
//     try {
//       // Create a reference to the storage location
//       Reference storageReference = FirebaseStorage.instance.ref().child('user_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

//       // Upload the image file
//       UploadTask uploadTask = storageReference.putFile(imageFile);

//       // Wait for the upload to complete and get the download URL
//       TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
//       String downloadURL = await taskSnapshot.ref.getDownloadURL();

//       return downloadURL;
//     } catch (e) {
//       throw Exception('Error uploading image: $e');
//     }
//   }

//   // Function to store data in Firestore
//  storeMeasurementData(String imageUrl, String username, String email, double actualSize, String selectedSize) async {
//     try {
//       // Get the current user
//       User? user = FirebaseAuth.instance.currentUser;

//       if (user != null) {
//         // Store the data in Firestore under the 'users' collection
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'username': username,
//           'email': email,
//           'selectedSize': selectedSize,
//           'actualSize': actualSize,
//           'imageUrl': imageUrl,  // Store the image URL here
//           'createdAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true)); // Merge data if user already exists

//         print("User data saved successfully.");
//       } else {
//         print("No user is logged in.");
//       }
//     } catch (e) {
//       print("Error storing data: $e");
//     }
//   }

  @override
  Widget build(BuildContext context) {
    final double difference = 0;
    // (measuredSize - widget.actualSize).abs();
    final double accuracy = 0;
    // 100 - (difference / widget.actualSize * 100);
    //uncomment this
    User user = FirebaseAuth.instance.currentUser!;
    //
    // final List<Map<String, dynamic>> measurements = widget.actualSize.entries.map((entry) {
    //   final name = entry.key;
    //   final value = entry.value ?? 0.0;
    //   return {
    //     'name': name,
    //     'measurementInches': cmToInches(value),
    //     'measurementCm': value,
    //   };
    // }).toList();
    final List<Map<String, dynamic>> comparisonList = widget.actualSize.entries.map((entry) {
      final name = entry.key;
      final measuredCm = entry.value ?? 0.0;
      final selectedCm = widget.selectedMeasurements[name] ?? 0.0;

      final diff = (measuredCm - selectedCm).abs();
      final accuracy = selectedCm == 0 ? 0 : (100 - (diff / selectedCm) * 100).clamp(0, 100);

      return {
        'name': name,
        'selectedCm': selectedCm,
        'selectedInches': cmToInches(selectedCm),
        'measuredCm': measuredCm,
        'measuredInches': cmToInches(measuredCm),
        'differenceCm': diff,
        'differenceInches': cmToInches(diff),
        'accuracy': accuracy,
      };
    }).toList();



    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Results for Size ${widget.selectedSize}",
            style: TextStyle(color: Colors.white),
          ),
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
                    // Image.file(
                    //   File(widget.capturedImagePath),
                    //   height: 300,
                    //   fit: BoxFit.contain,
                    // ),
                    Image.file(
                      File(widget.capturedImagePath),
                      key: UniqueKey(),
                      height: 300,
                      fit: BoxFit.contain,
                    ),

                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ToggleButtons(
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Card(
                //   margin: const EdgeInsets.symmetric(vertical: 10.0),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10.0),
                //   ),
                //   elevation: 2,
                //   child: Padding(
                //     padding: const EdgeInsets.all(defaultPadding),
                //     child: Column(
                //       children: [
                //         // Table Header
                //          Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             const Text("Name",
                //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                //             Text(
                //               isInches ? "Inches" : "Centimeters",
                //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //             ),
                //           ],
                //         ),
                //
                //         const Divider(),
                //         ...measurements.map((entry) {
                //           return Padding(
                //             padding: const EdgeInsets.symmetric(vertical: 8.0),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 Text(entry['name'], style: const TextStyle(fontSize: 16)),
                //                 Text(
                //                   isInches
                //                       ? entry['measurementInches'].toStringAsFixed(2)
                //                       : entry['measurementCm'].toStringAsFixed(2),
                //                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //                 ),
                //               ],
                //             ),
                //           );
                //         }).toList(),
                //       ],
                //     ),
                //   ),
                // ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sweatshirt Size Comparison",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     const Text("Measurement", style: TextStyle(fontWeight: FontWeight.bold)),
                        //     Text("Selected (${isInches ? 'in' : 'cm'})",
                        //         style: const TextStyle(fontWeight: FontWeight.bold)),
                        //     Text("Measured (${isInches ? 'in' : 'cm'})",
                        //         style: const TextStyle(fontWeight: FontWeight.bold)),
                        //   ],
                        // ),
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
                        // const Divider(),

                        // Render rows
                        // ...widget.selectedMeasurements.entries.map((entry) {
                        //   final name = entry.key;
                        //   final selectedValue = entry.value ?? 0.0;
                        //   final measuredValue = widget.actualSize[name] ?? 0.0;
                        //
                        //   return Padding(
                        //     padding: const EdgeInsets.symmetric(vertical: 10.0),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Expanded(
                        //           flex: 2,
                        //           child: Text(
                        //             name,
                        //             style: const TextStyle(fontSize: 16),
                        //           ),
                        //         ),
                        //
                        //         // Selected value
                        //         Expanded(
                        //           flex: 1,
                        //           child: Text(
                        //             isInches
                        //                 ? cmToInches(selectedValue).toStringAsFixed(2)
                        //                 : selectedValue.toStringAsFixed(2),
                        //             style: const TextStyle(fontSize: 16),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ),
                        //
                        //         // Add space between selected and measured
                        //         const SizedBox(width: 20),
                        //
                        //         // Measured value
                        //         Expanded(
                        //           flex: 1,
                        //           child: Text(
                        //             isInches
                        //                 ? cmToInches(measuredValue).toStringAsFixed(2)
                        //                 : measuredValue.toStringAsFixed(2),
                        //             style: const TextStyle(fontSize: 16),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   );
                        // }).toList(),
                        ...widget.selectedMeasurements.entries.map((entry) {
                          final name = entry.key;
                          final selectedValue = entry.value ?? 0.0;
                          final measuredValue = widget.actualSize[name] ?? 0.0;
                          final difference = (measuredValue - selectedValue).abs();

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    isInches
                                        ? cmToInches(selectedValue).toStringAsFixed(2)
                                        : selectedValue.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    isInches
                          ? cmToInches(measuredValue).toStringAsFixed(2)
                              : measuredValue.toStringAsFixed(2),
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


                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            // Upload image
                            File imageFile = File(widget.capturedImagePath);
                            // String imageUrl = await uploadImage(imageFile);
                            saveImageToGallery(imageFile.path);

                            // Store data in Firestore
                            //uncomment this
                            await storeMeasurementData(
                                imageFile.path,
                                user.uid,
                                user.email!,
                                widget.actualSize,
                                widget.selectedSize,
                                'Sweatshirt Sizes');

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
                    ],
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

Future<void> getCurrentUserData() async {
  try {
    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      // Fetch the user data from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Retrieve data from the document
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        String username = userData['username'] ?? "No username";
        String email = userData['email'] ?? "No email";
        String selectedSize = userData['selectedSize'] ?? "No selected size";
        String imageUrl = userData['imageUrl'] ?? "No image URL";

        // Output the retrieved data
        print("Username: $username");
        print("Email: $email");
        print("Selected Size: $selectedSize");
        print("Image URL: $imageUrl");
      } else {
        print("User document not found.");
      }
    } else {
      print("No user is logged in.");
    }
  } catch (e) {
    print("Error fetching user data: $e");
  }
}
