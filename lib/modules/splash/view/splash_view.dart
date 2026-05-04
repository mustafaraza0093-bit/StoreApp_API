import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app_api/common/app_prefs.dart';
import 'package:store_app_api/modules/auth/view/login_view.dart';
import 'package:store_app_api/modules/home/view/home_view.dart';
import 'package:store_app_api/modules/onboarding/view/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () async {
      String token = AppPrefs.getAccessToken();
      if (AppPrefs.isFirstTime()) {
        Get.offAll(() => OnboardingView());
      } else if (token.isNotEmpty) {
        Get.offAll(() => const HomeView());
      } else {
        Get.offAll(() => const LoginView());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Center(child: Image.asset("assets/appLogo.jpeg", width: 200)),
      ),
    );
  }
}
