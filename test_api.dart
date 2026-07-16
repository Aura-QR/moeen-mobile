// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = 'https://librechat-assiut-moeen-backend.tfgpna.easypanel.host/api';
  
  // 1. Register a test user to get a token
  final registerRes = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': 'Test User',
      'email': 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com',
      'password': 'Password123',
      'password_confirmation': 'Password123',
      'phone': '0501234567'
    }),
  );

  print('Register Response: ${registerRes.statusCode}');
  
  if (registerRes.statusCode != 201 && registerRes.statusCode != 200) {
    print('Failed to register: ${registerRes.body}');
    return;
  }

  final token = jsonDecode(registerRes.body)['token'];
  print('Token: $token');

  // 2. Fetch subjects
  final subjectsRes = await http.get(
    Uri.parse('$baseUrl/subjects'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print('Subjects Response: ${subjectsRes.statusCode}');
  print('Body: ${subjectsRes.body}');
}
