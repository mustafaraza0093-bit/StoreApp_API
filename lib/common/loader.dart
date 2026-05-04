import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLoader {
  static void show(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 100),
        child: Container(
          height: 100,
          color: Colors.transparent,
          child: Center(child: CircularProgressIndicator(color: Colors.blue)),
        ),
      ),
    );
  }

  static void hide() {
    Get.back();
  }
}
