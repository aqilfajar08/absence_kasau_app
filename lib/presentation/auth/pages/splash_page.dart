import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/presentation/home/pages/main_page.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import 'login_page.dart';
import 'package:flutter/foundation.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Fallback background color
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary, // Fallback color
          image: DecorationImage(
            image: Assets.images.splashPage.provider(),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            onError: (exception, stackTrace) {
              if (kDebugMode) {
                print('❌ Error loading splash image: $exception');
              }
            },
          ),
        ),
        child: FutureBuilder(
          future: AuthLocalDatasource().isAuth(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Navigate after splash delay
              Future.delayed(
                const Duration(seconds: 2),
                () {
                  if (mounted) {
                    if (snapshot.data! == true) {
                      if (kDebugMode) {
                        print('🚀 Navigating to MainPage - User is authenticated');
                      }
                      context.pushReplacement(const MainPage());
                    } else {
                      if (kDebugMode) {
                        print('🔐 Navigating to LoginPage - User is not authenticated');
                      }
                      context.pushReplacement(const LoginPage());
                    }
                  }
                },
              );
            } else if (snapshot.hasError) {
              // Handle error case
              Future.delayed(
                const Duration(seconds: 2),
                () {
                  if (mounted) {
                    if (kDebugMode) {
                      print('❌ Navigating to LoginPage - Error checking authentication');
                    }
                    context.pushReplacement(const LoginPage());
                  }
                },
              );
            }

            // Return empty container since we only want the background image
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}