import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShippingService {
  final String baseUrl = 'https://secondpeace.my.id/api/v1';
  //final String baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Map<String, dynamic>>> getProvinces() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/shipping/provinces');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception('Gagal memuat provinsi: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getCities(String provinceId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/shipping/cities?province_id=$provinceId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['cities'] ?? []);
    } else {
      throw Exception('Gagal memuat kota: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getCosts({
    required String originCityId,
    required String destinationCityId,
    required int weight,
    required String courier,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/shipping/cost');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'origin': originCityId,
        'destination': destinationCityId,
        'weight': weight,
        'courier': courier,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('Gagal menghitung ongkir: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> trackResi({
    required String ekspedisi,
    required String resi,
  }) async {
    const apiKey =
        'c2bf14c24e52b3eea60a70c409ebd993fe93c2c9e5a5ec8d3a88afed3aa82b8e'; // <-- Ganti dengan API key asli
    final url = Uri.parse(
      'https://api.binderbyte.com/v1/track?api_key=$apiKey&courier=$ekspedisi&awb=$resi',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 200) {
        return result['data'];
      } else {
        throw Exception(result['message'] ?? 'Gagal melacak resi');
      }
    } else {
      throw Exception('Gagal koneksi ke BinderByte');
    }
  }
}
