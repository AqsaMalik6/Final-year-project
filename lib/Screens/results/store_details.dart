import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';


Future<void> saveImageToGallery(String imagePath) async {
  try {
    // Read the image file
    File imageFile = File(imagePath);

    if (imageFile.existsSync()) {
      // Save the image to the gallery
      final result = await ImageGallerySaverPlus.saveFile(imagePath);

      // Check the result and show success message
      if (result != null) {
        Fluttertoast.showToast(
          msg: "Image saved to gallery",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Image not found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (e) {
    // Handle any error that occurs
    Fluttertoast.showToast(
      msg: "Failed to save image: $e",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}


Future<void> storeMeasurementData(String imageUrl, String username, String email, Map<String, double?> actualSize, String selectedSize ,String Cat) async {
  try {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('images').doc();

      // Store the data in Firestore under the 'users' collection
      docRef.set({
  'username': username,
  'email': email,
  'selectedSize': selectedSize,  // Size selected by the user
  'actualSize': actualSize,      // Actual size details
  'createdAt': FieldValue.serverTimestamp(),
  'currentCategory': Cat,
  'imagepath': imageUrl
}, SetOptions(merge: true));
 // Merge data if user already exists

      print("User data saved successfully.");
    } else {
      print("No user is logged in.");
    }
  } catch (e) {
    print("Error storing data: $e");
  }
}
