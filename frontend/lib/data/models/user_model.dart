import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.username, required super.email, super.image});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? json['id']).toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'image': image,
      };
}
