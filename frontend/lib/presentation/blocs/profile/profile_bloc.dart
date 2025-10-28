import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/profile_repository.dart';
import 'dart:io';

abstract class ProfileEvent extends Equatable {
  @override List<Object?> get props => [];
}
class ProfileLoadRequested extends ProfileEvent {}
class ProfileUpdateRequested extends ProfileEvent {
  final String? username;
  final String? email;
  final String? password;
  final File? imageFile;
  ProfileUpdateRequested({
    this.username,
    this.email,
    this.password,
    this.imageFile,
  });
  @override List<Object?> get props => [username, email, password];
}

abstract class ProfileState extends Equatable {
  @override List<Object?> get props => [];
}
class ProfileInitial extends ProfileState {}
class ProfileLoadInProgress extends ProfileState {}
class ProfileLoadSuccess extends ProfileState {
  final UserEntity user;
  ProfileLoadSuccess(this.user);
  @override List<Object?> get props => [user];
}
class ProfileOperationFailure extends ProfileState {
  final String message;
  ProfileOperationFailure(this.message);
  @override List<Object?> get props => [message];
}
class ProfileOperationSuccess extends ProfileState {
  final String message;
  ProfileOperationSuccess(this.message);
  @override List<Object?> get props => [message];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileUpdateRequested>(_onUpdate);
  }

  Future<void> _onLoad(ProfileLoadRequested e, Emitter<ProfileState> emit) async {
    emit(ProfileLoadInProgress());
    try {
      final user = await repository.getProfile();
      emit(ProfileLoadSuccess(user));
    } catch (ex) {
      String errorMessage = ex.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(ProfileOperationFailure(errorMessage));
    }
  }

  Future<void> _onUpdate(ProfileUpdateRequested e, Emitter<ProfileState> emit) async {
    emit(ProfileLoadInProgress());
    try {
      final user = await repository.updateProfile(
        username: e.username,
        email: e.email,
        password: e.password,
        imageFile: e.imageFile,
      );
      emit(ProfileOperationSuccess('Cập nhật thông tin thành công!'));
      emit(ProfileLoadSuccess(user));
    } catch (ex) {
      String errorMessage = ex.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      emit(ProfileOperationFailure(errorMessage));
      // Reload profile to show current state
      add(ProfileLoadRequested());
    }
  }
}
