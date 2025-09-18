import 'package:flutter/material.dart';
import 'package:absence_kasau_app/core/core.dart';
import 'package:absence_kasau_app/data/models/notification_model.dart';
import 'package:absence_kasau_app/data/services/notification_service.dart';
import 'package:absence_kasau_app/data/services/notification_stream_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedNotifications = await NotificationService.getNotifications();
      setState(() {
        notifications = loadedNotifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await NotificationService.markAsRead(notificationId);
    // Notify stream service about notification being read
    await NotificationStreamService().onNotificationRead();
    _loadNotifications(); // Reload to update UI
  }

  Future<void> _clearAllNotifications() async {
    // Show confirmation dialog
    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Cache'),
          content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await NotificationService.clearAllNotifications();
      // Notify stream service about notifications being cleared
      await NotificationStreamService().onNotificationsCleared();
      _loadNotifications(); // Reload to show empty state
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi berhasil dihapus'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: notifications.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.clear_all,
                    color: AppColors.black,
                  ),
                  onPressed: _clearAllNotifications,
                  tooltip: 'Hapus Cache',
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bell icon with pink background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E5), // Light pink background
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 60,
                color: Color(0xFFE91E63), // Dark pink color
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Belum ada Notifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jika Anda mendapat notifikasi dari aktivitas Anda, notifikasi tersebut akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            // Back Home button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F), // Dark red
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return Column(
      children: [
        // Header with title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Notifikasi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        // Notifications list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _markAsRead(notification.id);
            // Handle notification tap based on type
            _handleNotificationTap(notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon based on type
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type label
                      Text(
                        _getNotificationTypeLabel(notification.type),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Main notification text
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: notification.isRead ? AppColors.grey : AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Time and read indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getTimeAgo(notification.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'izin':
        return const Color(0xFF4CAF50); // Green
      case 'absensi':
        return const Color(0xFF2196F3); // Blue
      default:
        return AppColors.primary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'izin':
        return Icons.event_available;
      case 'absensi':
        return Icons.access_time;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'izin':
        return 'Absensi Mendatang';
      case 'absensi':
        return 'Absensi';
      default:
        return 'Notifikasi';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
        // Handle different notification types
        switch (notification.type.toLowerCase()) {
          case 'izin':
            // Navigate to permission/izin page
            // You can implement navigation to specific pages based on notification data
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Membuka ${notification.title}'),
                backgroundColor: AppColors.primary,
              ),
            );
            break;
          default:
            // Default action
            break;
        }
  }
}
