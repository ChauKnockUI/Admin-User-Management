// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/data/datasources/users_remote_datasource.dart';
import 'package:frontend/data/datasources/profile_remote_datasource.dart';
import 'package:frontend/data/repositories/auth_repository_impl.dart';
import 'package:frontend/data/repositories/users_repository_impl.dart';
import 'package:frontend/data/repositories/profile_repository_impl.dart';
import 'package:frontend/domain/usecases/login_usecase.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:frontend/storage/storage.dart';

void main() {
  testWidgets('Login page smoke test', (WidgetTester tester) async {
    // Initialize dependencies for testing
    final storage = Storage();
    await storage.init();
    
    final apiClient = ApiClient();
    
    // Initialize data sources
    final authRemoteDataSource = AuthRemoteDataSource(apiClient);
    final usersRemoteDataSource = UsersRemoteDataSource(apiClient);
    final profileRemoteDataSource = ProfileRemoteDataSource(apiClient);
    
    // Initialize repositories
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      storage: storage,
    );
    final usersRepository = UsersRepositoryImpl(usersRemoteDataSource);
    final profileRepository = ProfileRepositoryImpl(profileRemoteDataSource);
    
    // Initialize use cases
    final loginUseCase = LoginUseCase(authRepository);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      loginUseCase: loginUseCase,
      storage: storage,
      apiClient: apiClient,
      usersRepository: usersRepository,
      profileRepository: profileRepository,
    ));

    // Wait for the app to build
    await tester.pumpAndSettle();
    
    // Verify that login page is displayed
    expect(find.text('🔐 Đăng nhập Admin'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Username and password fields
    expect(find.text('🚀 Đăng nhập'), findsOneWidget);
  });
}
