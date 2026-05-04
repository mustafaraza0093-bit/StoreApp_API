import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String title;
  final Function callback;
  final double? height;
  final Color? btnColor;
  final Color? txtColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppButton({
    super.key,
    required this.callback,
    required this.title,
    this.btnColor,
    this.height,
    this.txtColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callback();
      },
      child: Container(
        height: height ?? 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: btnColor ?? const Color(0xFFFF7622),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize ?? 18,
              color: txtColor ?? Colors.white,
              fontWeight: fontWeight ?? FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
