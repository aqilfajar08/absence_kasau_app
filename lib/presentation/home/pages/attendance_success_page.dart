// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:absence_kasau_app/presentation/home/bloc/is_checkin/is_checkin_bloc.dart';
import 'package:absence_kasau_app/presentation/home/pages/main_page.dart';

import '../../../core/core.dart';

class AttendanceSuccessPage extends StatelessWidget {
  final String status;
  const AttendanceSuccessPage({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.background.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Assets.images.success.image(),
            const Text(
              'Asiap !',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SpaceHeight(8.0),
            Center(
              child: Text(
                'Anda telah melakukan Absensi $status Pukul ${DateTime.now().toWITATime()}. Selamat bekerja ',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SpaceHeight(80.0),
            Button.filled(
              onPressed: () {
                if (kDebugMode) {
                  debugPrint('Success page button pressed - navigating to main page with bottom navigation');
                }
                
                // Update the checkin status
                context
                .read<IsCheckinBloc>()
                .add(const IsCheckinEvent.isCheckIn());
                
                // Navigate back to main page (which includes bottom navigation)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const MainPage(),
                  ),
                  (route) => false, // Remove all previous routes
                );
              },
              label: 'Oke, dimengerti',
            ),
          ],
        ),
      ),
    ),
    );
  }
}
