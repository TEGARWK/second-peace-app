import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.1.4:8000/api/auth';

  // Simpan token ke SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Ambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Register Pelanggan
  Future<Map<String, dynamic>> registerUser({
    required String nama,
    required String username,
    required String email,
    required String noTelepon,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama': nama,
        'username': username,
        'email': email,
        'no_telepon': noTelepon,
        'password': password,
      }),
    );

    print('REGISTER STATUS CODE: ${response.statusCode}');
    print('REGISTER RESPONSE: ${response.body}');

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _saveToken(data['token']);
        return data;
      } else {
        // Munculkan pesan error Laravel kalau ada
        return {
          'success': false,
          'message':
              data['message'] ??
              data['errors']?.values.first.first ??
              'Registrasi gagal.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memproses respons: ${e.toString()}',
      };
    }
  }

  // Login Pelanggan
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success']) {
      await _saveToken(data['token']);
    }
    return data;
  }

  // Update Profil Pelanggan
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String nama,
    required String email,
    required String noTelepon,
    File? foto,
  }) async {
    final uri = Uri.parse('http://192.168.1.4:8000/api/user/update');
    final request = http.MultipartRequest('POST', uri);

    request.fields['id'] = userId.toString();
    request.fields['nama'] = nama;
    request.fields['email'] = email;
    request.fields['no_telepon'] = noTelepon;

    final token = await _getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto_profil', foto.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  // Menambahkan alamat
  Future<Map<String, dynamic>> addAddress({
    required String nama,
    required String telepon,
    required String alamat,
    required String kota,
    required String kodePos,
    required bool utama,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('http://192.168.1.4:8000/api/user/address'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama': nama,
        'telepon': telepon,
        'alamat': alamat,
        'kota': kota,
        'kodePos': kodePos,
        'utama': utama,
      }),
    );

    return jsonDecode(response.body);
  }

  // Mengupdate alamat
  Future<Map<String, dynamic>> updateAddress({
    required int id,
    required String nama,
    required String telepon,
    required String alamat,
    required String kota,
    required String kodePos,
    required bool utama,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('http://192.168.1.4:8000/api/user/address/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama': nama,
        'telepon': telepon,
        'alamat': alamat,
        'kota': kota,
        'kodePos': kodePos,
        'utama': utama,
      }),
    );

    return jsonDecode(response.body);
  }

  // ✅ Mengambil semua alamat user
  Future<List<Map<String, dynamic>>> getAddresses() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('http://192.168.1.4:8000/api/user/addresses'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    print('GET ADDRESSES STATUS: ${response.statusCode}');
    print('GET ADDRESSES BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['addresses']);
    } else {
      throw Exception('Gagal memuat alamat');
    }
  }

  Future<Map<String, dynamic>> deleteAddress(int id) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('http://192.168.1.4:8000/api/user/address/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> setPrimaryAddress(int id) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('http://192.168.1.4:8000/api/user/address/set-primary/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }
}
