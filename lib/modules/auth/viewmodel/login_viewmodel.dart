import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app_api/common/app_prefs.dart';
import 'package:store_app_api/common/loader.dart';
import 'package:store_app_api/modules/auth/service/auth_service.dart';
import 'package:store_app_api/modules/home/view/home_view.dart';

class LoginViewmodel extends GetxController {
  RxBool isRememberMe = false.obs;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<TextEditingController> email = TextEditingController(
    text: "john@mail.com",
  ).obs;
  Rx<TextEditingController> password = TextEditingController(
    text: "changeme",
  ).obs;

  RxBool isOtpSent = false.obs;
  RxString verificationId = ''.obs;

  Future<void> loginWithEmail() async {
    try {
      // if (!(formKey.currentState?.validate() ?? false)) return;

      final ctx = Get.context;
      if (ctx == null || !ctx.mounted) return;

      AppLoader.show(ctx);

      final res = await AuthService.login(
        email: email.value.text.trim(),
        password: password.value.text,
      );

      if (!res.isSuccess) {
        AppLoader.hide();
        Get.snackbar(
          'Login Failed',
          res.message,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final tokens = AuthService.tokensFromLoginData(res.data);
      if (tokens == null) {
        AppLoader.hide();
        Get.snackbar(
          'Login Failed',
          'Invalid response from server.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      await AppPrefs.setAccessToken(tokens.accessToken);
      await AppPrefs.setRefreshToken(tokens.refreshToken);

      final profileRes = await AuthService.fetchProfile(
        accessToken: tokens.accessToken,
      );

      if (!profileRes.isSuccess) {
        AppLoader.hide();
        Get.snackbar(
          'Profile',
          profileRes.message,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final user = AuthService.userFromProfileData(profileRes.data);
      if (user != null) {
        await AppPrefs.setUser(user);
      }

      AppLoader.hide();
      Get.offAll(() => const HomeView());
    } catch (e, st) {
      AppLoader.hide();
      Get.snackbar(
        'Login Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      log('Login error', error: e, stackTrace: st);
    }
  }
}
