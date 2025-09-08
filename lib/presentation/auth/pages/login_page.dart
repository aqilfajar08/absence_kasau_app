import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/presentation/auth/bloc/login/login_bloc.dart';
import 'package:absence_kasau_app/presentation/home/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool isShowPassword = false;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.logIn.provider(),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                      CustomTextField(
                        controller: emailController,
                        label: 'Email Address',
                        showLabel: false,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            Assets.icons.email.path,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                      const SpaceHeight(20),
                      CustomTextField(
                        controller: passwordController,
                        label: 'Password',
                        showLabel: false,
                        obscureText: !isShowPassword,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            Assets.icons.password.path,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isShowPassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isShowPassword = !isShowPassword;
                            });
                          },
                        ),
                      ),
                      const SpaceHeight(40),
                      BlocListener<LoginBloc, LoginState>(
                        listener: (context, state) {
                          state.maybeWhen(
                            orElse: () {},
                            success: (data) async {
                              try {
                                await AuthLocalDatasource().saveAuthData(data);
                                if (context.mounted) {
                                  context.pushReplacement(const MainPage());
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to save login data: $e'),
                                      backgroundColor: AppColors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            error: (message) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: AppColors.red,
                                ),
                              );
                            },
                          );
                        },
                        child: BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            return state.maybeWhen(
                              orElse: () {
                                return Button.filled(
                                  onPressed: () {
                                    context.read<LoginBloc>().add(
                                      LoginEvent.login(
                                        emailController.text,
                                        passwordController.text,
                                      ),
                                    );
                                  },
                                  label: 'Sign In',
                                );
                              },
                              loading: () {
                                return const Center(child: CircularProgressIndicator());
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
