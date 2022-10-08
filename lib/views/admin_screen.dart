// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uosbustracking/views/main_screen.dart';

class DriverModel {
  final int id;
  final int password;
  final int busNo;
  final String name;
  final int contact;
  final String from;
  final double lat;
  final double lon;

  DriverModel(this.id, this.password, this.busNo, this.name, this.contact,
      this.from, this.lat, this.lon);
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController pasController = TextEditingController();
  TextEditingController busNoController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  // final Stream<QuerySnapshot> _usersStream =
  //     FirebaseFirestore.instance.collection('drivers').snapshots();

  Future<void> adminLogout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('admin', '');
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Portal'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            await adminLogout().whenComplete(() {
              Route route =
                  MaterialPageRoute(builder: (context) => LoginScreen());
              Navigator.pushReplacement(context, route);
            });
          },
          icon: Icon(Icons.logout),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      scrollable: true,
                      title: AddUserAlertbox(
                          busNoController: busNoController,
                          pasController: pasController,
                          fromController: fromController,
                          contactController: contactController),
                    );
                  });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something Went wrong');
          } else if (snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Text(
                          "Bus# ${snapshot.data!.docs[index].get('bus#')}"),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "From: ${snapshot.data!.docs[index].get('from')}"),
                          Text(
                              "Password: ${snapshot.data!.docs[index].get('password')}"),
                          Text(
                              "Contact: ${snapshot.data!.docs[index].get('contact')}"),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  scrollable: true,
                                  title: UpdateUser(
                                      bus: snapshot.data!.docs[index]
                                          .get('bus#'),
                                      pass: snapshot.data!.docs[index]
                                          .get('password'),
                                      from: snapshot.data!.docs[index]
                                          .get('from'),
                                      contact: snapshot.data!.docs[index]
                                          .get('password')),
                                );
                              });
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ),
                  );
                });
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Text('data');
          }
        },
      ),
    );
  }
}

class AddUserAlertbox extends StatefulWidget {
  const AddUserAlertbox({
    Key? key,
    required this.busNoController,
    required this.pasController,
    required this.fromController,
    required this.contactController,
  }) : super(key: key);

  final TextEditingController busNoController;
  final TextEditingController pasController;
  final TextEditingController fromController;
  final TextEditingController contactController;

  @override
  State<AddUserAlertbox> createState() => _AddUserAlertboxState();
}

class _AddUserAlertboxState extends State<AddUserAlertbox> {
  String userAddValidation = '';
  bool pop = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Add Driver'),
        SizedBox(height: 10),
        Text(
          userAddValidation,
          style: TextStyle(color: Colors.red),
        ),
        SizedBox(height: 10),
        TextFieldAddDriver(
          enable: true,
          controller: widget.busNoController,
          label: 'Bus#',
        ),
        SizedBox(height: 10),
        TextFieldAddDriver(
          enable: true,
          controller: widget.pasController,
          label: 'Password',
        ),
        SizedBox(height: 10),
        SizedBox(height: 10),
        TextFieldAddDriver(
          enable: true,
          controller: widget.fromController,
          label: 'From',
        ),
        SizedBox(height: 10),
        TextFieldAddDriver(
          enable: true,
          controller: widget.contactController,
          label: 'Contact',
        ),
        SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel')),
            Spacer(),
            ElevatedButton(
                onPressed: () async {
                  final CollectionReference collectionReference =
                      FirebaseFirestore.instance.collection('drivers');

                  pop = true;
                  setState(() {});
                  try {
                    collectionReference
                        .doc(widget.busNoController.text)
                        .get()
                        .then((DocumentSnapshot documentSnapshot) async {
                      if (documentSnapshot.exists) {
                        setState(() {
                          userAddValidation = 'The bus is already exists';
                        });
                        print('Document exists on the database');
                      } else {
                        await collectionReference
                            .doc(widget.busNoController.text)
                            .set(
                          {
                            'bus#': widget.busNoController.text.trim(),
                            'password': widget.pasController.text.trim(),
                            'from': widget.fromController.text.trim(),
                            'contact': widget.contactController.text.trim(),
                            'latitude': 34.7671312,
                            'longitude': 72.3587479,
                          },
                        );
                        widget.busNoController.clear();
                        widget.pasController.clear();
                        widget.fromController.clear();
                        widget.contactController.clear();
                        Navigator.pop(context);
                      }
                    });
                  } on FirebaseAuthException catch (e) {
                  } catch (e) {
                    print(e);
                  }
                  // await getDriverData(
                  //   busNo: busNoController.text,
                  //   password: pasController.text,
                  //   from: fromController.text,
                  //   contact: contactController.text,
                  // );

                  setState(() {
                    pop = false;
                  });
                },
                child: pop ? CircularProgressIndicator() : Text('Add Driver')),
          ],
        )
      ],
    );
  }
}

class UpdateUser extends StatefulWidget {
  const UpdateUser({
    required this.bus,
    required this.pass,
    required this.from,
    required this.contact,
    Key? key,
  }) : super(key: key);
  final String bus;
  final String pass;
  final String from;
  final String contact;
  @override
  State<UpdateUser> createState() => _UpdateUser();
}

class _UpdateUser extends State<UpdateUser> {
  late TextEditingController busNoController;
  late TextEditingController pasController;
  late TextEditingController fromController;
  late TextEditingController contactController;
  String bus = '';
  String userAddValidation = '';
  bool pop = false;
  @override
  void initState() {
    // TODO: implement initState
    busNoController = TextEditingController(text: widget.bus);
    pasController = TextEditingController(text: widget.pass);
    fromController = TextEditingController(text: widget.from);
    contactController = TextEditingController(text: widget.contact);
    bus = widget.bus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
                onPressed: () async {
                  try {
                    CollectionReference users =
                        FirebaseFirestore.instance.collection('drivers');
                    users.doc(bus).delete();
                    Navigator.pop(context);
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text('Delete Driver')),
            SizedBox(width: 10),
            Text('Update Driver'),
          ],
        ),
        SizedBox(height: 10),
        Text(
          userAddValidation,
          style: TextStyle(color: Colors.red),
        ),
        SizedBox(height: 10),
        TextFieldAddDriver(
          enable: false,
          controller: busNoController,
          label: 'Bus#',
        ),
        SizedBox(height: 10),
        TextFieldAddDriver(
          enable: true,
          controller: pasController,
          label: 'Password',
        ),
        SizedBox(height: 10),
        SizedBox(height: 10),
        TextFieldAddDriver(
          enable: true,
          controller: fromController,
          label: 'From',
        ),
        SizedBox(height: 10),
        TextFieldAddDriver(
          enable: true,
          controller: contactController,
          label: 'Contact',
        ),
        SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel')),
            Spacer(),
            ElevatedButton(
                onPressed: () async {
                  final CollectionReference collectionReference =
                      FirebaseFirestore.instance.collection('drivers');

                  pop = true;

                  try {
                    print(bus);
                    await collectionReference.doc(bus.trim()).update(
                      {
                        'bus#': busNoController.text.trim(),
                        'password': pasController.text.trim(),
                        'from': fromController.text.trim(),
                        'contact': contactController.text.trim(),
                        'latitude': 23.254444,
                        'longitude': 123.5251,
                      },
                    );

                    Navigator.pop(context);
                  } on FirebaseAuthException catch (e) {
                  } catch (e) {
                    print(e);
                  }

                  setState(() {
                    pop = false;
                  });
                },
                child:
                    pop ? CircularProgressIndicator() : Text('Update Driver')),
          ],
        )
      ],
    );
  }
}

class TextFieldAddDriver extends StatelessWidget {
  const TextFieldAddDriver({
    required this.controller,
    required this.label,
    required this.enable,
    Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final String label;
  final bool enable;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                enabled: enable,
                contentPadding: EdgeInsets.only(left: 10),
                label: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
