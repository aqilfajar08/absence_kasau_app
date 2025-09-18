import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:absence_kasau_app/core/core.dart';
import 'package:absence_kasau_app/data/models/response/auth_response_model.dart';
import 'package:absence_kasau_app/presentation/home/bloc/profile/profile_bloc.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/core/constants/variables.dart';
import 'package:absence_kasau_app/core/notifiers/profile_notifier.dart';
import 'package:absence_kasau_app/presentation/auth/pages/login_page.dart';
import 'package:absence_kasau_app/presentation/auth/bloc/logout/logout_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Profile image state
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  User? _user;
  final ProfileNotifier _profileNotifier = ProfileNotifier();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload user data when page becomes visible
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authLocalDataSource = AuthLocalDatasource();
    final authData = await authLocalDataSource.getAuthData();
    print('=== DEBUG USER DATA ===');
    print('Auth data exists: ${authData != null}');
    print('User exists: ${authData?.user != null}');
    print('User imageUrl: ${authData?.user?.imageUrl}');
    print('User imageUrl type: ${authData?.user?.imageUrl.runtimeType}');
    print('User imageUrl isEmpty: ${authData?.user?.imageUrl.toString().isEmpty}');
    print('======================');
    
    if (mounted && authData?.user != null) {
      User user = authData!.user!;
      
      // Fix the image URL by combining with base URL if it's a relative path
      if (user.imageUrl != null && user.imageUrl.toString().startsWith('/')) {
        // Use the helper method to construct the full URL
        final fullImageUrl = Variables.getImageUrl(user.imageUrl.toString());
        
        // Get alternative patterns for debugging
        final patterns = Variables.getImageUrlPatterns(user.imageUrl.toString());
        print('Trying image URL patterns:');
        for (int i = 0; i < patterns.length; i++) {
          print('  Pattern ${i + 1}: ${patterns[i]}');
        }
        
        user = User(
          id: user.id,
          name: user.name,
          position: user.position,
          department: user.department,
          faceEmbedding: user.faceEmbedding,
          imageUrl: fullImageUrl,
          email: user.email,
          emailVerifiedAt: user.emailVerifiedAt,
          twoFactorSecret: user.twoFactorSecret,
          twoFactorRecoveryCodes: user.twoFactorRecoveryCodes,
          twoFactorConfirmedAt: user.twoFactorConfirmedAt,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        );
        print('Using imageUrl: $fullImageUrl');
      }
      
      setState(() {
        _user = user;
      });
      
      // Update the global ProfileNotifier
      _profileNotifier.setUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          uploading: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mengunggah foto profil...'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          uploadSuccess: (user) async {
            print('Upload success - User imageUrl: ${user.imageUrl}');
            
            // Update local auth data with new user info
            final authLocalDataSource = AuthLocalDatasource();
            final authData = await authLocalDataSource.getAuthData();
            if (authData != null) {
              final updatedAuthData = authData.copyWith(user: user);
              await authLocalDataSource.saveAuthData(updatedAuthData);
            }
            
            setState(() {
              _user = user;
              // Keep _selectedImage for a moment to show the preview
              // It will be cleared when user navigates away or after a delay
            });
            
            // Update the global ProfileNotifier immediately
            _profileNotifier.setUser(user);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto profil berhasil diperbarui!'),
                backgroundColor: AppColors.green,
              ),
            );
            
            // Clear local image after a short delay to allow network image to load
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _selectedImage = null;
                });
              }
            });
          },
          deleting: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menghapus foto profil...'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          deleteSuccess: (user) async {
            print('Delete success - User imageUrl: ${user.imageUrl}');
            
            // Update local auth data with new user info
            final authLocalDataSource = AuthLocalDatasource();
            final authData = await authLocalDataSource.getAuthData();
            if (authData != null) {
              final updatedAuthData = authData.copyWith(user: user);
              await authLocalDataSource.saveAuthData(updatedAuthData);
            }
            
            setState(() {
              _user = user;
              _selectedImage = null;
            });
            
            // Update the global ProfileNotifier immediately
            _profileNotifier.setUser(user);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto profil berhasil dihapus!'),
                backgroundColor: AppColors.green,
              ),
            );
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
      builder: (context, state) {
        return BlocListener<LogoutBloc, LogoutState>(
          listener: (context, logoutState) {
            logoutState.maybeMap(
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
          child: Scaffold(
            body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.images.bgHome.provider(),
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Column(
                children: [
                  // Top section with profile info
                  _buildTopSection(),
                  // Bottom section with account options
                  _buildBottomSection(),
                  const SizedBox(height: 80.0), // Bottom spacing like home page
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildTopSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Stack(
        children: [
          // Back button
          // Positioned(
          //   top: 20,
          //   left: 20,
          //   child: Container(
          //     width: 40,
          //     height: 40,
          //     decoration: BoxDecoration(
          //       color: Colors.transparent,
          //       border: Border.all(color: AppColors.white, width: 2),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: IconButton(
          //       onPressed: () => Navigator.of(context).pop(),
          //       icon: const Icon(
          //         Icons.arrow_back_ios_new,
          //         color: AppColors.white,
          //         size: 20,
          //       ),
          //     ),
          //   ),
          // ),
          // Profile title
          const Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Text(
              'Profil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Profile picture and info - Centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile picture with edit button
                Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        // Debug which image is being used
                        if (_selectedImage != null) {
                          print('Using local image: ${_selectedImage!.path}');
                        } else if (_user?.imageUrl != null && _user!.imageUrl.toString().isNotEmpty) {
                          print('Using network image: ${_user!.imageUrl}');
                          print('Testing URL accessibility...');
                        } else {
                          print('Using default asset image');
                        }
                        
                        return Container(
                          width: 125,
                          height: 125,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 4),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : _user?.imageUrl != null && _user!.imageUrl.toString().isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(_user!.imageUrl.toString()),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
                                          print('=== NETWORK IMAGE ERROR ===');
                                          print('Error: $exception');
                                          print('Image URL: ${_user!.imageUrl}');
                                          print('Trying alternative URL...');
                                          
                                          // Try alternative URL pattern
                                          final altUrl = _user!.imageUrl.toString().replaceFirst('/storage/', '/public/storage/');
                                          print('Alternative URL: $altUrl');
                                          print('===========================');
                                        },
                                      )
                                    : const DecorationImage(
                                        image: AssetImage('assets/images/blank-profile-circle.png'),
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        );
                      },
                    ),
                    // Edit button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: AppColors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // User name - centered and prominent
                Text(
                  _user?.name ?? "Nama Pengguna",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Contact information
                Text(
                  _user?.email ?? "pengguna@contoh.com",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _user?.position ?? "Jabatan",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account section title
          const Text(
            'Account',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          // Account options list
          Column(
            children: [
              // _buildAccountOption(
              //   title: 'Jabatan',
              //   onTap: () {
              //     // Navigate to position page
              //     _showComingSoon(context);
              //   },
              // ),
              // _buildAccountOption(
              //   title: 'Perangkat Terdaftar',
              //   onTap: () {
              //     // Navigate to registered devices page
              //     _showComingSoon(context);
              //   },
              // ),
              _buildAccountOption(
                title: 'Keluar',
                onTap: () {
                  // Show logout confirmation
                  _showLogoutConfirmation(context);
                },
                showDivider: false,
                textColor: AppColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Show image picker options (Camera or Gallery)
  void _showImagePickerOptions() {
    final profileBloc = context.read<ProfileBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(modalContext);
                      _pickImage(ImageSource.camera, profileBloc);
                    },
                  ),
                  _buildImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(modalContext);
                      _pickImage(ImageSource.gallery, profileBloc);
                    },
                  ),
                  if (_user?.imageUrl != null)
                    _buildImagePickerOption(
                      icon: Icons.delete,
                      label: 'Delete',
                      onTap: () {
                        Navigator.pop(modalContext);
                        _deleteProfileImage(profileBloc);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source, ProfileBloc profileBloc) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        
        // Check file size (limit to 2MB to match backend validation)
        final int fileSizeInBytes = await imageFile.length();
        const int maxSizeInBytes = 2 * 1024 * 1024; // 2MB
        
        if (fileSizeInBytes > maxSizeInBytes) {
          _showImageSizeWarning();
          return;
        }

        // Show preview first
        setState(() {
          _selectedImage = imageFile;
        });

        // Upload to backend
        profileBloc.add(
          ProfileEvent.uploadProfileImage(imageFile.path),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  // Delete profile image
  void _deleteProfileImage(ProfileBloc profileBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Hapus Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus foto profil? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                profileBloc.add(
                  const ProfileEvent.deleteProfileImage(),
                );
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show image size warning popup
  void _showImageSizeWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Gambar Terlalu Besar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          content: const Text(
            'Gambar yang dipilih terlalu besar. Silakan pilih gambar yang lebih kecil dari 2MB untuk performa yang lebih baik.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build account option item
  Widget _buildAccountOption({
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
    Color? textColor,
    Color? iconColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? AppColors.black,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: iconColor ?? AppColors.grey,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            color: AppColors.light,
          ),
      ],
    );
  }

  // Show coming soon dialog
  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Segera Hadir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          content: const Text(
            'Fitur ini sedang dalam pengembangan dan akan segera hadir.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout,
                color: AppColors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<LogoutBloc>().add(const LogoutEvent.logout());
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
