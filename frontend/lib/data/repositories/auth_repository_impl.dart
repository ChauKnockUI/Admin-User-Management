import 'dart:convert';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../storage/storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final Storage storage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storage,
  });

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final result = await remoteDataSource.login(username, password);
      final token = result['token'] as String;
      final userData = result['user'] as Map<String, dynamic>;
      
      // Save token to storage
      await storage.saveTokens(token, ''); // No refresh token for now
      
      // Convert user data to entity
      final user = UserModel.fromJson(userData);
      
      return {
        'token': token,
        'user': user,
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserEntity> getProfile(String token) async {
    // TODO: Implement profile fetch if needed
    throw UnimplementedError();
  }
}
