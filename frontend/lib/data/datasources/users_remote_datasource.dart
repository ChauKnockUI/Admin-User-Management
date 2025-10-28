import 'dart:convert';
import 'dart:io';
import '../../../utils/api_client.dart';
import '../models/user_model.dart';

class UsersRemoteDataSource {
  final ApiClient apiClient;

  UsersRemoteDataSource(this.apiClient);

  Future<List<UserModel>> getUsers({String? search}) async {
    try {
      final queryParams = search != null && search.isNotEmpty
          ? {'search': search}
          : null;
      
      final response = await apiClient.get('/users', queryParams: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> createUser({
    required String username,
    required String email,
    required String password,
    File? imageFile,
  }) async {
    try {
      final response = await apiClient.postMultipart(
        '/users',
        fields: {
          'username': username,
          'email': email,
          'password': password,
        },
        imageFile: imageFile,
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create user');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> updateUser({
    required String id,
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
        '/users/$id',
        fields: fields.isEmpty ? null : fields,
        imageFile: imageFile,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final response = await apiClient.delete('/users/$id');
      
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
