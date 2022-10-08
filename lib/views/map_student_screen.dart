// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uosbustracking/views/main_screen.dart';
import 'dart:ui' as ui;
import 'package:geolocator/geolocator.dart';

class StudentMapScreen extends StatefulWidget {
  const StudentMapScreen({Key? key}) : super(key: key);

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor selectedbusmarker = BitmapDescriptor.defaultMarker;
  late GoogleMapController _controller;
  List<String> busesList = [];
  bool isVisible = false;
  double mapZoom = 14.0;
  double userSelectedlat = 0.0;
  double userSelectedlon = 0.0;
  double userCurrentLat = 34.7671316;
  double userCurrentlon = 72.3587472;
  String userSelectedBus = '';
  @override
  void initState() {
    // TODO: implement initState
    getCustomeIcon();
    // getSelectedbusmarker();
    getSelectedbusIcon();
    getLocation();
    super.initState();
  }

  void getLocation() async {
    Position positions = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentLat = positions.latitude;
    userCurrentlon = positions.longitude;
    // print(position!.latitude);
    // print(position!.longitude);
    setState(() {});
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot, double zoom) async {
    if (userSelectedBus != '') {
      await _controller
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == userSelectedBus)['latitude'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == userSelectedBus)['longitude'],
              ),
              zoom: zoom)));
    } else {
      await _controller
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(
                userCurrentLat,
                userCurrentlon,
              ),
              zoom: zoom)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [],
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('drivers').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (userSelectedBus != '') {
                mymap(snapshot, mapZoom);
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (userSelectedBus != '') {
                FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(userSelectedBus)
                    .get()
                    .then(
                  (DocumentSnapshot documentSnapshot) {
                    setState(() {
                      userSelectedlat = documentSnapshot['latitude'];
                      userSelectedlon = documentSnapshot['longitude'];
                    });
                  },
                );
              }

              return GoogleMap(
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                tiltGesturesEnabled: false,
                onCameraMove: (CameraPosition cameraPosition) {
                  if (cameraPosition.zoom != mapZoom) {
                    setState(() {
                      mapZoom = cameraPosition.zoom;
                    });
                    print('current zoom is ${cameraPosition.zoom}');
                  }
                },
                markers: {
                  for (var i in snapshot.data!.docs)
                    Marker(
                        position: LatLng(
                          i['latitude'],
                          i['longitude'],
                        ),
                        infoWindow: InfoWindow(title: 'Bus No ${i['bus#']}'),
                        markerId: MarkerId('id${i['bus#']}'),
                        icon: markerIcon),
                  if (userSelectedBus != '')
                    Marker(
                        position: LatLng(
                          userSelectedlat,
                          userSelectedlon,
                        ),
                        infoWindow:
                            InfoWindow(title: 'Bus No ${userSelectedBus}'),
                        markerId: MarkerId('id${userSelectedBus}'),
                        icon: selectedbusmarker),
                  if (userSelectedBus == '')
                    Marker(
                        position: LatLng(
                          userCurrentLat,
                          userCurrentlon,
                        ),
                        infoWindow: InfoWindow(title: 'You'),
                        markerId: MarkerId('idstudent'),
                        icon: BitmapDescriptor.defaultMarker),
                },
                initialCameraPosition: userSelectedBus == ''
                    ? CameraPosition(
                        target: LatLng(
                          userCurrentLat,
                          userCurrentlon,
                        ),
                        zoom: mapZoom)
                    : CameraPosition(
                        target: LatLng(
                          userSelectedlat,
                          userSelectedlon,
                        ),
                        zoom: mapZoom),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                    // _added = true;
                  });
                },
              );
            },
          ),
          Positioned(
            top: 50,
            child: InkWell(
              onTap: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
              child: Ink(
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(20)),
                    color: Colors.blueAccent,
                  ),
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            child: InkWell(
              onTap: () {},
              child: Ink(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: isVisible ? 160 : 0.0,
                  width: isVisible ? 200 : 0.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        topRight: Radius.circular(10)),
                    color: Colors.blueAccent,
                  ),
                  child: isVisible
                      ? Column(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  // await getBuses();

                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Select Your Bus'),
                                          content: selectYourBus(),
                                        );
                                      });
                                },
                                child: ListTile(
                                  leading: FaIcon(
                                    FontAwesomeIcons.bus,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'Find Your Bus',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    userSelectedBus = '';
                                  });
                                  isVisible = !isVisible;
                                },
                                child: Card(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.person_pin_circle,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        'My Location',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await getLogut().whenComplete(() {
                                    Route route = MaterialPageRoute(
                                        builder: (context) => LoginScreen());
                                    Navigator.pushReplacement(context, route);
                                  });
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'LogOut',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectYourBus() {
    return SizedBox(
      height: 500.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: FutureBuilder(
        future: getBuses(),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasError) {
            return Text('Something Went wrong');
          } else if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      userSelectedBus = busesList[index];
                    });

                    Navigator.pop(context);
                  },
                  child: ListTile(
                    title: Text("Bus NO. ${snapshot.data![index]}"),
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                height: 70,
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ));
          } else {
            return Text('Please try again');
          }
        },
      ),
    );
  }

  Future<List<String>> getBuses() async {
    busesList.clear();
    await FirebaseFirestore.instance
        .collection('drivers')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        busesList.add(doc["bus#"]);
        print(doc["bus#"]);
      });
    });
    // print(busesList);
    return busesList;
  }

  void getCustomeIcon() async {
    final Uint8List markerIcons =
        await getBytesFromAsset('assets/images/bus_marker.png', 100);
    markerIcon = BitmapDescriptor.fromBytes(markerIcons);
    setState(() {});
  }

  void getSelectedbusIcon() async {
    final Uint8List selectedbusmarkers =
        await getBytesFromAsset('assets/images/selectedbus.png', 100);
    selectedbusmarker = BitmapDescriptor.fromBytes(selectedbusmarkers);
    setState(() {});
  }

  void getCustomeIdcon() {
    markerIcon = BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/bus_marker.png')
        as BitmapDescriptor;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> getLogut() async {
    final pref = await SharedPreferences.getInstance();
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    pref.setString('student', '');
  }
}
