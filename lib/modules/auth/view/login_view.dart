import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app_api/common/app_TextField.dart';
import 'package:store_app_api/common/app_button.dart';
import 'package:store_app_api/modules/auth/viewmodel/login_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(LoginViewmodel());

    return Scaffold(
      backgroundColor: Color(0xFF121223),
      body: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.transparent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Welcome back! Please login to your account.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Form(
                    // key: viewModel.formKey,
                    child: Obx(
                      () => Column(
                        children: [
                          // for Email
                          AppTextfield(
                            lableText: "Email",
                            controller: viewModel.email.value,
                            textFieldType: AppTextFieldType.email,
                          ),
                          SizedBox(height: 20),
                          // for password
                          AppTextfield(
                            lableText: "Password",
                            textFieldType: AppTextFieldType.password,
                            controller: viewModel.password.value,
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  viewModel.isRememberMe.value =
                                      !viewModel.isRememberMe.value;
                                },
                                child: Obx(
                                  () => Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: viewModel.isRememberMe.value
                                          ? const Color(0xFFFF7622)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: viewModel.isRememberMe.value
                                            ? const Color(0xFFFF7622)
                                            : Colors.grey,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: viewModel.isRememberMe.value
                                        ? Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Remember me",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: const Color(0xFFFF7622),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          AppButton(
                            title: "Log in",
                            callback: () {
                              viewModel.loginWithEmail();
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?"),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: const Color(0xFFFF7622),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
