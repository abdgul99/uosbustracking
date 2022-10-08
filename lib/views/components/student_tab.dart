import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uosbustracking/views/map_student_screen.dart';

class StudentTab extends StatefulWidget {
  const StudentTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StudentTab> createState() => _StudentTabState();
}

class _StudentTabState extends State<StudentTab> {
  bool userNavigation = false;
  bool loadingState = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            await getUserLogIn().whenComplete(() {
              if (userNavigation == true) {
                Route route = MaterialPageRoute(
                    builder: (context) => const StudentMapScreen());
                Navigator.pushReplacement(context, route);
              }
            });
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            onPrimary: Colors.black,
            maximumSize: const Size(double.infinity, 50),
          ),
          icon: loadingState
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              : const FaIcon(FontAwesomeIcons.google),
          label: const Text('Sing In with Google'),
        ),
      ],
    );
  }

  Future<void> getUserLogIn() async {
    setState(() {
      loadingState = true;
    });
    try {
      // final CollectionReference collectionReference = FirebaseFirestore.instance.doc(documentPath)
      final pref = await SharedPreferences.getInstance();

      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        pref.setString('student', 'student');
        setState(() {
          userNavigation = true;
        });
        // print(user!.uid);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      loadingState = false;
    });
  }

  void getNavigation(BuildContext context) {
    Route route =
        MaterialPageRoute(builder: (context) => const StudentMapScreen());
    Navigator.pushReplacement(context, route);
  }
}
