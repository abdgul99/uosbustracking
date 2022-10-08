import 'package:flutter/material.dart';

class SingUpScreen extends StatelessWidget {
  const SingUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          height: 50,
          child: TextField(
            decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Bus No.'),
                      TextSpan(
                        text: 'bold',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                contentPadding: EdgeInsets.all(10)),
          ),
        ),
      ],
    );
  }
}
