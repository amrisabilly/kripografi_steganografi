import 'dart:convert';
import 'dart:io';
import 'package:aplikasi_dua/config/constant.dart';
import 'package:aplikasi_dua/services/storage_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final StorageService _storageService = StorageService();

  // --- Mendapatkan Header Otentikasi ---
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // --- Endpoint Autentikasi ---
  Future<http.Response> register({
    required String username,
    required String displayName,
    required String email,
    required String password,
    required String publicKey,
  }) async {
    return http.post(
      Uri.parse('$BASE_URL/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'display_name': displayName,
        'email': email,
        'password': password,
        'public_key': publicKey,
        'bio': '', // Default bio kosong
      }),
    );
  }

  Future<http.Response> login({
    required String username,
    required String password,
  }) async {
    print('[DEBUG] Login request: $username');
    final response = await http.post(
      Uri.parse('$BASE_URL/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    print('[DEBUG] Login response: ${response.statusCode} ${response.body}');
    return response;
  }

  Future<http.Response> logout() async {
    return http.post(
      Uri.parse('$BASE_URL/logout'),
      headers: await _getAuthHeaders(),
    );
  }

  // --- Endpoint Pengguna ---
  Future<http.Response> getUsers() async {
    final headers = await _getAuthHeaders();
    return await http.get(Uri.parse('$BASE_URL/users'), headers: headers);
  }

  Future<http.Response> updateProfile(Map<String, String> profileData) async {
    return http.post(
      Uri.parse('$BASE_URL/update-profile'),
      headers: await _getAuthHeaders(),
      body: jsonEncode(profileData),
    );
  }

  Future<http.Response> updateProfilePicture(File imageFile) async {
    final token = await _storageService.getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$BASE_URL/update-profile'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(
      await http.MultipartFile.fromPath('profile_photo', imageFile.path),
    );
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // --- Endpoint Pesan ---
  Future<http.Response> getMessages({required int userId}) async {
    final headers = await _getAuthHeaders();
    return await http.get(
      Uri.parse('$BASE_URL/messages?user_id=$userId'),
      headers: headers,
    );
  }

  Future<http.Response> sendMessage({
    required String senderId,
    required String recipientId,
    required String contentType,
    required String encryptedPayload,
    String? fileName,
    String? fileSize,
  }) async {
    return http.post(
      Uri.parse('$BASE_URL/messages'),
      headers: await _getAuthHeaders(),
      body: jsonEncode({
        'sender_id': senderId,
        'recipient_id': recipientId,
        'content_type': contentType,
        'encrypted_payload': encryptedPayload,
        'file_name': fileName,
        'file_size': fileSize,
      }),
    );
  }

  Future<http.Response> getChats({required int userId}) async {
    final headers = await _getAuthHeaders();
    // Ganti endpoint sesuai backend Anda, misal pakai /messages?user_id=...
    return await http.get(
      Uri.parse('$BASE_URL/messages?user_id=$userId'),
      headers: headers,
    );
  }
}
