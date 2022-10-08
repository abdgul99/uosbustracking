import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final singUpProvider = ChangeNotifierProvider<SingUpController>((ref) {
  return SingUpController();
});

class SingUpController extends ChangeNotifier {
  bool signUpWidget = false;
  void getSignUpWidget() {
    signUpWidget = !signUpWidget;
    notifyListeners();
  }
}
