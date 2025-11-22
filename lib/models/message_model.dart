class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType; // "text", "file", "location", etc.
  final String? fileUrl;
  final String? fileName;
  final String? sentAt;
  final String? createdAt;
  final String status; // sent/delivered/seen
  final List<dynamic> seenBy;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.sentAt,
    this.createdAt,
    required this.status,
    required this.seenBy,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) {
    return MessageModel(
      id: j["_id"] ?? "",
      chatId: j["chatId"] ?? "",
      senderId: j["senderId"] ?? "",
      content: j["content"] ?? "",
      messageType: j["messageType"] ?? "text",
      fileUrl: j["fileUrl"]?.toString(),
      fileName: j["fileName"]?.toString(),
      sentAt: j["sentAt"]?.toString(),
      createdAt: j["createdAt"]?.toString(),
      status: j["status"] ?? "sent",
      seenBy: (j["seenBy"] is List) ? j["seenBy"] as List : [],
    );
  }
}
