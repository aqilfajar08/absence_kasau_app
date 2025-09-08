import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:absence_kasau_app/core/core.dart';
import 'package:absence_kasau_app/presentation/auth/pages/login_page.dart';

import '../../auth/bloc/logout/logout_bloc.dart';
import 'package:absence_kasau_app/data/datasources/firebase_messaging_remote_datasourece.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Page'),
      ),
      body: Center(
          child: BlocConsumer<LogoutBloc, LogoutState>(
        listener: (context, state) {
          state.maybeMap(
            orElse: () {},
            success: (_) {
              context.pushReplacement(const LoginPage());
            },
            error: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value.error),
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
                  context.read<LogoutBloc>().add(const LogoutEvent.logout());
                },
                label: 'Logout',
              );
            },
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      )),
    );
  }
}