import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import '../../SelectionScreen/SelectionPage.dart';

void showToast({
  required String message,
  ToastGravity position = ToastGravity.BOTTOM,
  Toast length = Toast.LENGTH_SHORT,
  Color backgroundColor = const Color.fromARGB(255, 54, 160, 160),
  Color textColor = Colors.white,
  double fontSize = 16.0,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: length,
    gravity: position,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: fontSize,
  );
}

class SignUpForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  SignUpForm({
    Key? key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for FormState
  bool _loading = false;

  // SignUp logic
  Future<void> signUp() async {
    // Validate the form
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _loading = true;
      });

      try {
        // Create a new user with email and password
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.emailController.text,
          password: widget.passwordController.text,
        );

        // Get the Firebase User
        User? user = userCredential.user;
         userCredential.user?.updateDisplayName(widget.usernameController.text.trim().toString()) ;
        if (user != null) {
          // Save user information to Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'username': widget.usernameController.text,
            'email': widget.emailController.text,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Redirect to SelectionPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SelectionPage(
                userName: widget.usernameController.text,
                userEmail: widget.emailController.text,
              ),
            ),
          );
        }
      } 
      on FirebaseAuthException catch (e) {
        // Show an error message if sign-up fails
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        }
        showToast(message: errorMessage); // Show the error message
      } catch (e) {
        showToast(message: '$e');
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Associate the form with the key
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 5),
      child:
      TextFormField(
            scrollPadding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 4),
            controller: widget.usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Username",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username cannot be empty';
              }
              return null;
            },
          ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 5),
          child:
          TextFormField(
            scrollPadding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 4),
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.email),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              String pattern = r'^[^@]+@[^@]+\.[^@]+$';
              RegExp regex = RegExp(pattern);
              if (!regex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              controller: widget.passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                } else if (value.length < 6) {
                  return 'Password should be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          // Sign-Up Button
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: signUp,
                  child: Text("Sign Up".toUpperCase()),
                ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {


              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
