// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:uosbustracking/views/main_screen.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({Key? key}) : super(key: key);

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  String uid = '';
  final LatLng sourcePosition = LatLng(34.767163, 72.359864);
  final LatLng destinationPosition = LatLng(34.767414, 72.356718);
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  late GoogleMapController _controller;
  bool _added = false;
  double mapZoom = 14.74;
  bool isVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    // getPolyLine();
    getUid();
    // enableBackgroundMode();
    _requestPermission();
    getCustomeIcon();
    _listenLocation();
    location.changeSettings(interval: 30, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
    super.initState();
  }

  Future<bool> enableBackgroundMode() async {
    bool bgModeEnabled = await location.isBackgroundModeEnabled();
    if (bgModeEnabled) {
      return true;
    } else {
      try {
        await location.enableBackgroundMode();
      } catch (e) {
        debugPrint(e.toString());
      }
      try {
        bgModeEnabled = await location.enableBackgroundMode();
      } catch (e) {
        debugPrint(e.toString());
      }
      print(bgModeEnabled); //True!
      return bgModeEnabled;
    }
  }

  void getCustomeIdcon() {
    markerIcon = BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/bus_marker.png')
        as BitmapDescriptor;
  }

  Future<void> _listenLocation() async {
    location.enableBackgroundMode();
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('drivers').doc(uid).update({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
      });
    });
  }

  Future<void> getLogout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('driver', '');
    _locationSubscription!.pause();
    await Future.delayed(const Duration(seconds: 1));
  }

  void getcontext(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('drivers').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (_added) {
                mymap(snapshot, mapZoom);
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
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
                    // print('current zoom is ${cameraPosition.zoom}');
                  }
                },
                markers: {
                  Marker(
                      position: LatLng(
                        snapshot.data!.docs.singleWhere(
                            (element) => element.id == uid)['latitude'],
                        snapshot.data!.docs.singleWhere(
                            (element) => element.id == uid)['longitude'],
                      ),
                      markerId: MarkerId('id'),
                      icon: markerIcon),
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                      snapshot.data!.docs.singleWhere(
                          (element) => element.id == uid)['latitude'],
                      snapshot.data!.docs.singleWhere(
                          (element) => element.id == uid)['longitude'],
                    ),
                    zoom: mapZoom),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                    _added = true;
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
                  height: isVisible ? 50 : 0.0,
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
                            // Expanded(
                            //   child: InkWell(
                            //     onTap: () {},
                            //     child: ListTile(
                            //       leading: FaIcon(
                            //         FontAwesomeIcons.bus,
                            //         color: Colors.white,
                            //       ),
                            //       title: Text(
                            //         'Find Your Bus',
                            //         style: TextStyle(color: Colors.white),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  getLogout().whenComplete(() {
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

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot, double zoom) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs
                  .singleWhere((element) => element.id == uid)['latitude'],
              snapshot.data!.docs
                  .singleWhere((element) => element.id == uid)['longitude'],
            ),
            zoom: zoom)));
  }

  void getCustomeIcon() async {
    final Uint8List markerIcons =
        await getBytesFromAsset('assets/images/bus_marker.png', 100);
    markerIcon = BitmapDescriptor.fromBytes(markerIcons);
    setState(() {});
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

  Future<void> getUid() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      uid = pref.getString('driver') as String;
    });
  }
}
