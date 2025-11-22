import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatController extends GetxController {
  final storage = GetStorage();
  final ApiService _service = ApiService();

  var chats = <ChatModel>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;

  int page = 1;
  final int limit = 10;
  bool hasMore = true;

  late String userId;

  @override
  void onInit() {
    super.onInit();
    userId = storage.read("USER_ID");
    fetchChats();
  }

  Future<void> fetchChats() async {
    if (!hasMore) return;

    isLoading(true);

    final res = await _service.getUserChats(userId);

    if (res["statusCode"] == 200) {
      List data = res["data"] ?? [];

      if (data.isEmpty) {
        hasMore = false;
      } else {
        chats.addAll(
          data.map((e) => ChatModel.fromJson(e, userId)).toList(),
        );
        page++;
      }

    }

    isLoading(false);
  }

  Future<void> loadMore() async {
    if (isMoreLoading.value || !hasMore) return;

    isMoreLoading(true);
    await fetchChats();
    isMoreLoading(false);
  }
}
