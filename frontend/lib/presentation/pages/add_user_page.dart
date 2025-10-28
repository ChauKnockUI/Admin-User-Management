import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/rounded_input.dart';
import '../components/gradient_header.dart';
import '../components/bottom_nav.dart';
import '../blocs/users/users_bloc.dart';
import '../../domain/entities/user.dart';

class AddUserPage extends StatefulWidget {
  final UserEntity? editing;
  const AddUserPage({super.key, this.editing});
  @override State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final ctrlUsername = TextEditingController();
  final ctrlEmail = TextEditingController();
  final ctrlPassword = TextEditingController();
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      ctrlUsername.text = widget.editing!.username;
      ctrlEmail.text = widget.editing!.email;
    }
  }

  Future<void> pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _pickedImage = img);
  }

  void resetForm() {
    ctrlUsername.clear();
    ctrlEmail.clear();
    ctrlPassword.clear();
    setState(() => _pickedImage = null);
  }

  void submit() {
    final username = ctrlUsername.text.trim();
    final email = ctrlEmail.text.trim();
    final password = ctrlPassword.text;
    if (username.isEmpty || email.isEmpty || (widget.editing==null && password.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }
    
    File? imageFile;
    if (_pickedImage != null) {
      imageFile = File(_pickedImage!.path);
    }
    
    if (widget.editing != null) {
      context.read<UsersBloc>().add(UserUpdateRequested(
        id: widget.editing!.id,
        username: username,
        email: email,
        password: password.isEmpty ? null : password,
        imageFile: imageFile,
      ));
    } else {
      context.read<UsersBloc>().add(UserAddRequested(
        username: username,
        email: email,
        password: password,
        imageFile: imageFile,
      ));
    }
  }
  
  @override
  void dispose() {
    ctrlUsername.dispose();
    ctrlEmail.dispose();
    ctrlPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UsersOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          if (widget.editing == null) {
            resetForm();
          } else {
            Navigator.pop(context);
          }
        } else if (state is UsersOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Column(
          children: [
            GradientHeader(title: 'Quản lý người dùng'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username field
                    Row(
                      children: [
                        Icon(Icons.person, color: Color(0xFF4F46E5), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tên đăng nhập',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    RoundedInput(controller: ctrlUsername, hint: 'Nhập tên đăng nhập'),
                    SizedBox(height: 20),
                    
                    // Email field
                    Row(
                      children: [
                        Icon(Icons.email, color: Color(0xFF4F46E5), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    RoundedInput(controller: ctrlEmail, hint: 'Nhập địa chỉ email'),
                    SizedBox(height: 20),
                    
                    // Password field
                    if (widget.editing == null) ...[
                      Row(
                        children: [
                          Icon(Icons.lock, color: Color(0xFFFF9800), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Mật khẩu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      RoundedInput(controller: ctrlPassword, hint: 'Nhập mật khẩu', obscure: true),
                      SizedBox(height: 20),
                    ],
                    
                    // Image upload
                    Row(
                      children: [
                        Icon(Icons.camera_alt, color: Color(0xFF374151), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Ảnh đại diện',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFD1D5DB),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: _pickedImage == null
                            ? Column(
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48, color: Color(0xFF9CA3AF)),
                                  SizedBox(height: 10),
                                  Text(
                                    'Chọn ảnh đại diện',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF374151),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'JPG, PNG tối đa 5MB',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_pickedImage!.path),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Submit button
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
                        onPressed: submit,
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
                            Icon(Icons.check, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              widget.editing == null ? 'Thêm người dùng' : 'Cập nhật người dùng',
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
                    
                    // Reset button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE2E8F0)),
                      ),
                      child: ElevatedButton(
                        onPressed: resetForm,
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
                            Icon(Icons.refresh, color: Color(0xFF475569)),
                            SizedBox(width: 8),
                            Text(
                              'Làm mới',
                              style: TextStyle(
                                color: Color(0xFF475569),
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
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNav(currentIndex: 1),
      ),
    );
  }
}