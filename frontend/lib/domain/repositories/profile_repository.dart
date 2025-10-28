import '../entities/user.dart';
import 'dart:io';

abstract class ProfileRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({
    String? username,
    String? email,
    String? password,
    File? imageFile,
  });
}
