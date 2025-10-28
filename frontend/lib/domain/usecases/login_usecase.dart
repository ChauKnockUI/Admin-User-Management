import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Map<String, dynamic>> call(String username, String password) async {
    if (username.isEmpty) {
      throw Exception('Vui lòng nhập tên đăng nhập');
    }
    if (password.isEmpty) {
      throw Exception('Vui lòng nhập mật khẩu');
    }
    
    return await repository.login(username, password);
  }
}
