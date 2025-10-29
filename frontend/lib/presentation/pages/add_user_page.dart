import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/blocs/users/form_validation_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _validationCubit = FormValidationCubit(); // ← Khởi tạo ngay

  @override
  void initState() {
    super.initState();
    
    if (widget.editing != null) {
      ctrlUsername.text = widget.editing!.username;
      ctrlEmail.text = widget.editing!.email;
      // Validate initial values
      Future.microtask(() {
        _validationCubit.validateUsername(ctrlUsername.text);
        _validationCubit.validateEmail(ctrlEmail.text);
      });
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
    _validationCubit.reset();
  }

  void submit() {
    // Validate tất cả fields trước
    _validationCubit.validateUsername(ctrlUsername.text);
    _validationCubit.validateEmail(ctrlEmail.text);
    _validationCubit.validatePassword(ctrlPassword.text, isRequired: widget.editing == null);

    if (!_validationCubit.state.isValid) {
      return;
    }

    final username = ctrlUsername.text.trim();
    final email = ctrlEmail.text.trim();
    final password = ctrlPassword.text;
    
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
    _validationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _validationCubit,
      child: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.all(16),
              ),
            );
            if (widget.editing == null) {
              resetForm();
            } else {
              Navigator.pop(context);
            }
          } else if (state is UsersOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.all(16),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Color(0xFFF8FAFC),
          body: Column(
            children: [
              // Header
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
                          child: Icon(
                            widget.editing == null ? Icons.person_add : Icons.edit,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.editing == null ? 'Thêm người dùng' : 'Cập nhật người dùng',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Quản lý thông tin người dùng',
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      
                      // Username field with realtime validation
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
                      BlocBuilder<FormValidationCubit, FormValidationState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: state.usernameError != null
                                      ? Border.all(color: Color(0xFFEF4444), width: 1.5)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: ctrlUsername,
                                  style: TextStyle(fontSize: 15),
                                  onChanged: (value) => _validationCubit.validateUsername(value),
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tên đăng nhập',
                                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  ),
                                ),
                              ),
                              if (state.usernameError != null) ...[
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.error_outline, size: 16, color: Color(0xFFEF4444)),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        state.usernameError!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      
                      // Email field with realtime validation
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
                      BlocBuilder<FormValidationCubit, FormValidationState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: state.emailError != null
                                      ? Border.all(color: Color(0xFFEF4444), width: 1.5)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: ctrlEmail,
                                  style: TextStyle(fontSize: 15),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) => _validationCubit.validateEmail(value),
                                  decoration: InputDecoration(
                                    hintText: 'Nhập địa chỉ email',
                                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  ),
                                ),
                              ),
                              if (state.emailError != null) ...[
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.error_outline, size: 16, color: Color(0xFFEF4444)),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        state.emailError!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      
                      // Password field with realtime validation
                      Row(
                        children: [
                          Icon(Icons.lock, color: Color(0xFF4F46E5), size: 24),
                          SizedBox(width: 8),
                          Text(
                            widget.editing == null ? 'Mật khẩu' : 'Mật khẩu mới (tùy chọn)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      BlocBuilder<FormValidationCubit, FormValidationState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: state.passwordError != null
                                      ? Border.all(color: Color(0xFFEF4444), width: 1.5)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: ctrlPassword,
                                  obscureText: true,
                                  style: TextStyle(fontSize: 15),
                                  onChanged: (value) => _validationCubit.validatePassword(
                                    value,
                                    isRequired: widget.editing == null,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: widget.editing == null 
                                        ? 'Nhập mật khẩu' 
                                        : 'Để trống nếu không đổi mật khẩu',
                                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  ),
                                ),
                              ),
                              if (state.passwordError != null) ...[
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.error_outline, size: 16, color: Color(0xFFEF4444)),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        state.passwordError!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (widget.editing != null && state.passwordError == null && ctrlPassword.text.isEmpty) ...[
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: Color(0xFF4F46E5)),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Để trống nếu không muốn đổi mật khẩu',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      
                      // Image upload (unchanged)
                      Row(
                        children: [
                          Icon(Icons.camera_alt, color: Color(0xFF4F46E5), size: 24),
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
                            border: Border.all(color: Color(0xFFD1D5DB), width: 2),
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
                                      style: TextStyle(fontSize: 16, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 5),
                                    Text('JPG, PNG tối đa 5MB', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(_pickedImage!.path), height: 100, width: 100, fit: BoxFit.cover),
                                ),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Submit button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                widget.editing == null ? 'Thêm người dùng' : 'Cập nhật người dùng',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, color: Color(0xFF475569)),
                              SizedBox(width: 8),
                              Text('Làm mới', style: TextStyle(color: Color(0xFF475569), fontSize: 16, fontWeight: FontWeight.w600)),
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
      ),
    );
  }
}