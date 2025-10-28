import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/users_repository.dart';
import 'dart:io';

abstract class UsersEvent extends Equatable {
  @override List<Object?> get props => [];
}
class UsersLoadRequested extends UsersEvent {}
class UsersSearchRequested extends UsersEvent {
  final String query;
  UsersSearchRequested(this.query);
  @override List<Object?> get props => [query];
}
class UserAddRequested extends UsersEvent {
  final String username;
  final String email;
  final String password;
  final File? imageFile;
  UserAddRequested({
    required this.username,
    required this.email,
    required this.password,
    this.imageFile,
  });
  @override List<Object?> get props => [username, email, password];
}
class UserUpdateRequested extends UsersEvent {
  final String id;
  final String? username;
  final String? email;
  final String? password;
  final File? imageFile;
  UserUpdateRequested({
    required this.id,
    this.username,
    this.email,
    this.password,
    this.imageFile,
  });
  @override List<Object?> get props => [id, username, email];
}
class UserDeleteRequested extends UsersEvent {
  final String userId;
  UserDeleteRequested(this.userId);
  @override List<Object?> get props => [userId];
}

abstract class UsersState extends Equatable {
  @override List<Object?> get props => [];
}
class UsersInitial extends UsersState {}
class UsersLoadInProgress extends UsersState {}
class UsersLoadSuccess extends UsersState {
  final List<UserEntity> users;
  UsersLoadSuccess(this.users);
  @override List<Object?> get props => [users];
}
class UsersOperationFailure extends UsersState {
  final String message;
  UsersOperationFailure(this.message);
  @override List<Object?> get props => [message];
}
class UsersOperationSuccess extends UsersState {
  final String message;
  UsersOperationSuccess(this.message);
  @override List<Object?> get props => [message];
}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository repository;

  UsersBloc(this.repository) : super(UsersInitial()) {
    on<UsersLoadRequested>(_onLoad);
    on<UsersSearchRequested>(_onSearch);
    on<UserAddRequested>(_onAdd);
    on<UserUpdateRequested>(_onUpdate);
    on<UserDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(UsersLoadRequested e, Emitter<UsersState> emit) async {
    emit(UsersLoadInProgress());
    try {
      final users = await repository.getUsers();
      emit(UsersLoadSuccess(users));
    } catch (ex) {
      String errorMessage = ex.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(UsersOperationFailure(errorMessage));
    }
  }

  Future<void> _onSearch(UsersSearchRequested e, Emitter<UsersState> emit) async {
    emit(UsersLoadInProgress());
    try {
      final users = await repository.getUsers(search: e.query);
      emit(UsersLoadSuccess(users));
    } catch (ex) {
      String errorMessage = ex.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(UsersOperationFailure(errorMessage));
    }
  }

  Future<void> _onAdd(UserAddRequested e, Emitter<UsersState> emit) async {
    try {
      await repository.createUser(
        username: e.username,
        email: e.email,
        password: e.password,
        imageFile: e.imageFile,
      );
      emit(UsersOperationSuccess('Thêm người dùng thành công!'));
      // Reload users list
      add(UsersLoadRequested());
    } catch (ex) {
      String errorMessage = ex.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(UsersOperationFailure(errorMessage));
    }
  }

  Future<void> _onUpdate(UserUpdateRequested e, Emitter<UsersState> emit) async {
    try {
      await repository.updateUser(
        id: e.id,
        username: e.username,
        email: e.email,
        password: e.password,
        imageFile: e.imageFile,
      );
      emit(UsersOperationSuccess('Cập nhật người dùng thành công!'));
      // Reload users list
      add(UsersLoadRequested());
    } catch (ex) {
      String errorMessage = ex.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(UsersOperationFailure(errorMessage));
    }
  }

  Future<void> _onDelete(UserDeleteRequested e, Emitter<UsersState> emit) async {
    try {
      await repository.deleteUser(e.userId);
      emit(UsersOperationSuccess('Xóa người dùng thành công!'));
      // Reload users list
      add(UsersLoadRequested());
    } catch (ex) {
      String errorMessage = ex.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(UsersOperationFailure(errorMessage));
    }
  }
}
