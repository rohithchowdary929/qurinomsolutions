import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:q_s_task/services/api_service.dart';
import '../../models/login_model.dart';
import '../views/chats_page.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  final storage = GetStorage();
  final ApiService _service = ApiService();

  /// VALIDATION
  String? validateEmail(String email) {
    if (email.isEmpty) return "Email cannot be empty";
    if (!GetUtils.isEmail(email)) return "Enter a valid email";
    return null;
  }

  String? validatePassword(String pass) {
    if (pass.isEmpty) return "Password cannot be empty";
    if (pass.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  Future<void> login(String email, String password) async {
    try {
      // Validation
      final emailError = validateEmail(email);
      final passError = validatePassword(password);

      if (emailError != null) {
        Get.snackbar(
          "Invalid Email",
          emailError,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (passError != null) {
        Get.snackbar(
          "Invalid Password",
          passError,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading(true);

      final response = await _service.loginUser(email, password);
      int statusCode = response["statusCode"] ?? 400;

      if (statusCode == 200) {
        final model = LoginModel.fromJson(response);

        // SAVE USER ID
        storage.write("USER_ID", model.id);

        Get.snackbar(
          "Success",
          "Login Successful",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Future.delayed(Duration(milliseconds: 500), () {
          Get.offAll(() => ChatListPage());
        });

      } else {
        String message = response["message"] ?? "Invalid email or password";
        Get.snackbar(
          "Login Failed",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
