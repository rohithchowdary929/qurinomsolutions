import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/message_controller.dart';
import '../controllers/send_message_controller.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String? avatarUrl; // optional

  const ChatScreen({super.key, required this.chatId, required this.chatName, this.avatarUrl});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController controller = Get.put(MessageController());
  final ScrollController scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();
  final SendMessageController sendController =
  Get.put(SendMessageController());


  // base host to resolve relative fileUrl
  final String _baseHost = 'https://testmobile-api.storeflaunt.co.in';

  @override
  void initState() {
    super.initState();
    controller.init(widget.chatId);

    // When reversed: list shows bottom newest; detect scroll near top to load older
    scrollController.addListener(() {
      // when at top (pixels <= 0) — since we'll use reverse:true, top becomes maxScrollExtent
      // For safety, check distance to maxScrollExtent (older messages are beyond max)
      if (scrollController.position.atEdge) {
        final isTop = scrollController.position.pixels == scrollController.position.maxScrollExtent;
        if (isTop) {
          // load older messages
          controller.loadOlder();
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 24,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
              child: widget.avatarUrl == null ? Icon(Icons.person, color: Colors.grey.shade700) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chatName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text("last seen recently", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.call_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(child: Obx(() {
            if (controller.isLoading.value && controller.messages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // List is chronological oldest->newest in controller.messages.
            // We use reverse:true and display messages so newest are at the bottom.
            return Stack(
              children: [
                ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  itemCount: controller.messages.length + (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (controller.isLoadingMore.value && index == controller.messages.length) {
                      // loading older indicator (shows at top because list is reversed)
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    // because list is reversed, map index to reversed order
                    final reversedIndex = controller.messages.length - 1 - index;
                    final msg = controller.messages[reversedIndex];
                    final isMe = controller.isMe(msg);
                    return _buildMessageBubble(msg, isMe);
                  },
                ),

                // optional "load older" floating indicator when hasMore
                if (controller.hasMore && !controller.isLoadingMore.value)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => controller.loadOlder(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Load older messages'),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          })),

          // input area (UI only for now)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [

                  /// PICK IMAGE
                  IconButton(
                    onPressed: () {
                      sendController.pickImage();
                    },
                    icon: const Icon(Icons.add),
                  ),

                  /// MESSAGE TEXTFIELD
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: inputController,
                              decoration: const InputDecoration(
                                hintText: "Type a message",
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          /// EMOJI BUTTON
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.emoji_emotions_outlined),
                          ),

                          /// CAMERA → same as pick image
                          IconButton(
                            onPressed: () {
                              sendController.pickImage();
                            },
                            icon: const Icon(Icons.camera_alt_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// SEND BUTTON
                  Obx(() => FloatingActionButton(
                    onPressed: sendController.isSending.value
                        ? null
                        : () {
                      sendController.sendMessage(
                        chatId: widget.chatId,
                        senderId: controller.currentUserId,
                        content: inputController.text.trim(),
                      );

                      inputController.clear();

                      scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    mini: true,
                    backgroundColor: sendController.isSending.value
                        ? Colors.grey
                        : Colors.green,
                    child: sendController.isSending.value
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.white),
                  )),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    final time = _formatTime(msg.createdAt ?? msg.sentAt ?? '');
    final bubbleColor = isMe ? Colors.green.shade100 : Colors.grey.shade100;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(12))
        : const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12));

    Widget content;
    if (msg.messageType == 'file' || (msg.fileUrl != null && msg.fileUrl!.isNotEmpty && (msg.fileUrl!.toLowerCase().endsWith('.jpg') || msg.fileUrl!.toLowerCase().contains('vendor/')))) {
      // image (file)
      final url = _resolveFileUrl(msg.fileUrl);
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url, width: 220, height: 160, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(
          width: 220, height: 160, color: Colors.grey.shade300, child: const Icon(Icons.broken_image),
        )),
      );
    } else if (msg.messageType == 'location' && (msg.fileUrl?.isNotEmpty ?? false)) {
      content = GestureDetector(
        onTap: () {
          // open map link
          if (msg.fileUrl != null) Get.dialog(AlertDialog(content: Text('Open map: ${msg.fileUrl}')));
        },
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(msg.content, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      );
    } else {
      // text
      content = Text(msg.content, style: const TextStyle(fontSize: 15));
    }

    // seen tick
    final seen = controller.showBlueTick(msg);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) SizedBox(width: 40), // space for avatar if you want
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      content,
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(width: 6),
                          if (isMe)
                            Icon(Icons.check, size: 16, color: seen ? Colors.blue : Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$h:$minute $ampm';
    } catch (e) {
      return '';
    }
  }

  String _resolveFileUrl(String? fileUrl) {
    if (fileUrl == null) return '';
    if (fileUrl.startsWith('http')) return fileUrl;
    // sometimes fileUrl is 'vendor/xxxxx.jpg' -> prepend base host
    return '$_baseHost/$fileUrl';
  }
}
