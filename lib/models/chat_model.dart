class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String? profile;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.profile,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // get opposite user
    final participants = json["participants"] as List;
    final other = participants.firstWhere(
          (p) => p["_id"] != currentUserId,
      orElse: () => participants.first,
    );

    return ChatModel(
      id: json["_id"] ?? "",
      name: other["name"] ?? "Unknown",
      lastMessage: json["lastMessage"]?["content"] ?? "",
      time: json["lastMessage"]?["createdAt"] ?? "",
    );
  }
}
