import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnakbar {
  static void success(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  static void error(String title, String message) {
    Get.snackbar(
      title,
      "",
      messageText: Text(
        message,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
