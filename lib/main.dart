import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uosbustracking/views/admin_screen.dart';
import 'package:uosbustracking/views/map_student_screen.dart';
import 'package:uosbustracking/views/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uosbustracking/views/map_driver_screen.dart';
import 'package:wakelock/wakelock.dart';

const Color primaryColor = Color(0xFF476D57);
const Color secondaryColor = Color(0xFF762723);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Wakelock.enable();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String dUid = '';
  String sUid = '';
  String admin = '';
  @override
  void initState() {
    // TODO: implement initState
    getId();
    super.initState();
  }

  Future<void> getId() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getString('driver') != null) {
      setState(() {
        dUid = pref.getString('driver') as String;
      });
    }
    if (pref.getString('admin') != null) {
      setState(() {
        admin = pref.getString('admin') as String;
        // print('the student uid is $sUid');
      });
    }
    if (pref.getString('student') != null) {
      setState(() {
        sUid = pref.getString('student') as String;
        // print('the student uid is $sUid');
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'buses',
        theme: ThemeData(
          // brightness: Brightness.dark,
          primarySwatch: const MaterialColor(
            0xFF762723,
            <int, Color>{
              50: Color(0xFF162A49),
              100: Color(0xFF162A49),
              200: Color(0xFF162A49),
              300: Color(0xFF162A49),
              400: Color(0xFF162A49),
              500: Color(0xFF162A49),
              600: Color(0xFF162A49),
              700: Color(0xFF162A49),
              800: Color(0xFF162A49),
              900: Color(0xFF162A49),
            },
          ),
          inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color.fromARGB(255, 95, 89, 69),
              disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xff141920))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xff444444)))),
        ),
        home: getUserScreen());
  }

  Widget getUserScreen() {
    if (dUid.isEmpty && sUid.isEmpty && admin.isEmpty) {
      return const LoginScreen();
    } else if (dUid.isNotEmpty) {
      return const DriverMapScreen();
    } else if (sUid.isNotEmpty) {
      return const StudentMapScreen();
    } else {
      return const AdminScreen();
    }
  }
}
