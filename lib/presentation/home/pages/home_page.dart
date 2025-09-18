import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:absence_kasau_app/core/helper/radius_calculate.dart';
import 'package:absence_kasau_app/core/services/navigation_helper.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:absence_kasau_app/presentation/home/bloc/is_checkin/is_checkin_bloc.dart';
import 'package:absence_kasau_app/presentation/home/pages/attendance_checkin_page.dart';
import 'package:absence_kasau_app/presentation/home/pages/attendance_checkout_page.dart';
import 'package:absence_kasau_app/presentation/home/pages/permission_page.dart';
import 'package:absence_kasau_app/presentation/home/pages/profile_page.dart';
import 'package:absence_kasau_app/presentation/home/pages/register_face_attendance_page.dart';
import 'package:absence_kasau_app/presentation/notification/pages/notification_page.dart';
import 'package:absence_kasau_app/presentation/home/bloc/profile/profile_bloc.dart';
import 'package:absence_kasau_app/data/datasources/profile_remote_datasource.dart';
import 'package:absence_kasau_app/core/notifiers/profile_notifier.dart';
import 'package:absence_kasau_app/data/services/notification_service.dart';
import 'package:absence_kasau_app/data/services/notification_stream_service.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:async';

import '../../../core/core.dart';
import '../widgets/menu_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String? faceEmbedding;
  final ProfileNotifier _profileNotifier = ProfileNotifier();
  bool _hasUnreadNotifications = false;
  StreamSubscription<int>? _notificationStreamSubscription;

  // Refresh attendance status and wait for the latest Success/Error state
  Future<(bool isCheckedIn, bool isCheckedOut)> _refreshAndGetAttendanceStatus(
    BuildContext context,
  ) async {
    final IsCheckinBloc bloc = context.read<IsCheckinBloc>();
    bloc.add(const IsCheckinEvent.isCheckIn());
    try {
      final IsCheckinState latestState = await bloc.stream
          .firstWhere(
            (state) => state.maybeWhen(
              success: (_) => true,
              error: (_) => true,
              orElse: () => false,
            ),
          )
          .timeout(const Duration(seconds: 3));

      final bool isCheckedIn = latestState.maybeWhen(
        success: (data) => data.isCheckIn,
        orElse: () => false,
      );
      final bool isCheckedOut = latestState.maybeWhen(
        success: (data) => data.isCheckOut,
        orElse: () => false,
      );
      return (isCheckedIn, isCheckedOut);
    } catch (_) {
      // On timeout or any error, return conservative defaults
      return (false, false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh face embedding when app comes back to foreground
      _refreshFaceEmbedding();
      // Refresh notification badge when app comes back to foreground
      _checkUnreadNotifications();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh face embedding every time this page becomes active
    _refreshFaceEmbedding();
    // Refresh notification badge every time this page becomes active
    _checkUnreadNotifications();
    // Refresh the page to update profile image
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<IsCheckinBloc>().add(const IsCheckinEvent.isCheckIn());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());
    _initializeFaceEmbedding();
    _loadUserData();
    _initializeNotificationStream();
    getCurrentPosition();
  }

  double? latitude;
  double? longitude;

  Future<void> getCurrentPosition() async {
    try {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;

      setState(() {});
    } on PlatformException {
      // ignore
    } catch (_) {}
  }

  Future<void> _initializeFaceEmbedding() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      if (mounted) {
        setState(() {
          faceEmbedding = authData?.user?.faceEmbedding;
        });

        // No debug prints
      }
    } catch (e) {
      // Handle error when getting authData
      if (mounted) {
        setState(() {
          faceEmbedding = null; // Set faceEmbedding to null if there's an error
        });
      }
    }
  }

  // Method to refresh face embedding status
  void _refreshFaceEmbedding() {
    _initializeFaceEmbedding();
  }

  // Initialize notification stream for real-time updates
  Future<void> _initializeNotificationStream() async {
    try {
      // Initialize the stream service
      await NotificationStreamService().initialize();
      
      // Listen to unread count changes
      _notificationStreamSubscription = NotificationStreamService()
          .unreadCountStream
          .listen((unreadCount) {
        if (mounted) {
          setState(() {
            _hasUnreadNotifications = unreadCount > 0;
          });
        }
      });
    } catch (e) {
      // Handle error silently
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = false;
        });
      }
    }
  }

  // Method to check for unread notifications (kept for compatibility)
  Future<void> _checkUnreadNotifications() async {
    try {
      final unreadCount = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = unreadCount > 0;
        });
      }
    } catch (e) {
      // Handle error silently
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = false;
        });
      }
    }
  }

  // Load user data and update ProfileNotifier
  Future<void> _loadUserData() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      if (authData?.user != null) {
        _profileNotifier.setUser(authData!.user!);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Method to check if face is currently registered (always checks fresh data)
  Future<bool> _checkIfFaceIsRegistered() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();

      final embedding = authData?.user?.faceEmbedding;

      // More strict validation
      final isRegistered =
          embedding != null &&
          embedding.isNotEmpty &&
          embedding.trim().isNotEmpty &&
          embedding.trim() != 'null' &&
          embedding.trim() != '0' &&
          embedding.trim() != 'undefined' &&
          embedding.length > 20; // Face embeddings are typically much longer

      return isRegistered;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.bgHome.provider(),
              alignment: Alignment.topCenter,
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Stack(
                children: [
                  // Main content row
                  Row(
                    children: [
                      ChangeNotifierProvider.value(
                        value: _profileNotifier,
                        child: Consumer<ProfileNotifier>(
                          builder: (context, profileNotifier, child) {
                            final user = profileNotifier.currentUser;
                            final isLoading = profileNotifier.isLoading;
                            
                            if (isLoading) {
                              return Container(
                                width: 48.0,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            return GestureDetector(
                              onTap: () async {
                                // Navigate to profile page with ProfileBloc
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (context) => ProfileBloc(
                                        profileRemoteDataSource: ProfileRemoteDataSourceImpl(
                                          client: http.Client(),
                                          authLocalDataSource: AuthLocalDatasource(),
                                        ),
                                      ),
                                      child: const ProfilePage(),
                                    ),
                                  ),
                                );
                                // Refresh user data when returning from profile
                                await _loadUserData();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: user?.imageUrl != null && user!.imageUrl.toString().isNotEmpty
                                    ? Image.network(
                                        user.imageUrl.toString(),
                                        width: 48.0,
                                        height: 48.0,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Fallback to default image if network image fails
                                          return Image.asset(
                                            'assets/images/blank-profile-circle.png',
                                            width: 48.0,
                                            height: 48.0,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/blank-profile-circle.png',
                                        width: 48.0,
                                        height: 48.0,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SpaceWidth(12.0),
                      Expanded(
                        child: ChangeNotifierProvider.value(
                          value: _profileNotifier,
                          child: Consumer<ProfileNotifier>(
                            builder: (context, profileNotifier, child) {
                              final user = profileNotifier.currentUser;
                              return Text(
                                'Halo, ${user?.name ?? 'Pengguna'}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: AppColors.white,
                                ),
                                maxLines: 2,
                              );
                            },
                          ),
                        ),
                      ),
                      // Spacer to push notification to the right
                      const SizedBox(width: 56.0), // Space for notification icon (40px + 16px padding)
                    ],
                  ),
                  // Notification icon positioned at default location (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const NotificationPage(),
                                ),
                              );
                              // Refresh notification badge when returning from notification page
                              _checkUnreadNotifications();
                            },
                            icon: Assets.icons.notificationRounded.svg(),
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                          // Red notification badge
                          if (_hasUnreadNotifications)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SpaceHeight(24.0),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    Text(
                      DateTime.now().toWITATime(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      DateTime.now().toFormattedDate(),
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                    const SpaceHeight(18.0),
                    const Divider(),
                    const SpaceHeight(30.0),
                    Text(
                      DateTime.now().toFormattedDate(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                    const SpaceHeight(6.0),
                    Text(
                      '${DateTime(2025, 9, 12, 7, 30).toWITATime()} - ${DateTime(2025, 9, 12, 16, 30).toWITATime()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceHeight(80.0),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    BlocBuilder<GetCompanyBloc, GetCompanyState>(
                      builder: (context, state) {
                        final latitudePoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.latitude!),
                        );
                        final longitudePoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.longitude!),
                        );
                        final radiusPoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.radiusKm!),
                        );
                        return BlocConsumer<IsCheckinBloc, IsCheckinState>(
                          listener: (context, state) {
                            // TODO: implement listener
                          },
                          builder: (context, state) {
                            // Keep builder reactive without using the value directly
                            final _ = state.maybeWhen(
                              orElse: () => false,
                              success: (data) => data.isCheckIn,
                            );
                            return MenuButton(
                              label: 'Datang',
                              iconPath: Assets.icons.menu.datang.path,
                              onPressed: () async {
                                final bool isFakeLocation =
                                    await DetectFakeLocation()
                                        .detectFakeLocation();
                                if (isFakeLocation) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Lokasi Palsu Terdeteksi',
                                        ),
                                        content: const Text(
                                          'Silakan nonaktifkan lokasi palsu untuk melanjutkan.',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                }

                                final distanceKm =
                                    RadiusCalculate.calculateDistance(
                                      latitude ?? 0.0,
                                      longitude ?? 0.0,
                                      latitudePoint,
                                      longitudePoint,
                                    );

                                // final position =
                                //       await Geolocator.getCurrentPosition();

                                print('jarak radius: $distanceKm');

                                if (distanceKm > radiusPoint) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Anda berada di luar jangkauan absensi',
                                      ),
                                      backgroundColor: AppColors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Always use the latest status from server before gating
                                final latest =
                                    await _refreshAndGetAttendanceStatus(
                                      context,
                                    );
                                final bool latestIsCheckedIn = latest.$1;

                                if (latestIsCheckedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Anda sudah melakukan absensi masuk hari ini',
                                      ),
                                      backgroundColor: AppColors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else {
                                  await NavigationHelper.navigateWithCameraCleanup(
                                    context,
                                    const AttendanceCheckinPage(),
                                  );
                                  // Refresh status after returning from check-in page
                                  if (context.mounted) {
                                    context.read<IsCheckinBloc>().add(
                                      const IsCheckinEvent.isCheckIn(),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                    BlocBuilder<GetCompanyBloc, GetCompanyState>(
                      builder: (context, state) {
                        final latitudePoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.latitude!),
                        );
                        final longitudePoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.longitude!),
                        );
                        final radiusPoint = state.maybeWhen(
                          orElse: () => 0.0,
                          success: (data) => double.parse(data.radiusKm!),
                        );
                        return BlocBuilder<IsCheckinBloc, IsCheckinState>(
                          builder: (context, state) {
                            // Keep reactive to status updates without using local vars here
                            final _ = state;
                            return MenuButton(
                              label: 'Pulang',
                              iconPath: Assets.icons.menu.pulang.path,
                              onPressed: () async {
                                final distanceKm =
                                    RadiusCalculate.calculateDistance(
                                      latitude ?? 0.0,
                                      longitude ?? 0.0,
                                      latitudePoint,
                                      longitudePoint,
                                    );

                                // final position =
                                //       await Geolocator.getCurrentPosition();

                                print('jarak radius: $distanceKm');

                                if (distanceKm > radiusPoint) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Anda berada di luar jangkauan absensi',
                                      ),
                                      backgroundColor: AppColors.red,
                                    ),
                                  );
                                  return;
                                }

                                final bool isFakeLocation =
                                    await DetectFakeLocation()
                                        .detectFakeLocation();
                                if (isFakeLocation) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Lokasi Palsu Terdeteksi',
                                        ),
                                        content: const Text(
                                          'Silakan nonaktifkan lokasi palsu untuk melanjutkan.',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                }

                                // Then, gate by the latest attendance status from server.
                                final latest =
                                    await _refreshAndGetAttendanceStatus(
                                      context,
                                    );
                                final bool latestIsCheckedIn = latest.$1;
                                final bool latestIsCheckedOut = latest.$2;

                                // Show 'already checked out' first if applicable
                                if (latestIsCheckedOut) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Anda sudah melakukan absensi pulang hari ini',
                                      ),
                                      backgroundColor: AppColors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  return;
                                }

                                // Then validate check-in status
                                if (!latestIsCheckedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Anda belum melakukan absensi masuk hari ini',
                                      ),
                                      backgroundColor: AppColors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  return;
                                }

                                // Finally, navigate exactly once and refresh status after.
                                await NavigationHelper.navigateWithCameraCleanup(
                                  context,
                                  const AttendanceCheckoutPage(),
                                );
                                if (context.mounted) {
                                  context.read<IsCheckinBloc>().add(
                                    const IsCheckinEvent.isCheckIn(),
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                    MenuButton(
                      label: 'Izin',
                      iconPath: Assets.icons.menu.izin.path,
                      onPressed: () {
                        context.push(const PermissionPage());
                      },
                    ),
                    // MenuButton(
                    //   label: 'Catatan',
                    //   iconPath: Assets.icons.menu.catatan.path,
                    //   onPressed: () {},
                    // ),
                  ],
                ),
              ),
              const SpaceHeight(15.0),
              // Use FutureBuilder to always check current data
              FutureBuilder<bool>(
                future: _checkIfFaceIsRegistered(),
                builder: (context, snapshot) {
                  // Show loading state while checking
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Button.filled(
                      onPressed: () {}, // Empty function while loading
                      label: 'Memeriksa Registrasi Wajah...',
                      icon: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      color: AppColors.grey,
                    );
                  }

                  // Handle errors - default to not registered
                  if (snapshot.hasError) {
                    // ignore errors; default to not registered
                  }

                  // Get the result, default to false (not registered)
                  final isRegistered = snapshot.data == true;

                  // No debug prints
                  return isRegistered
                      ? BlocBuilder<IsCheckinBloc, IsCheckinState>(
                        builder: (context, state) {
                          return BlocBuilder<GetCompanyBloc, GetCompanyState>(
                            builder: (context, state) {
                              final latitudePoint = state.maybeWhen(
                                orElse: () => 0.0,
                                success: (data) => double.parse(data.latitude!),
                              );
                              final longitudePoint = state.maybeWhen(
                                orElse: () => 0.0,
                                success:
                                    (data) => double.parse(data.longitude!),
                              );
                              final radiusPoint = state.maybeWhen(
                                orElse: () => 0.0,
                                success: (data) => double.parse(data.radiusKm!),
                              );
                              return Button.filled(
                                onPressed: () async {
                                  // Ensure we have current location
                                  if (latitude == null || longitude == null) {
                                    await getCurrentPosition();
                                  }
                                  if (latitude == null || longitude == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Lokasi belum tersedia. Mohon tunggu sebentar atau coba lagi.',
                                        ),
                                        backgroundColor: AppColors.red,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    return;
                                  }

                                  // Radius validation
                                  final distanceKm =
                                      RadiusCalculate.calculateDistance(
                                        latitude ?? 0.0,
                                        longitude ?? 0.0,
                                        latitudePoint,
                                        longitudePoint,
                                      );
                                  if (distanceKm > radiusPoint) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Anda berada di luar jangkauan absensi',
                                        ),
                                        backgroundColor: AppColors.red,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    return;
                                  }

                                  // Fake location check
                                  final bool isFakeLocation =
                                      await DetectFakeLocation()
                                          .detectFakeLocation();
                                  if (isFakeLocation) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Lokasi Palsu Terdeteksi',
                                          ),
                                          content: const Text(
                                            'Silakan nonaktifkan lokasi palsu untuk melanjutkan.',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  // Refresh latest status and route accordingly
                                  final latest =
                                      await _refreshAndGetAttendanceStatus(
                                        context,
                                      );
                                  final bool latestIsCheckedIn = latest.$1;
                                  final bool latestIsCheckedOut = latest.$2;

                                  if (!latestIsCheckedIn) {
                                    await NavigationHelper.navigateWithCameraCleanup(
                                      context,
                                      const AttendanceCheckinPage(),
                                    );
                                    if (context.mounted) {
                                      context.read<IsCheckinBloc>().add(
                                        const IsCheckinEvent.isCheckIn(),
                                      );
                                    }
                                    return;
                                  }

                                  if (!latestIsCheckedOut) {
                                    await NavigationHelper.navigateWithCameraCleanup(
                                      context,
                                      const AttendanceCheckoutPage(),
                                    );
                                    if (context.mounted) {
                                      context.read<IsCheckinBloc>().add(
                                        const IsCheckinEvent.isCheckIn(),
                                      );
                                    }
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Anda sudah melakukan absensi pulang hari ini',
                                      ),
                                      backgroundColor: AppColors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                },
                                label: 'Absensi Menggunakan Face ID',
                                icon: Assets.icons.attendance.svg(),
                                color: AppColors.primary,
                              );
                            },
                          );
                        },
                      )
                      : Button.filled(
                        onPressed: () {
                          showBottomSheet(
                            backgroundColor: AppColors.white,
                            context: context,
                            builder:
                                (context) => Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 60.0,
                                        height: 8.0,
                                        child: Divider(
                                          color: AppColors.lightSheet,
                                        ),
                                      ),
                                      const CloseButton(),
                                      const Center(
                                        child: Text(
                                          'Oops !',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24.0,
                                          ),
                                        ),
                                      ),
                                      const SpaceHeight(4.0),
                                      const Center(
                                        child: Text(
                                          'Aplikasi ingin mengakses Kamera',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                      const SpaceHeight(36.0),
                                      Button.filled(
                                        onPressed: () => context.pop(),
                                        label: 'Tolak',
                                        color: AppColors.secondary,
                                      ),
                                      const SpaceHeight(16.0),
                                      Button.filled(
                                        onPressed: () async {
                                          context.pop();
                                          // Navigate to face registration with proper camera cleanup
                                          await NavigationHelper.navigateWithCameraCleanup(
                                            context,
                                            const RegisterFaceAttendancePage(),
                                          );
                                          // Refresh face embedding status when user returns
                                          _refreshFaceEmbedding();
                                        },
                                        label: 'Izinkan',
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },
                        label: 'Absensi Menggunakan Face ID',
                        icon: Assets.icons.attendance.svg(),
                        color: AppColors.red,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
