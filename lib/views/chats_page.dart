import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'messages_screen.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  final controller = Get.put(ChatController());
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        controller.loadMore();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: Colors.blue,
      ),

      body: Obx(() {
        if (controller.isLoading.value && controller.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: controller.chats.length +
              (controller.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.chats.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final chat = controller.chats[index];

            return ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.grey.shade700),
              ),
              title: Text(
                chat.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                formatTime(chat.time),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              onTap: () {
                Get.to(() => ChatScreen(chatId: chat.id, chatName: chat.name, avatarUrl: chat.profile) );

              },
            );
          },
        );
      }),
    );
  }

  /// Convert ISO timestamp → 12:45 PM
  String formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }
}
