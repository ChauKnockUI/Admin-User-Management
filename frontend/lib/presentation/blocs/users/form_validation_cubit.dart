import 'package:flutter_bloc/flutter_bloc.dart';

// States
class FormValidationState {
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final bool isValid;

  FormValidationState({
    this.usernameError,
    this.emailError,
    this.passwordError,
    this.isValid = false,
  });

  FormValidationState copyWith({
    String? usernameError,
    String? emailError,
    String? passwordError,
    bool? isValid,
  }) {
    return FormValidationState(
      usernameError: usernameError,
      emailError: emailError,
      passwordError: passwordError,
      isValid: isValid ?? this.isValid,
    );
  }
}

// Cubit
class FormValidationCubit extends Cubit<FormValidationState> {
  FormValidationCubit() : super(FormValidationState());

  void validateUsername(String value) {
    String? error;
    
    if (value.trim().isEmpty) {
      error = 'Vui lòng nhập tên đăng nhập';
    } else if (value.trim().length < 3) {
      error = 'Tên đăng nhập phải có ít nhất 3 ký tự';
    }

    emit(state.copyWith(
      usernameError: error,
      isValid: _checkIfValid(usernameError: error),
    ));
  }

  void validateEmail(String value) {
    String? error;
    
    if (value.trim().isEmpty) {
      error = 'Vui lòng nhập địa chỉ email';
    } else if (!value.contains('@')) {
      error = 'Email phải chứa ký tự @';
    } else if (!value.endsWith('.com')) {
      error = 'Email phải kết thúc bằng .com';
    } else {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.com$');
      if (!emailRegex.hasMatch(value)) {
        error = 'Email không đúng định dạng';
      }
    }

    emit(state.copyWith(
      emailError: error,
      isValid: _checkIfValid(emailError: error),
    ));
  }

  void validatePassword(String value, {bool isRequired = true}) {
    String? error;
    
    if (isRequired) {
      if (value.isEmpty) {
        error = 'Vui lòng nhập mật khẩu';
      } else if (value.length < 6) {
        error = 'Mật khẩu phải có ít nhất 6 ký tự';
      }
    } else if (value.isNotEmpty && value.length < 6) {
      error = 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    emit(state.copyWith(
      passwordError: error,
      isValid: _checkIfValid(passwordError: error),
    ));
  }

  bool _checkIfValid({String? usernameError, String? emailError, String? passwordError}) {
    final username = usernameError ?? state.usernameError;
    final email = emailError ?? state.emailError;
    final password = passwordError ?? state.passwordError;
    
    return username == null && email == null && password == null;
  }

  void reset() {
    emit(FormValidationState());
  }
}