import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserCard extends StatelessWidget {
  final UserEntity user;
  const UserCard({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?')),
      title: Text(user.username),
      subtitle: Text(user.email),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: Icon(Icons.edit), onPressed: () {
          // navigate to edit page with user
        }),
        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {
          // dispatch delete event
        }),
      ]),
    );
  }
}
