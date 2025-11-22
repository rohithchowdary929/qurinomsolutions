import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';


class VendorLoginScreen extends StatelessWidget {
  VendorLoginScreen({super.key});

  final LoginController controller = Get.put(LoginController());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Error messages
  final emailError = "".obs;
  final passError = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade700,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 25),
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Center(
                    child: Text(
                      "Vendor Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // EMAIL FIELD
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      emailError.value =
                          controller.validateEmail(value) ?? "";
                    },
                  ),
                  Obx(() => emailError.value.isEmpty
                      ? SizedBox()
                      : Padding(
                    padding: const EdgeInsets.only(top: 6, left: 8),
                    child: Text(
                      emailError.value,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  )),

                  SizedBox(height: 20),

                  // PASSWORD FIELD
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      passError.value =
                          controller.validatePassword(value) ?? "";
                    },
                  ),
                  Obx(() => passError.value.isEmpty
                      ? SizedBox()
                      : Padding(
                    padding: const EdgeInsets.only(top: 6, left: 8),
                    child: Text(
                      passError.value,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  )),

                  SizedBox(height: 30),

                  // LOGIN BUTTON
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                        controller.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 18, color: Colors.white),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
