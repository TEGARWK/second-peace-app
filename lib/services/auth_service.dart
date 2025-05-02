import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ REGISTER
  Future<Map<String, dynamic>> registerUser({
    required String nama,
    required String username,
    required String email,
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
        'password': password,
        'password_confirmation': password,
      }),
    );

    print('REGISTER STATUS CODE: ${response.statusCode}');
    print('REGISTER RESPONSE: ${response.body}');

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['token'] != null &&
          data['user'] != null) {
        await _saveToken(data['token']);
        return {
          'success': true,
          'token': data['token'],
          'user': {
            'id': data['user']['id'],
            'nama': data['user']['nama'] ?? 'Pengguna',
            'email': data['user']['email'] ?? '',
          },
        };
      } else {
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

  // ✅ LOGIN
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

    if (response.statusCode == 200 &&
        data['token'] != null &&
        data['user'] != null) {
      await _saveToken(data['token']);
      return {
        'success': true,
        'token': data['token'],
        'user': {
          'id': data['user']['id'],
          'nama': data['user']['nama'] ?? 'Pengguna',
          'email': data['user']['email'] ?? '',
        },
      };
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login gagal.'};
    }
  }

  // ✅ UPDATE PROFIL
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String nama,
    required String email,
    File? foto,
  }) async {
    final uri = Uri.parse('$baseUrl/user/update');
    final request = http.MultipartRequest('POST', uri);

    request.fields['id'] = userId.toString();
    request.fields['nama'] = nama;
    request.fields['email'] = email;

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

  // ✅ ALAMAT: Tambah
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
      Uri.parse('$baseUrl/user/address'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama': nama,
        'no_whatsapp': telepon,
        'alamat': alamat,
        'utama': utama,
      }),
    );

    return jsonDecode(response.body);
  }

  // ✅ ALAMAT: Update
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
      Uri.parse('$baseUrl/user/address/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama': nama,
        'no_whatsapp': telepon,
        'alamat': alamat,
        'utama': utama,
      }),
    );

    return jsonDecode(response.body);
  }

  // ✅ ALAMAT: Get all
  Future<List<Map<String, dynamic>>> getAddresses() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/user/addresses'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['alamat']);
    } else {
      throw Exception('Gagal memuat alamat');
    }
  }

  // ✅ ALAMAT: Hapus
  Future<Map<String, dynamic>> deleteAddress(int id) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/user/address/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return jsonDecode(response.body);
  }

  // ✅ ALAMAT: Set utama
  Future<Map<String, dynamic>> setPrimaryAddress(int id) async {
    final token = await _getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/user/address/set-primary/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return jsonDecode(response.body);
  }

  // ✅ MIDTRANS
  Future<String?> getSnapToken({required double amount}) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/midtrans/token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['snap_token'];
    } else {
      throw Exception('Gagal mendapatkan Snap Token');
    }
  }

  // ✅ CHECKOUT
  Future<Map<String, dynamic>> checkout(
    List<Map<String, dynamic>> produkList, {
    required String paymentMethod,
    required String ekspedisi,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'produk': produkList,
        'payment_method': paymentMethod,
        'ekspedisi': ekspedisi,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal checkout: ${response.body}');
    }
  }
}
