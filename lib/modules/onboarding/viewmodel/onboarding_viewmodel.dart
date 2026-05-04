import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app_api/common/app_prefs.dart';
import 'package:store_app_api/modules/auth/view/login_view.dart';


class OnboardingViewModel extends GetxController {
  final PageController pageController = PageController();

  final RxInt currentIndex = 0.obs;

  final List<Map<String, String>> data = [
    {
      "image": "assets/onboarding/onboarding_1.png",
      "title": "All your favorites",
      "desc":
          "Get all your loved foods in one place, you just place the order we do the rest",
    },
    {
      "image": "assets/onboarding/onboarding_2.png",
      "title": "Fast Delivery",
      "desc": "Fast delivery to your home, office and wherever you are",
    },
    {
      "image": "assets/onboarding/onboarding_3.png",
      "title": "Easy Payment",
      "desc": "Pay with cash or online payment safely and easily",
    },
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < data.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _completeOnboarding();
    }
  }

  void skip() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    AppPrefs.setFirstTime(false);
    Get.offAll(() => const LoginView());
  }


  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
