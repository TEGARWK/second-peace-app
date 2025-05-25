import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, dynamic>> registerUser({
    required String nama,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
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

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        await _saveToken(data['token']);
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        await _saveToken(data['token']);
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String email,
    File? foto,
  }) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('$baseUrl/user/update');
      final request = http.MultipartRequest('POST', uri);

      request.fields['nama'] = nama;
      request.fields['email'] = email;

      if (foto != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_profil', foto.path),
        );
      }

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';
      }

      final response = await http.Response.fromStream(await request.send());
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update profil: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/addresses'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['alamat']);
      } else {
        throw Exception('Gagal memuat alamat');
      }
    } catch (e) {
      throw Exception('Kesalahan saat mengambil alamat: $e');
    }
  }

  Future<Map<String, dynamic>> _alamatRequest({
    required String method,
    int? id,
    required Map<String, dynamic> body,
    bool setPrimary = false,
  }) async {
    try {
      final token = await _getToken();
      late Uri url;

      if (setPrimary) {
        url = Uri.parse('$baseUrl/user/address/set-primary/$id');
      } else if (id != null && method == 'PUT') {
        url = Uri.parse('$baseUrl/user/address/$id');
      } else if (id != null && method == 'DELETE') {
        url = Uri.parse('$baseUrl/user/address/$id');
      } else {
        url = Uri.parse('$baseUrl/user/address');
      }

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      late http.Response response;

      switch (method) {
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PATCH':
          response = await http.patch(url, headers: headers);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Method tidak valid');
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal proses alamat: $e'};
    }
  }

  Future<Map<String, dynamic>> addAddress({
    required String nama,
    required String telepon,
    required String alamat,
    required String kota,
    required String kodePos,
    required bool utama,
    required int kotaId,
    required int provinsiId,
    required String kotaNama, // ✅ Tambah ini
    required String provinsiNama, // ✅ Tambah ini
  }) {
    return _alamatRequest(
      method: 'POST',
      body: {
        'nama': nama,
        'no_whatsapp': telepon,
        'alamat': alamat,
        'utama': utama,
        'kota_id': kotaId,
        'provinsi_id': provinsiId,
        'kota_nama': kotaNama, // ✅ Tambah ini
        'provinsi_nama': provinsiNama, // ✅ Tambah ini
      },
    );
  }

  Future<Map<String, dynamic>> updateAddress({
    required int id,
    required String nama,
    required String telepon,
    required String alamat,
    required String kota,
    required String kodePos,
    required bool utama,
    required int kotaId,
    required int provinsiId,
    required String kotaNama, // ✅ Tambah ini
    required String provinsiNama, // ✅ Tambah ini
  }) {
    return _alamatRequest(
      method: 'PUT',
      id: id,
      body: {
        'nama': nama,
        'no_whatsapp': telepon,
        'alamat': alamat,
        'utama': utama,
        'kota_id': kotaId,
        'provinsi_id': provinsiId,
        'kota_nama': kotaNama, // ✅ Tambah ini
        'provinsi_nama': provinsiNama, // ✅ Tambah ini
      },
    );
  }

  Future<Map<String, dynamic>> deleteAddress(int id) {
    return _alamatRequest(method: 'DELETE', id: id, body: {});
  }

  Future<Map<String, dynamic>> setPrimaryAddress(int id) {
    return _alamatRequest(method: 'PATCH', id: id, body: {}, setPrimary: true);
  }

  Future<Map<String, dynamic>> checkout(
    List<Map<String, dynamic>> produkList, {
    required String ekspedisi,
    required int ongkir,
    required String estimasi,
  }) async {
    try {
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
          'ekspedisi': ekspedisi,
          'ongkir': ongkir,
          'estimasi': estimasi,
        }),
      );

      print('[CHECKOUT] status: ${response.statusCode}');
      print('[CHECKOUT] response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['snap_token'] != null &&
          data['order_id'] != null) {
        return {
          'success': true,
          'snap_token': data['snap_token'],
          'order_id': data['order_id'],
          'expired_at': data['expired_at'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal checkout.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Checkout error: $e'};
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'message': 'Gagal mengambil data user'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
