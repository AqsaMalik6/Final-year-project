import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

Future<String> uploadImage(File imageFile) async {
  try {
    // Create a reference to the storage location
    Reference storageReference = FirebaseStorage.instance.ref().child('user_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the image file
    UploadTask uploadTask = storageReference.putFile(imageFile);

    // Wait for the upload to complete and get the download URL
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    return downloadURL;
  } catch (e) {
    throw Exception('Error uploading image: $e');
  }
}
