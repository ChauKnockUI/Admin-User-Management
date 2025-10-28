import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/rounded_input.dart';
import '../components/loading_button.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/users/users_bloc.dart';
import '../routers/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Load users after login
            context.read<UsersBloc>().add(UsersLoadRequested());
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Spacer(),
                Text('🔐 Đăng nhập Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                RoundedInput(controller: userCtrl, hint: 'Tên đăng nhập'),
                SizedBox(height: 8),
                RoundedInput(controller: passCtrl, hint: 'Mật khẩu', obscure: true),
                SizedBox(height: 20),
                BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                  bool loading = state is AuthLoading;
                  return LoadingButton(
                    label: '🚀 Đăng nhập',
                    loading: loading,
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLoginRequested(userCtrl.text.trim(), passCtrl.text));
                    },
                  );
                }),
                SizedBox(height: 8),
                Text('Demo: admin / admin123', style: TextStyle(color: Colors.grey)),
                Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
