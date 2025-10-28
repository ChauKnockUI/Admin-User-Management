import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/gradient_header.dart';
import '../components/bottom_nav.dart';
import '../blocs/users/users_bloc.dart';
import '../routers/app_router.dart';
import '../../domain/entities/user.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(UsersLoadRequested());
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildUserAvatar(String? imageData, String username) {
    if (imageData != null && imageData.isNotEmpty) {
      // Check if it's a data URI
      if (imageData.startsWith('data:image')) {
        try {
          final uriData = Uri.parse(imageData);
          if (uriData.data != null) {
            return ClipOval(
              child: Image.memory(
                uriData.data!.contentAsBytes(),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(username),
              ),
            );
          }
        } catch (e) {
          // Fallback to default if parsing fails
        }
      } else {
        // Regular URL
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageData,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2),
            errorWidget: (context, url, error) => _buildDefaultAvatar(username),
          ),
        );
      }
    }
    return _buildDefaultAvatar(username);
  }

  Widget _buildDefaultAvatar(String username) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Color(0xFFE5E7EB),
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: TextStyle(color: Color(0xFF9CA3AF)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          GradientHeader(title: 'Quản lý người dùng'),
          // Search bar
          Container(
            padding: EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchCtrl,
                onChanged: (value) {
                  context.read<UsersBloc>().add(UsersSearchRequested(value));
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm người dùng...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF4F46E5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<UsersBloc, UsersState>(
              builder: (context, state) {
                if (state is UsersLoadInProgress) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is UsersLoadSuccess) {
                  if (state.users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 64, color: Color(0xFF9CA3AF)),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có người dùng nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Hãy thêm người dùng đầu tiên của bạn!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return _buildUserCard(context, user);
                    },
                  );
                }
                if (state is UsersOperationFailure) {
                  return Center(
                    child: Text(
                      'Lỗi: ${state.message}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: 2),
    );
  }

  Widget _buildUserCard(BuildContext context, UserEntity user) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildUserAvatar(user.image, user.username),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addUser,
                      arguments: user,
                    );
                  },
                  icon: Icon(Icons.edit, color: Colors.white),
                  label: Text('Sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFBBF24),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(context, user),
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text('Xóa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UsersBloc>().add(UserDeleteRequested(user.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}