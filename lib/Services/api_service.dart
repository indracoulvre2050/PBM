// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:praktikum4/models/product.dart';

class ApiService {
  final String baseUrl = 'https://task.itprojects.web.id/api';
  final storage = const FlutterSecureStorage();

  // 1. Endpoint Login
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['data']['token'];
      // Simpan token autentikasi
      await storage.write(key: 'token', value: token);
      return true;
    }
    return false;
  }

  // Mengambil token dari storage
  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  // 2. Endpoint Get Products
  Future<List<Product>> getProducts() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List productsJson = data['data']['products'] ?? [];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil draft produk');
    }
  }

  // 3. Endpoint Submit
  Future<bool> submitTask(String name, int price, String description, String githubUrl) async {
    final token = await _getToken();
    print ('Token yang digunakan: $token');

    final response = await http.post(
      Uri.parse('$baseUrl/products/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    return response.statusCode == 200 || response.statusCode == 201;
  }
}