import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../storage/storage.dart';
import '../../../utils/api_client.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override List<Object?> get props => [];
}
class AuthCheckRequested extends AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  AuthLoginRequested(this.username, this.password);
  @override List<Object?> get props => [username];
}
class AuthLogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override List<Object?> get props => [];
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final String token;
  AuthAuthenticated(this.user, this.token);
  @override List<Object?> get props => [user, token];
}
class AuthUnauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final Storage storage;
  final ApiClient apiClient;

  AuthBloc({
    required this.loginUseCase,
    required this.storage,
    required this.apiClient,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    try {
      final token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, but we'd need to validate it with backend
        // For now, just emit unauthenticated to force login
        emit(AuthUnauthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await loginUseCase(e.username, e.password);
      final user = result['user'] as UserEntity;
      final token = result['token'] as String;
      
      // Update ApiClient with new token
      apiClient.setToken(token);
      
      emit(AuthAuthenticated(user, token));
    } catch (ex) {
      String errorMessage = ex.toString();
      // Clean up error message
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested e, Emitter<AuthState> emit) async {
    try {
      await storage.clearTokens();
      apiClient.setToken(null);
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
