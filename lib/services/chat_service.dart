import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ChatService {
  //final String baseUrl = 'https://secondpeace.my.id/api/v1';
  final String baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// 🔄 Ambil semua pesan dalam satu chat room
  Future<List<Map<String, dynamic>>> fetchMessages(int roomId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/chat-rooms/$roomId/messages');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['messages']);
    } else {
      throw Exception('Gagal mengambil pesan: ${response.body}');
    }
  }

  /// 📨 Kirim pesan teks ke chat room
  Future<Map<String, dynamic>> sendMessage({
    required int roomId,
    required String message,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/chat-rooms/$roomId/messages');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengirim pesan: ${response.body}');
    }
  }

  /// 📥 Cek atau buat chat room
  Future<Map<String, dynamic>> getOrCreateRoom() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/chat-rooms');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mendapatkan chat room: ${response.body}');
    }
  }

  /// 📷 Upload gambar/video ke chat room
  Future<void> uploadMedia(XFile file, int roomId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/chat-rooms/$roomId/upload');

    final mimeType =
        lookupMimeType(file.path)?.split('/') ??
        ['application', 'octet-stream'];

    final request =
        http.MultipartRequest('POST', url)
          ..headers.addAll({
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          })
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              file.path,
              contentType: MediaType(mimeType[0], mimeType[1]),
            ),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal upload media: ${response.body}');
    }
  }

  Future<void> markMessagesAsRead(int roomId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/chat-rooms/$roomId/read');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menandai pesan sebagai dibaca: ${response.body}');
    }
  }

  /// 🔔 Cek apakah ada pesan yang belum dibaca
  Future<bool> hasUnreadMessages() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/chat-rooms/unread');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['has_unread'] == true;
    } else {
      throw Exception('Gagal cek pesan belum dibaca: ${response.body}');
    }
  }
}
