// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Base host (you can change to the IP host if needed)
  static const String _baseHost = 'https://testmobile-api.storeflaunt.co.in';

  // Endpoints
  static const String _loginPath = '/user/login';
  static String userChatsPath(String userId) => '/chats/user-chats/$userId';

  // common timeout
  static const Duration _timeout = Duration(seconds: 15);

  /// Login API
  /// Returns a Map with at least: { "statusCode": int, ...original response parsed... }
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = '$_baseHost$_loginPath';
    final body = {"email": email, "password": password, "role": "vendor"};

    print('--- API CALL: LOGIN ---');
    print('URL: $url');
    print('BODY: ${jsonEncode(body)}');

    try {
      final resp = await http
          .post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body))
          .timeout(_timeout);

      print('STATUS CODE: ${resp.statusCode}');
      print('RAW RESPONSE: ${resp.body}');

      // Try parse JSON; if it fails, return raw message
      final decoded = _tryDecode(resp.body);

      return {
        'statusCode': resp.statusCode,
        if (decoded != null) ...decoded,
        if (decoded == null) 'message': resp.body,
      };
    } on SocketException catch (e) {
      print('Network error: $e');
      return {'statusCode': 0, 'message': 'No Internet connection'};
    } on http.ClientException catch (e) {
      print('Client error: $e');
      return {'statusCode': 0, 'message': e.toString()};
    } on TimeoutException catch (e) {
      print('Timeout: $e');
      return {'statusCode': 0, 'message': 'Request timed out'};
    } catch (e) {
      print('Unexpected error: $e');
      return {'statusCode': 0, 'message': e.toString()};
    }
  }

  /// Get user chats with simple pagination
  /// page and limit are optional; default page=1, limit=10 if pass null or invalid
  Future<Map<String, dynamic>> getUserChats(String userId, {int page = 1, int limit = 10}) async {
    final safePage = (page != null && page > 0) ? page : 1;
    final safeLimit = (limit != null && limit > 0) ? limit : 10;
    final url = '$_baseHost${userChatsPath(userId)}?page=$safePage&limit=$safeLimit';

    print('--- API CALL: GET USER CHATS ---');
    print('URL: $url');

    try {
      final resp = await http.get(Uri.parse(url)).timeout(_timeout);

      print('STATUS CODE: ${resp.statusCode}');
      print('RAW RESPONSE: ${resp.body.substring(0, resp.body.length > 800 ? 800 : resp.body.length)}'); // limit print

      final decoded = _tryDecode(resp.body);

      return {
        'statusCode': resp.statusCode,
        if (decoded != null) 'data': decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded,
        if (decoded is Map && decoded.containsKey('message')) 'message': decoded['message'],
        if (decoded == null) 'message': resp.body,
      };
    } on SocketException catch (e) {
      print('Network error: $e');
      return {'statusCode': 0, 'message': 'No Internet connection'};
    } on TimeoutException catch (e) {
      print('Timeout: $e');
      return {'statusCode': 0, 'message': 'Request timed out'};
    } catch (e) {
      print('Unexpected error: $e');
      return {'statusCode': 0, 'message': e.toString()};
    }
  }

  // small helper to decode JSON safely
  dynamic _tryDecode(String source) {
    try {
      final parsed = jsonDecode(source);
      return parsed;
    } catch (e) {
      // not JSON
      return null;
    }
  }
  Future<Map<String, dynamic>> getMessages(String chatId, {int page = 1, int limit = 10}) async {
    final url = '$_baseHost/messages/get-messagesformobile/$chatId?page=$page&limit=$limit';

    print('--- API CALL: GET MESSAGES ---');
    print('URL: $url');

    try {
      final resp = await http.get(Uri.parse(url)).timeout(_timeout);

      print('STATUS CODE: ${resp.statusCode}');
      // avoid huge print
      final raw = resp.body;
      print('RAW RESPONSE (len=${raw.length}): ${raw.substring(0, raw.length > 600 ? 600 : raw.length)}');

      final decoded = _tryDecode(resp.body);

      return {
        'statusCode': resp.statusCode,
        if (decoded != null) 'data': decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded,
        if (decoded is Map && decoded.containsKey('message')) 'message': decoded['message'],
        if (decoded == null) 'message': resp.body,
      };
    } on SocketException catch (e) {
      print('Network error: $e');
      return {'statusCode': 0, 'message': 'No Internet connection'};
    } on TimeoutException catch (e) {
      print('Timeout: $e');
      return {'statusCode': 0, 'message': 'Request timed out'};
    } catch (e) {
      print('Unexpected error: $e');
      return {'statusCode': 0, 'message': e.toString()};
    }
  }
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    required String messageType,
    File? imageFile,
  }) async {
    try {
      var body = {
        "chatId": chatId,
        "senderId": senderId,
        "content": content,
        "messageType": messageType,
        "fileUrl": imageFile != null ? "image.jpg" : ""  // required!
      };

      print("📤 SENDING → ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse("http://45.129.87.38:6065/messages/sendMessage"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("🔵 RESPONSE: ${response.body}");

      return {
        "statusCode": response.statusCode,
        ...jsonDecode(response.body)
      };

    } catch (e) {
      return {"statusCode": 500, "message": e.toString()};
    }
  }

}
