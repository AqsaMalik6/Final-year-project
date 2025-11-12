import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:measuremate/Screens/Signup/components/signup_form.dart';
import 'package:measuremate/Screens/UserDetails/userDetailScreen.dart';
import '../../../constants.dart';
import 'package:measuremate/Screens/Sizes/denimjeans_size.dart';
import 'package:measuremate/Screens/Sizes/sweatshirt_size.dart';
import 'package:measuremate/Screens/Login/login_screen.dart';

class SelectionPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const SelectionPage({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  Map<String, Map<String, dynamic>> sweatshirtSizes = {};
  Map<String, Map<String, dynamic>> denimJeansSizes = {};
  Future<void> fetchImages() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Reference to user's document
          .collection('images') // Reference to images subcollection
          .get(); // Get all images
// if(snapshot.docs.isNotEmpty){
      snapshot.docs.forEach((doc) {
        final category = doc['currentCategory'];
        final selectedSize = doc['selectedSize'];
        final imageData = {
          'size': doc['actualSize'], // Actual size details
          'image': doc['imagepath'], // Image URL
        };

        // Categorize based on currentCategory
        if (category == 'Sweatshirt') {
          sweatshirtSizes[selectedSize] = imageData; // Add to sweatshirt map
        } else if (category == 'Denim') {
          denimJeansSizes[selectedSize] = imageData; // Add to denim map
        }
      });
// }
      // Loop through the documents and categorize images

      setState(() {
        // Refresh the UI with the categorized data
      });
    }
  }

  // Future<void> fetchImages() async {
  //   final user = FirebaseAuth.instance.currentUser;

  //   if (user != null) {
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid) // Reference to user's document
  //         .collection('images') // Reference to images subcollection
  //         .get(); // Get all images

  //     // Separate images into categories
  //     List<Map<String, dynamic>> sweatshirtList = [];
  //     List<Map<String, dynamic>> denimList = [];

  //     snapshot.docs.forEach((doc) {
  //       final category = doc['currentCategory'];
  //       final imageData = {
  //         'username': doc['username'],
  //         'email': doc['email'],
  //         'selectedSize': doc['selectedSize'],
  //         'actualSize': doc['actualSize'],
  //         'currentCategory': category,
  //         'imagepath': doc['imagepath'],
  //       };

  //       if (category == 'Sweatshirt') {
  //         sweatshirtList.add(imageData); // Add to sweatshirt list
  //       } else if (category == 'Denim') {
  //         denimList.add(imageData); // Add to denim list
  //       }
  //     });

  //     setState(() {
  //       sweatshirtSizes = sweatshirtList; // Update sweatshirt list
  //       denimJeansSizes = denimList; // Update denim list
  //     });
  //   }
  // }
  @override
  void initState() {
    // TODO: implement initState
    getDataFromFirestore();
    super.initState();
  }

  Future<void> getDataFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Reference to the user's collection
      final userImagesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('images');

      QuerySnapshot snapshot = await userImagesRef.get();

      if (snapshot.docs.isNotEmpty) {
        // Temporary maps for updating
        Map<String, Map<String, dynamic>> tempSweatshirtSizes = {};
        Map<String, Map<String, dynamic>> tempDenimJeansSizes = {};

        for (var doc in snapshot.docs) {
          // Extract data
          var data = doc.data() as Map<String, dynamic>;
          String category = data['currentCategory'];
          String selectedSize = data['selectedSize'];
          Map<String, dynamic> actualSize = data['actualSize'];
          String imagePath = data['imagepath'];

          // Create size data
          Map<String, dynamic> sizeData = {
            'size': actualSize, // Use the map from actualSize
            'image': imagePath,
          };

          // Add to appropriate category
          if (category == 'Sweatshirt Sizes') {
            tempSweatshirtSizes[selectedSize] = sizeData;
          } else if (category == 'Denim Jeans Sizes') {
            tempDenimJeansSizes[selectedSize] = sizeData;
          }
        }

        // Update the state
        setState(() {
          sweatshirtSizes = tempSweatshirtSizes;
          denimJeansSizes = tempDenimJeansSizes;
        });
      } else {
        print('No data found!');
      }
    } else {
      print('No user is signed in!');
    }
  }

  @override
  Widget build(BuildContext context) {
//     loadimage()async{
//       User user = FirebaseAuth.instance.currentUser!;
//             final docRef = FirebaseFirestore.instance.collection('users').doc(user).collection('images').doc();

//       DocumentSnapshot snapshot = await docRef.get();
// Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

//     }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text(
          "MEASUREMATE",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
              // fontFamily: 'CeraPro',
            color: Colors.black,
            letterSpacing: 3.5
          ),
        ),
        centerTitle: true,
        // backgroundColor: kPrimaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kPrimaryLightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                widget.userName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  getDataFromFirestore();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(
                        userName: widget.userName,
                        email: widget.userEmail,
                        sweatshirtSizes: sweatshirtSizes,
                        denimJeansSizes: denimJeansSizes,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.userName.isNotEmpty ? widget.userName[0] : 'U',
                    style: const TextStyle(fontSize: 40, color: kPrimaryColor,
                        // fontFamily: 'CeraPro'
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(fontSize: 16,
                    // fontFamily: 'CeraPro'
                ),
              ),
              onTap: () {
                logout(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryLightColor, kPrimaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOptionCard(
                      context,
                      "Sweatshirt Size",
                      const SweatshirtSize(),
                      'assets/images/sweatshirt-icon.png',
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      "Denim Jeans Size",
                      const DenimJeansSize(),
                      'assets/images/jeans-icon.png',
                    ),
                  ],
                ),
                const Spacer(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildOptionCard(
      BuildContext context,
      String text,
      Widget page,
      String imagePath,
      ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      shadowColor: kPrimaryColor.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 200, // Increase height for a larger card
          width: double.infinity, // Card stretches to fit parent width
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // fontFamily: 'CeraPro',
                    letterSpacing: 1.0,
                    color: Colors.black87,
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

void logout(BuildContext context) async {
  try {
    // Sign out the user from Firebase Authentication
    await FirebaseAuth.instance.signOut();

    // After sign-out, navigate to the Login screen or Home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(), // or navigate to any other screen
      ),
    );

    // Optionally, show a confirmation message
    showToast(message: 'You have been logged out successfully',);
  } catch (e) {
    // Handle errors (if any)
    showToast(message: 'Error logging out: $e');
  }
}
