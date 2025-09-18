import 'package:absence_kasau_app/presentation/home/pages/history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:absence_kasau_app/presentation/home/bloc/profile/profile_bloc.dart';
import 'package:absence_kasau_app/data/datasources/profile_remote_datasource.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';

import '../../../core/core.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final _widgets = [
    const HomePage(),
    const HistoryPage(),
    // const SettingPage(),
    BlocProvider(
      create: (context) => ProfileBloc(
        profileRemoteDataSource: ProfileRemoteDataSourceImpl(
          client: http.Client(),
          authLocalDataSource: AuthLocalDatasource(),
        ),
      ),
      child: const ProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgets,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 16.0,
              blurStyle: BlurStyle.outer,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            useLegacyColorScheme: false,
            currentIndex: _selectedIndex,
            onTap: (value) => setState(() => _selectedIndex = value),
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(color: AppColors.primary),
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Assets.icons.nav.home.svg(
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 0 ? AppColors.primary : AppColors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Assets.icons.nav.history.svg(
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 1 ? AppColors.primary : AppColors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Riwayat',
              ),
              // BottomNavigationBarItem(
              //   icon: Assets.icons.nav.setting.svg(
              //     colorFilter: ColorFilter.mode(
              //       _selectedIndex == 2 ? AppColors.primary : AppColors.grey,
              //       BlendMode.srcIn,
              //     ),
              //   ),
              //   label: 'Pengaturan',
              // ),
              BottomNavigationBarItem(
                icon: Assets.icons.nav.profile.svg(
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 3 ? AppColors.primary : AppColors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}