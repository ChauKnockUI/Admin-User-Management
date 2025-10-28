import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../components/gradient_header.dart';
import '../components/bottom_nav.dart';
import '../components/rounded_input.dart';
import '../routers/app_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _pickedImage = img);
  }

  void cancelEdit() {
    setState(() {
      isEditing = false;
      _pickedImage = null;
      usernameCtrl.clear();
      emailCtrl.clear();
      passwordCtrl.clear();
    });
  }

  void submitProfile() {
    final username = usernameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    
    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }
    
    File? imageFile;
    if (_pickedImage != null) {
      imageFile = File(_pickedImage!.path);
    }
    
    context.read<ProfileBloc>().add(ProfileUpdateRequested(
      username: username,
      email: email,
      password: password.isEmpty ? null : password,
      imageFile: imageFile,
    ));
  }

  Widget _buildProfileImage(String? imageData, String username) {
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
            placeholder: (context, url) => CircularProgressIndicator(),
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
      backgroundColor: Color(0xFF4F46E5),
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4F46E5).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 30),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.account_circle, color: Colors.white, size: 33),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin cá nhân',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Quản lý thông tin tài khoản của bạn',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                  );
                  setState(() => isEditing = false);
                } else if (state is ProfileOperationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoadInProgress) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is ProfileLoadSuccess) {
                    final user = state.user;
                    
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile card
                          Container(
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
                            child: Row(
                              children: [
                                _buildProfileImage(user.image, user.username),
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
                          ),
                          SizedBox(height: 15),
                          
                          // Account info card
                          Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.ads_click_sharp, color: Color(0xFF4F46E5)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Thông tin tài khoản',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                _buildInfoRow(Icons.person, 'Tên đăng nhập:', user.username),
                                SizedBox(height: 15),
                                _buildInfoRow(Icons.email, 'Email:', user.email),
                              ],
                            ),
                          ),
                          SizedBox(height: 80),
                          
                          // Edit form or edit button
                          if (isEditing) ...[
                            // Edit form
                            Container(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chỉnh sửa thông tin',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Username field
                                  Row(
                                    children: [
                                      Icon(Icons.person, color: Color(0xFF4F46E5)),
                                      SizedBox(width: 8),
                                      Text('Tên đăng nhập', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  RoundedInput(controller: usernameCtrl, hint: 'Nhập tên đăng nhập'),
                                  SizedBox(height: 20),
                                  // Email field
                                  Row(
                                    children: [
                                      Icon(Icons.email, color: Color(0xFF4F46E5)),
                                      SizedBox(width: 8),
                                      Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  RoundedInput(controller: emailCtrl, hint: 'Nhập địa chỉ email'),
                                  SizedBox(height: 20),
                                  // Password field
                                  Row(
                                    children: [
                                      Icon(Icons.lock, color: Color(0xFFFF9800)),
                                      SizedBox(width: 8),
                                      Text('Mật khẩu mới', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  RoundedInput(controller: passwordCtrl, hint: 'Để trống nếu không đổi', obscure: true),
                                  SizedBox(height: 20),
                                  // Image upload
                                  Row(
                                    children: [
                                      Icon(Icons.camera_alt, color: Color(0xFF374151)),
                                      SizedBox(width: 8),
                                      Text('Ảnh đại diện', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: pickImage,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Color(0xFFD1D5DB), width: 2, style: BorderStyle.solid),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: _pickedImage == null
                                          ? Column(
                                              children: [
                                                Icon(Icons.add_photo_alternate, size: 32, color: Color(0xFF9CA3AF)),
                                                SizedBox(height: 8),
                                                Text('Chọn ảnh đại diện mới', style: TextStyle(color: Color(0xFF374151))),
                                              ],
                                            )
                                          : ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.file(File(_pickedImage!.path), height: 80, width: 80, fit: BoxFit.cover),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  // Update button
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: submitProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.save, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Cập nhật thông tin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  // Cancel button
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Color(0xFFE2E8F0)),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: cancelEdit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.close, color: Color(0xFF475569)),
                                          SizedBox(width: 8),
                                          Text('Hủy', style: TextStyle(color: Color(0xFF475569), fontSize: 16, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                          ] else ...[
                            // Edit button
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = true;
                                    usernameCtrl.text = user.username;
                                    emailCtrl.text = user.email;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Chỉnh sửa thông tin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                          
                          // Logout button
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(AuthLogoutRequested());
                                Navigator.pushReplacementNamed(context, AppRoutes.login);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Đăng xuất',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(child: Text('Không có dữ liệu profile'));
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: 3),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF6B7280), size: 20),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(color: Color(0xFF374151)),
        ),
      ],
    );
  }
}