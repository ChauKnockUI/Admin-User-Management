import 'dart:convert';
import '../../../utils/api_client.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await apiClient.post('/auth/login', body: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'token': data['token'] as String,
          'user': data['user'] as Map<String, dynamic>,
        };
      } else {
        String errorMessage = 'Đăng nhập thất bại';
        try {
          final error = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = error['message'] ?? errorMessage;
        } catch (_) {
          errorMessage = 'Lỗi kết nối đến server';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    }
  }
}
