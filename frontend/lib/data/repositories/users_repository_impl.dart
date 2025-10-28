import '../../domain/repositories/users_repository.dart';
import '../../domain/entities/user.dart';
import '../datasources/users_remote_datasource.dart';
import 'dart:io';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<UserEntity>> getUsers({String? search}) async {
    return await remoteDataSource.getUsers(search: search);
  }

  @override
  Future<UserEntity> createUser({
    required String username,
    required String email,
    required String password,
    File? imageFile,
  }) async {
    return await remoteDataSource.createUser(
      username: username,
      email: email,
      password: password,
      imageFile: imageFile,
    );
  }

  @override
  Future<UserEntity> updateUser({
    required String id,
    String? username,
    String? email,
    String? password,
    File? imageFile,
  }) async {
    return await remoteDataSource.updateUser(
      id: id,
      username: username,
      email: email,
      password: password,
      imageFile: imageFile,
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    await remoteDataSource.deleteUser(id);
  }
}
