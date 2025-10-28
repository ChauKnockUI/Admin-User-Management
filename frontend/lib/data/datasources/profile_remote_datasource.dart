import 'dart:convert';
import 'dart:io';
import '../../../utils/api_client.dart';
import '../models/user_model.dart';

class ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSource(this.apiClient);

  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get('/profile');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> updateProfile({
    String? username,
    String? email,
    String? password,
    File? imageFile,
  }) async {
    try {
      Map<String, String> fields = {};
      if (username != null) fields['username'] = username;
      if (email != null) fields['email'] = email;
      if (password != null) fields['password'] = password;
      
      final response = await apiClient.putMultipart(
        '/profile',
        fields: fields.isEmpty ? null : fields,
        imageFile: imageFile,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
