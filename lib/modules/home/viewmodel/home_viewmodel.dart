import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app_api/common/api_provider.dart';
import 'package:store_app_api/common/app_prefs.dart';
import 'package:store_app_api/modules/auth/service/auth_service.dart';
import 'package:store_app_api/modules/auth/models/user_model.dart';
import 'package:store_app_api/modules/home/model/product_model.dart';
import 'package:store_app_api/modules/home/service/home_service.dart';

class HomeViewmodel extends GetxController {
  final products = <ProductModel>[].obs;
  final user = Rxn<UserModel>();

  /// Full-screen first load spinner; pull-to-refresh can reuse [_loadParallel].
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = AppPrefs.getUser();
    _loadParallel(showFullScreenLoading: true);
  }

  Future<void> pullToRefresh() => _loadParallel(showFullScreenLoading: false);

  Future<void> _loadParallel({required bool showFullScreenLoading}) async {
    if (showFullScreenLoading) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true;
    }

    final token = AppPrefs.getAccessToken();

    Future<ApiResponse> profileFut;
    if (token.isEmpty) {
      profileFut = Future.value(
        ApiResponse(
          isSuccess: false,
          statusCode: 401,
          data: null,
          rawBody: '',
          message: 'Missing access token',
        ),
      );
    } else {
      profileFut = AuthService.fetchProfile(accessToken: token);
    }

    final productsFut = HomeService.fetchProducts();

    try {
      final results = await Future.wait([profileFut, productsFut]);
      final profileRes = results[0];
      final productsRes = results[1];

      if (profileRes.isSuccess) {
        final u = AuthService.userFromProfileData(profileRes.data);
        if (u != null) {
          await AppPrefs.setUser(u);
          user.value = u;
        }
      } else if (profileRes.statusCode != 401) {
        log('Profile load: ${profileRes.message}');
      }

      if (productsRes.isSuccess && productsRes.data is List) {
        products.assignAll(HomeService.parseProducts(productsRes.data));
      } else {
        if (Get.context != null) {
          Get.snackbar(
            'Products',
            productsRes.message,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    } catch (e, st) {
      log('Home load error', error: e, stackTrace: st);
      Get.snackbar(
        'Home',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
}
