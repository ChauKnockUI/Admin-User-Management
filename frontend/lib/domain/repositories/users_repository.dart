import '../entities/user.dart';
import 'dart:io';

abstract class UsersRepository {
  Future<List<UserEntity>> getUsers({String? search});
  Future<UserEntity> createUser({
    required String username,
    required String email,
    required String password,
    File? imageFile,
  });
  Future<UserEntity> updateUser({
    required String id,
    String? username,
    String? email,
    String? password,
    File? imageFile,
  });
  Future<void> deleteUser(String id);
}
