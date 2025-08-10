import 'package:client/model/auth_model.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio();

  AuthService() {
    _dio.options.baseUrl =
        'http://192.168.1.14:3000'; // Replace with your API base URL
    _dio.options.connectTimeout = Duration(seconds: 5);
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<Map<String, dynamic>> getUrl() async {
    try {
      final response = await _dio.get(
        '/auth/login',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('Error fetching URL: $e');
    }
  }

  Future<AuthSession> getToken(String sessionId) async {
    try {
      final response = await _dio.get(
        '/auth/token',
        options: Options(headers: {'session_id': sessionId}),
      );

      if (response.statusCode == 200) {
        return AuthSession.fromJson(response.data);
      } else {
        throw Exception('Failed to get token: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  Future<AuthSession> handleCallback(
    String code,
    String sessionId,
    String state,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'code': code, 'session_id': sessionId, 'state': state},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return AuthSession.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to handle callback: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error handling callback: $e');
    }
  }

  Future<void> logout() async {
    UnimplementedError();
  }
}
