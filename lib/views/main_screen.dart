import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:uosbustracking/main.dart';
import 'package:uosbustracking/views/components/driver_tab.dart';
import 'package:uosbustracking/views/components/student_tab.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 95, 89, 69),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Image.asset(
              'assets/images/uni1.jpeg',
              height: 270,
              fit: BoxFit.fill,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Card(
                      elevation: 20.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: primaryColor,
                      child: AnimatedContainer(
                        height: MediaQuery.of(context).viewInsets.bottom != 0.0
                            ? 650
                            : 450,
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            TabBar(
                                unselectedLabelStyle: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                                unselectedLabelColor: secondaryColor,
                                indicator: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(8)),
                                tabs: const [
                                  Tab(
                                    text: 'Student',
                                  ),
                                  Tab(
                                    text: 'Bus Driver',
                                  )
                                ]),
                            const Expanded(
                              child: TabBarView(
                                children: [
                                  StudentTab(),
                                  DriverTab(),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
