import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum AppTextFieldType { normal, email, password, search }

class AppTextfield extends StatefulWidget {
  final String? hintText;
  final String? lableText;
  final AppTextFieldType textFieldType;
  final TextEditingController? controller;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const AppTextfield({
    super.key,
    this.hintText,
    this.lableText,
    this.textFieldType = AppTextFieldType.normal,
    this.controller,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  State<AppTextfield> createState() => _AppTextfieldState();
}

class _AppTextfieldState extends State<AppTextfield> {
  // local Varables.
  bool isVisiblePassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.lableText != null) ...{
          Text(widget.lableText ?? "", style: TextStyle(fontSize: 14)),
          SizedBox(height: 10),
        },

        TextFormField(
          controller: widget.controller,
          obscureText: widget.textFieldType == AppTextFieldType.password
              ? !isVisiblePassword
              : false,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          inputFormatters:
              widget.inputFormatters ??
              [
                if (widget.textFieldType == AppTextFieldType.email) ...{
                  FilteringTextInputFormatter.deny(RegExp(r"\s")),
                },
              ],
          validator: widget.validator ?? validate,

          decoration: InputDecoration(
            errorMaxLines: 3,
            hintText: widget.hintText ?? 'Enter your ${widget.lableText ?? ""}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            fillColor: Color(0xFFEBF5FF),
            filled: true,

            suffixIcon: widget.textFieldType == AppTextFieldType.password
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isVisiblePassword = !isVisiblePassword;
                      });
                    },
                    icon: Icon(
                      isVisiblePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  )
                : null,
            prefixIcon: widget.textFieldType == AppTextFieldType.search
                ? Icon(Icons.search)
                : null,
          ),
        ),
      ],
    );
  }

  String? validate(String? value) {
    if (widget.textFieldType == AppTextFieldType.email) {
      if (value == null || value.isEmpty) {
        return 'Please enter your email';
      } else if (!GetUtils.isEmail(value)) {
        return 'Please enter a valid email';
      }
    }

    if (widget.textFieldType == AppTextFieldType.password) {
      final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
      ).hasMatch(value ?? '');
      if (value == null || value.isEmpty) {
        return 'Please enter your password';
      } else if (!passwordRegex) {
        return 'Password must include uppercase, lowercase, number, and special character';
      }
    }

    if (widget.textFieldType == AppTextFieldType.normal) {
      if (value == null || value.isEmpty) {
        return 'Please enter your ${widget.lableText ?? "value"}';
      }
    }

    return null;
  }
}
