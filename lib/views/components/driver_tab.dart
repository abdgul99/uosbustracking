// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uosbustracking/controller/driver_screen_controller.dart';
import 'package:uosbustracking/views/admin_screen.dart';
import 'package:uosbustracking/views/components/driver_singup_screen.dart';
import 'package:uosbustracking/views/map_driver_screen.dart';

class DriverTab extends StatefulWidget {
  const DriverTab({
    Key? key,
  }) : super(key: key);

  @override
  State<DriverTab> createState() => _DriverTabState();
}

class _DriverTabState extends State<DriverTab> {
  final TextEditingController _adminLoginEmail = TextEditingController();
  final TextEditingController _adminLoginPassword = TextEditingController();
  final TextEditingController _sInBusNoContrller = TextEditingController();
  final TextEditingController _sInPasswordContrller = TextEditingController();
  final _formKeySup = GlobalKey<FormState>();
  final _formKeySin = GlobalKey<FormState>();
  bool singUpScreen = false;
  bool loadingState = false;
  String driverLoginValidation = '';
  String adminValidation = '';
  bool driverNavigation = false;
  bool adminNavigation = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            singUpScreen == false
                ? Form(
                    key: _formKeySin,
                    child: Column(
                      children: [
                        Text(
                          'Driver Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          driverLoginValidation,
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _sInBusNoContrller,
                          decoration: InputDecoration(
                              label: Text(
                                'Bus#',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              contentPadding: EdgeInsets.all(10)),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please enter Bus No';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _sInPasswordContrller,
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              label: Text(
                                'Password',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              contentPadding: EdgeInsets.all(10)),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please enter the password';
                            }
                            return null;
                          },
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  if (_formKeySin.currentState!.validate()) {
                                    // TODO submit
                                    await getSingInDriver(
                                            busNo: _sInBusNoContrller.text,
                                            password:
                                                _sInPasswordContrller.text)
                                        .whenComplete(() {
                                      if (driverNavigation == true) {
                                        Route route = MaterialPageRoute(
                                            builder: (context) =>
                                                DriverMapScreen());
                                        Navigator.pushReplacement(
                                            context, route);
                                      }
                                    });
                                  }
                                },
                                child: loadingState
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ))
                                    : Text('Sing In')),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    singUpScreen = !singUpScreen;
                                  });
                                },
                                child: Text(
                                  'Login as a Admin',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                )),
                          ],
                        ),
                      ],
                    ),
                  )
                //?! Admin form
                : Form(
                    key: _formKeySup,
                    child: Column(
                      children: [
                        Text(
                          'Admin Login Portal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),

                        SizedBox(height: 10),
                        //email text field
                        TextFormField(
                          controller: _adminLoginEmail,
                          decoration: InputDecoration(
                              label: Text(
                                'Email',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              contentPadding: EdgeInsets.all(10)),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please enter the Email';
                            } else if (text.contains('@') == false) {
                              return 'Please enter a valid Email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        //Password text field
                        TextFormField(
                          controller: _adminLoginPassword,
                          decoration: InputDecoration(
                              label: Text(
                                'Password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              contentPadding: EdgeInsets.all(10)),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please enter the password';
                            } else if (text.length < 6) {
                              return 'Password must be greater then 6';
                            }
                            return null;
                          },
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  if (_formKeySup.currentState!.validate()) {
                                    // TODO submit
                                    await adminLogin(
                                            email: _adminLoginEmail.text
                                                .toString(),
                                            password: _adminLoginPassword.text)
                                        .whenComplete(() {
                                      if (adminNavigation == true) {
                                        Route route = MaterialPageRoute(
                                            builder: (context) =>
                                                AdminScreen());
                                        Navigator.pushReplacement(
                                            context, route);
                                      }
                                    });
                                    ;
                                  }
                                },
                                child: loadingState
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ))
                                    : Text('Sing In')),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    singUpScreen = !singUpScreen;
                                  });
                                },
                                child: Text(
                                  'Login as a Driver',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                )),
                          ],
                        ),
                        Text(
                          adminValidation,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      );
    });
  }

  Future<void> getSingInDriver(
      {required String busNo, required String password}) async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('drivers');
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      driverLoginValidation = "";
    });
    setState(() {
      loadingState = true;
    });
    try {
      await collectionReference
          .doc(busNo)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        dynamic passwordMatch = documentSnapshot.get(FieldPath(['password']));
        if (password == passwordMatch) {
          await prefs.setString('driver', busNo);
          driverNavigation = true;
        } else {
          setState(() {
            driverLoginValidation =
                "Credentials error please contact with your system administrator";
          });
        }
      });
    } catch (e) {
      print(e);
      setState(() {
        driverLoginValidation =
            "Credentials error please contact with your system administrator OR check your Internet Connection";
      });
    }
    setState(() {
      loadingState = false;
    });
  }

  //?!
  Future<void> adminLogin(
      {required String email, required String password}) async {
    setState(() {
      loadingState = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.toString().trim(), password: password);
      // User? user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin', 'admin');
      adminValidation = '';
      adminNavigation = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print(
            'No user found for that email please contact with your system administrator.');
        adminValidation =
            'No user found for that email please contact with your system administrator.';
        loadingState = false;
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        adminValidation =
            'Wrong password provided for that user please contact with your system administrator.';
      } else if (e.code == 'network-request-failed') {
        adminValidation = 'Please check your internet connection';
      }
      setState(() {
        loadingState = false;
      });
    }
  }
}
