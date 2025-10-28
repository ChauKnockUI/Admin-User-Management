import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/user.dart';
import '../datasources/profile_remote_datasource.dart';
import 'dart:io';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<UserEntity> updateProfile({
    String? username,
    String? email,
    String? password,
    File? imageFile,
  }) async {
    return await remoteDataSource.updateProfile(
      username: username,
      email: email,
      password: password,
      imageFile: imageFile,
    );
  }
}
