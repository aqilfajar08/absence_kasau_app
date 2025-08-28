import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/presentation/home/pages/main_page.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FutureBuilder(
        future: AuthLocalDatasource().isAuth(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Assets.images.logoWhite.image(),
                ),
                const Spacer(),
                Assets.images.logoCodeWithBahri.image(height: 70),
                const SpaceHeight(20.0),
              ],
            );
          }

          if (snapshot.hasData) {
            // Navigate after splash delay
            Future.delayed(
              const Duration(seconds: 2),
              () {
                if (mounted) {
                  if (snapshot.data! == true) {
                    context.pushReplacement(const MainPage());
                  } else {
                    context.pushReplacement(const LoginPage());
                  }
                }
              },
            );
          } else {
            // Handle error case
            Future.delayed(
              const Duration(seconds: 2),
              () {
                if (mounted) {
                  context.pushReplacement(const LoginPage());
                }
              },
            );
          }

          return Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Assets.images.logoWhite.image(),
              ),
              const Spacer(),
              Assets.images.logoCodeWithBahri.image(height: 70),
              const SpaceHeight(20.0),
            ],
          );
        },
      ),
    );
  }
}