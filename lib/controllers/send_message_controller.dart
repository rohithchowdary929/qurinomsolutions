import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_s_task/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

import 'message_controller.dart';


class SendMessageController extends GetxController {
  final ApiService service = ApiService();

  var isSending = false.obs;
  File? selectedImage;

  /// Pick single image
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      selectedImage = File(picked.path);
      update();
    }
  }

  /// Clear image after sending
  void clearImage() {
    selectedImage = null;
    update();
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    if (content.isEmpty && selectedImage == null) {
      Get.snackbar("Error", "Message cannot be empty");
      return;
    }

    isSending(true);

    final response = await service.sendMessage(
      chatId: chatId,
      senderId: senderId,
      content: content,
      messageType: selectedImage != null ? "image" : "text",
      imageFile: selectedImage,
    );

    isSending(false);

    if (response["statusCode"] == 201) {

      try {
        Get.find<MessageController>().init(chatId);
      } catch (e) {
        print("MessagesController not found: $e");
      }

      // Get.snackbar("Success", "Message Sent",
      //     backgroundColor: Colors.green, colorText: Colors.white);
      clearImage();
    } else {
      Get.snackbar("Failed", response["message"] ?? "Something went wrong",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
