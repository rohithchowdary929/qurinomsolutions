import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

class MessageController extends GetxController {
  final ApiService _api = ApiService();
  final storage = GetStorage();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final isLoading = false.obs;      // initial load
  final isLoadingMore = false.obs;  // loading older messages
  bool hasMore = true;

  // pagination — server-side if supported; otherwise client-side fallback
  int page = 1;
  final int limit = 10;

  late String chatId;
  late String currentUserId;

  /// Call this when you open the chat screen
  Future<void> init(String chatIdParam) async {
    chatId = chatIdParam;
    currentUserId = storage.read("USER_ID") ?? "";
    messages.clear();
    page = 1;
    hasMore = true;
    await loadInitial();
  }

  Future<void> loadInitial() async {
    isLoading(true);
    try {
      final resp = await _api.getMessages(chatId, page: page, limit: limit);
      if (resp['statusCode'] == 200) {
        // resp['data'] may be a list or map; handle both
        List raw = [];
        if (resp['data'] is List) raw = resp['data'];
        else if (resp['data'] is Map && resp['data']['messages'] is List) raw = resp['data']['messages'];
        else if (resp['data'] != null && resp['data'] is List) raw = resp['data'];

        final fetched = raw.map((e) => MessageModel.fromJson(e)).toList();

        // If the API returns newest-first or oldest-first is unknown.
        // We want chronological bottom-up with newest at the bottom.
        // Option: assume API returns oldest->newest; if not, reverse when needed.
        // To be safe, sort by createdAt if available.
        fetched.sort((a, b) {
          DateTime da = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          DateTime db = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return da.compareTo(db);
        });

        messages.addAll(fetched);

        // If fewer than limit returned, there's no more
        if (fetched.length < limit) hasMore = false;
        else page++;
      } else {
        hasMore = false;
      }
    } catch (e) {
      print("loadInitial error: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Load older messages (pagination) — prepend older messages to the list
  Future<void> loadOlder() async {
    if (!hasMore || isLoadingMore.value) return;
    isLoadingMore(true);
    try {
      final resp = await _api.getMessages(chatId, page: page, limit: limit);
      if (resp['statusCode'] == 200) {
        List raw = [];
        if (resp['data'] is List) raw = resp['data'];
        else if (resp['data'] is Map && resp['data']['messages'] is List) raw = resp['data']['messages'];
        else if (resp['data'] != null && resp['data'] is List) raw = resp['data'];

        final fetched = raw.map((e) => MessageModel.fromJson(e)).toList();
        fetched.sort((a, b) {
          DateTime da = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          DateTime db = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return da.compareTo(db);
        });

        if (fetched.isEmpty) {
          hasMore = false;
        } else {
          // Prepend older messages
          messages.insertAll(0, fetched);
          page++;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      print("loadOlder error: $e");
    } finally {
      isLoadingMore(false);
    }
  }

  /// Utility: determine if message is sent by current user
  bool isMe(MessageModel msg) => msg.senderId == currentUserId;

  /// Utility: whether to show blue tick for messages sent by me
  bool showBlueTick(MessageModel msg) {
    if (!isMe(msg)) return false;
    // message considered seen if status == "seen" or seenBy contains other ids
    if (msg.status.toLowerCase() == "seen") return true;
    if (msg.seenBy.isNotEmpty) {
      // if seenBy contains any id other than sender
      return msg.seenBy.any((id) => id != currentUserId);
    }
    return false;
  }
}
