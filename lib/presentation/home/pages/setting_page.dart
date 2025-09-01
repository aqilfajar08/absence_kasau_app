import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:absence_kasau_app/core/core.dart';
import 'package:absence_kasau_app/presentation/auth/pages/login_page.dart';

import '../../auth/bloc/logout/logout_bloc.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: BlocConsumer<LogoutBloc, LogoutState>(
          listener: (context, state) {
            state.maybeMap(
              orElse: () {},
              success: (_) {
                if (kDebugMode) {
                  print('✅ Logout successful, navigating to login page');
                }
                context.pushReplacement(const LoginPage());
              },
              error: (value) {
                if (kDebugMode) {
                  print('❌ Logout error: ${value.error}');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${value.error}'),
                    backgroundColor: AppColors.red,
                  ),
                );
              },
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              orElse: () {
                return Button.filled(
                  onPressed: () {
                    if (kDebugMode) {
                      print('🚪 User initiated logout');
                    }
                    context.read<LogoutBloc>().add(const LogoutEvent.logout());
                  },
                  label: 'Logout',
                );
              },
              loading: () {
                return const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Logging out...'),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}