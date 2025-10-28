import '../entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<UserEntity> getProfile(String token);
}
