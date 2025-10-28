import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/repositories/users_repository_impl.dart';
import 'presentation/routers/app_router.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/users/users_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'utils/api_client.dart';
import 'storage/storage.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/users_remote_datasource.dart';
import 'data/datasources/profile_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/users_repository.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/usecases/login_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  final storage = Storage();
  await storage.init();
  
  // Get token from storage
  final token = await storage.getAccessToken();
  
  // Initialize API client with token
  final apiClient = ApiClient(token: token);
  
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
  
  runApp(MyApp(
    loginUseCase: loginUseCase,
    storage: storage,
    apiClient: apiClient,
    usersRepository: usersRepository,
    profileRepository: profileRepository,
  ));
}

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;
  final Storage storage;
  final ApiClient apiClient;
  final UsersRepository usersRepository;
  final ProfileRepositoryImpl profileRepository;
  final _router = AppRouter();

  MyApp({
    super.key,
    required this.loginUseCase,
    required this.storage,
    required this.apiClient,
    required this.usersRepository,
    required this.profileRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth bloc
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: loginUseCase,
            storage: storage,
            apiClient: apiClient,
          )..add(AuthCheckRequested()),
        ),
        // Users bloc
        BlocProvider(
          create: (_) => UsersBloc(usersRepository),
        ),
        // Profile bloc
        BlocProvider(
          create: (_) => ProfileBloc(profileRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Admin - User Management',
        theme: ThemeData(primarySwatch: Colors.blue),
        onGenerateRoute: _router.onGenerateRoute,
        initialRoute: AppRoutes.login,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
