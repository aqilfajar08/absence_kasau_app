import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/data/datasources/auth_remote_datasource.dart';
import 'package:absence_kasau_app/data/models/notification_model.dart';
import 'package:absence_kasau_app/data/services/notification_service.dart';
import 'package:absence_kasau_app/data/services/notification_stream_service.dart';

// Top-level background handler function - MUST be outside the class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    debugPrint('🌙 Background message received:');
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');
    debugPrint('   Topic: ${message.data['topic'] ?? 'No topic'}');
    debugPrint('   Data: ${message.data}');
  }

  // Save notification to local storage even in background
  if (message.notification != null) {
    await _saveNotificationToLocalStatic(message);
    // Notify stream service about new notification
    await NotificationStreamService().onNotificationAdded();
  }
}

class FirebaseMessagingRemoteDatasource {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('🚀 Initializing Firebase Messaging...');
    }
    
    // Request notification permissions with additional settings
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('🔐 Notification permission status: ${settings.authorizationStatus}');
      debugPrint('🔐 Alert enabled: ${settings.alert}');
      debugPrint('🔐 Badge enabled: ${settings.badge}');
      debugPrint('🔐 Sound enabled: ${settings.sound}');
      debugPrint('🔐 Announcement enabled: ${settings.announcement}');
    }

    // Create notification channels for Android (required for FCM to work properly)
    await _createNotificationChannels();

    // Configure Firebase notification settings for better display
    await _configureFirebaseNotificationSettings();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    
    if (kDebugMode) {
      debugPrint('🔧 Initializing local notifications plugin...');
    }
    
    final bool? initialized = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (kDebugMode) {
          debugPrint('📱 Notification tapped: ${notificationResponse.payload}');
        }
      }
    );
    
    if (kDebugMode) {
      debugPrint('🔧 Local notifications initialized: $initialized');
    }

    final fcmToken = await _firebaseMessaging.getToken();

    if (kDebugMode) {
      debugPrint('🔑 FCM Token: $fcmToken');
    }

    // Update FCM token on server if user is authenticated
    if (await AuthLocalDatasource().getAuthData() != null) {
      AuthRemoteDatasource().updateFcmToken(fcmToken!);
    }

    // Subscribe to general topics for auto-send notifications
    await _subscribeToGeneralTopics();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
      }
      // Send new token to your server
      await _updateTokenOnServer(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) async {
      if (kDebugMode) {
        debugPrint('📱 Foreground message received:');
        debugPrint('   Title: ${message.notification?.title}');
        debugPrint('   Body: ${message.notification?.body}');
        debugPrint('   Topic: ${message.data['topic'] ?? 'No topic'}');
        debugPrint('   Data: ${message.data}');
      }
      
      // Save notification to local storage
      if (message.notification != null) {
        _saveNotificationToLocal(message);
        
        // Notify stream service about new notification
        await NotificationStreamService().onNotificationAdded();
        
        // Show local notification for foreground messages since Firebase won't auto-display them
        showNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          payLoad: message.data.toString(),
        );
      }
    });

    // Handle background messages - now using top-level function
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        debugPrint('🚀 App opened from notification:');
        debugPrint('   Title: ${message.notification?.title}');
        debugPrint('   Body: ${message.notification?.body}');
        debugPrint('   Topic: ${message.data['topic'] ?? 'No topic'}');
        debugPrint('   Data: ${message.data}');
      }
      
      // Save notification to local storage when app is opened from notification
      if (message.notification != null) {
        _saveNotificationToLocal(message);
        // Notify stream service about new notification
        NotificationStreamService().onNotificationAdded();
      }
    });

    // Get initial message if app was opened from notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        debugPrint('🚀 App opened from initial notification:');
        debugPrint('   Title: ${initialMessage.notification?.title}');
        debugPrint('   Body: ${initialMessage.notification?.body}');
        debugPrint('   Topic: ${initialMessage.data['topic'] ?? 'No topic'}');
        debugPrint('   Data: ${initialMessage.data}');
      }
      
      // Save initial notification to local storage
      if (initialMessage.notification != null) {
        _saveNotificationToLocal(initialMessage);
        // Notify stream service about new notification
        NotificationStreamService().onNotificationAdded();
      }
    }
  }

  // Use this method for custom app notifications and FCM foreground messages
  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    // Check if notifications are enabled before showing
    final areEnabled = await areNotificationsEnabled();
    if (!areEnabled) {
      if (kDebugMode) {
        debugPrint('❌ Notifications are disabled, cannot show notification');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('📱 Showing notification: $title - $body');
    }

    return flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'high_importance_channel', 'High Importance Notifications',
            channelDescription: 'Channel for important notifications including FCM',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            showWhen: true,
            icon: '@mipmap/ic_launcher'),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Test method to verify notifications are working
  Future<void> testNotification() async {
    try {
      if (kDebugMode) {
        debugPrint('🧪 Starting notification test...');
      }
      
      // Check notification permissions first
      final areEnabled = await areNotificationsEnabled();
      if (kDebugMode) {
        debugPrint('🔐 Notifications enabled: $areEnabled');
      }
      
      if (!areEnabled) {
        if (kDebugMode) {
          debugPrint('❌ Notifications are disabled. Requesting permissions...');
        }
        // Try to request permissions again
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          announcement: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
        );
        
        if (kDebugMode) {
          debugPrint('🔐 Permission request result: ${settings.authorizationStatus}');
        }
        
        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          if (kDebugMode) {
            debugPrint('❌ Permission still not granted. User needs to enable notifications in device settings.');
          }
          return;
        }
      }
      
      // Test local notification directly
      if (kDebugMode) {
        debugPrint('📱 Attempting to show test notification...');
      }
      
      await showNotification(
        title: 'Notifikasi Uji Coba',
        body: 'Ini adalah notifikasi uji coba untuk memverifikasi sistem berfungsi',
        payLoad: 'test',
      );
      
      if (kDebugMode) {
        debugPrint('✅ Notifikasi uji coba berhasil dikirim');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gagal mengirim notifikasi uji coba: $e');
        debugPrint('❌ Error details: ${e.toString()}');
      }
    }
  }

  // Enhanced debug method to check all notification settings
  Future<Map<String, dynamic>> debugNotificationSettings() async {
    final Map<String, dynamic> debugInfo = {};
    
    try {
      if (kDebugMode) {
        debugPrint('🔍 Starting comprehensive notification debug...');
      }

      // Check Firebase messaging permissions
      final settings = await _firebaseMessaging.getNotificationSettings();
      debugInfo['firebase_authorization_status'] = settings.authorizationStatus.toString();
      debugInfo['firebase_alert'] = settings.alert;
      debugInfo['firebase_badge'] = settings.badge;
      debugInfo['firebase_sound'] = settings.sound;

      // Check FCM token
      final token = await _firebaseMessaging.getToken();
      debugInfo['fcm_token'] = token;
      debugInfo['has_fcm_token'] = token != null && token.isNotEmpty;

      // Check user authentication and topics
      final authData = await AuthLocalDatasource().getAuthData();
      if (authData != null && authData.user != null) {
        debugInfo['user_id'] = authData.user!.id;
        debugInfo['user_email'] = authData.user!.email;
        debugInfo['user_topics'] = [
          'user_${authData.user!.id}',
          'permissions_${authData.user!.id}',
          'izin_${authData.user!.id}',
          'general',
          'all_users',
          'notifications',
          'broadcast'
        ];
      } else {
        debugInfo['user_authenticated'] = false;
      }

      // Check if local notifications plugin is initialized
      try {
        final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
        debugInfo['local_notifications_initialized'] = true;
        debugInfo['pending_notifications_count'] = pendingNotifications.length;
      } catch (e) {
        debugInfo['local_notifications_initialized'] = false;
        debugInfo['local_notifications_error'] = e.toString();
      }

      // Test notification channels on Android
      if (kDebugMode) {
        final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          try {
            final channels = await androidPlugin.getNotificationChannels();
            debugInfo['notification_channels_count'] = channels?.length ?? 0;
            debugInfo['notification_channels'] = channels?.map((c) => {
              'id': c.id,
              'name': c.name,
              'importance': c.importance.toString(),
              'sound': c.sound?.toString(),
            }).toList();
          } catch (e) {
            debugInfo['channels_error'] = e.toString();
          }
        }
      }

      if (kDebugMode) {
        debugPrint('🔍 Debug Info:');
        debugInfo.forEach((key, value) {
          debugPrint('   $key: $value');
        });
      }

    } catch (e) {
      debugInfo['debug_error'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ Error during debug: $e');
      }
    }

    return debugInfo;
  }

  // Test method to add sample Izin notification
  Future<void> addSampleIzinNotification() async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Status Izin',
        body: 'Absensi Pulang dilakukan pukul 16:00 mendatang',
        type: 'izin',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        data: {'action': 'izin_reminder'},
      );
      
      await NotificationService.addNotification(notification);
      if (kDebugMode) {
        debugPrint('✅ Notifikasi Izin contoh berhasil ditambahkan');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gagal menambahkan notifikasi contoh: $e');
      }
    }
  }

  // Send notification for permission status updates
  Future<void> sendPermissionStatusNotification({
    required String status,
    required String permissionType,
    String? additionalInfo,
  }) async {
    try {
      String title = 'Status Izin';
      String body = '';
      
      switch (status.toLowerCase()) {
        case 'approved':
        case 'disetujui':
          title = 'Izin Disetujui';
          body = 'Pengajuan izin Anda telah disetujui';
          break;
        case 'rejected':
        case 'ditolak':
          title = 'Izin Ditolak';
          body = 'Pengajuan izin Anda telah ditolak';
          break;
        case 'pending':
        case 'menunggu':
          title = 'Izin Menunggu Persetujuan';
          body = 'Pengajuan izin Anda sedang menunggu persetujuan';
          break;
        default:
          title = 'Update Status Izin';
          body = 'Status pengajuan izin Anda telah diperbarui';
      }
      
      if (additionalInfo != null && additionalInfo.isNotEmpty) {
        body += '\n$additionalInfo';
      }

      // Show local notification
      await showNotification(
        title: title,
        body: body,
        payLoad: 'permission_status_$status',
      );

      // Save to local storage
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        type: 'izin',
        timestamp: DateTime.now(),
        data: {
          'action': 'permission_status',
          'status': status,
          'type': permissionType,
        },
      );
      
      await NotificationService.addNotification(notification);
      await NotificationStreamService().onNotificationAdded();
      
      if (kDebugMode) {
        debugPrint('✅ Notifikasi status izin berhasil dikirim: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gagal mengirim notifikasi status izin: $e');
      }
    }
  }

  // Remove the old background handler method since it's now top-level

  Future<void> _subscribeToGeneralTopics() async {
    try {
      // Subscribe to general topics for auto-send notifications
      await _firebaseMessaging.subscribeToTopic('general');
      await _firebaseMessaging.subscribeToTopic('all_users');
      await _firebaseMessaging.subscribeToTopic('notifications');
      await _firebaseMessaging.subscribeToTopic('broadcast');
      
      if (kDebugMode) {
        debugPrint('✅ Subscribed to topics: general, all_users, notifications, broadcast');
      }
      
      // Subscribe to user-specific topics for permission notifications
      await _subscribeToUserSpecificTopics();
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subscribing to topics: $e');
      }
    }
  }

  // Subscribe to user-specific topics for permission notifications
  Future<void> _subscribeToUserSpecificTopics() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      if (authData != null && authData.user != null) {
        // Subscribe to user-specific topic using user ID
        final userId = authData.user!.id;
        await _firebaseMessaging.subscribeToTopic('user_$userId');
        await _firebaseMessaging.subscribeToTopic('permissions_$userId');
        await _firebaseMessaging.subscribeToTopic('izin_$userId');
        
        if (kDebugMode) {
          debugPrint('✅ Subscribed to user-specific topics: user_$userId, permissions_$userId, izin_$userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subscribing to user-specific topics: $e');
      }
    }
  }

  // Update FCM token on server when it refreshes
  Future<void> _updateTokenOnServer(String newToken) async {
    try {
      if (await AuthLocalDatasource().getAuthData() != null) {
        await AuthRemoteDatasource().updateFcmToken(newToken);
        if (kDebugMode) {
          debugPrint('✅ Updated FCM token on server');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating FCM token on server: $e');
      }
    }
  }

  // Method to subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        debugPrint('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subscribing to topic $topic: $e');
      }
    }
  }

  // Method to unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        debugPrint('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error unsubscribing from topic $topic: $e');
      }
    }
  }

  // Method to get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting FCM token: $e');
      }
      return null;
    }
  }

  // Method to check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking notification status: $e');
      }
      return false;
    }
  }

  // Comprehensive debug method to test FCM functionality
  Future<Map<String, dynamic>> debugFCMStatus() async {
    final Map<String, dynamic> debugInfo = {};
    
    try {
      if (kDebugMode) {
        debugPrint('🔍 Starting FCM debug diagnostics...');
      }

      // Check FCM token
      final token = await getCurrentToken();
      debugInfo['fcm_token'] = token;
      debugInfo['has_token'] = token != null && token.isNotEmpty;

      // Check notification permissions
      final areEnabled = await areNotificationsEnabled();
      debugInfo['notifications_enabled'] = areEnabled;

      // Check notification settings
      final settings = await _firebaseMessaging.getNotificationSettings();
      debugInfo['authorization_status'] = settings.authorizationStatus.toString();
      debugInfo['alert_enabled'] = settings.alert;
      debugInfo['badge_enabled'] = settings.badge;
      debugInfo['sound_enabled'] = settings.sound;

      // Check if app is in foreground
      debugInfo['app_in_foreground'] = true; // This method is called from UI

      // Test local notification capability
      try {
        await showNotification(
          title: 'Debug Test',
          body: 'Testing local notification capability',
          payLoad: 'debug_test',
        );
        debugInfo['local_notification_test'] = 'success';
      } catch (e) {
        debugInfo['local_notification_test'] = 'failed: $e';
      }

      if (kDebugMode) {
        debugPrint('🔍 FCM Debug Info:');
        debugPrint('   Token: ${debugInfo['fcm_token']}');
        debugPrint('   Has Token: ${debugInfo['has_token']}');
        debugPrint('   Notifications Enabled: ${debugInfo['notifications_enabled']}');
        debugPrint('   Authorization Status: ${debugInfo['authorization_status']}');
        debugPrint('   Local Notification Test: ${debugInfo['local_notification_test']}');
      }

    } catch (e) {
      debugInfo['error'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ Error during FCM debug: $e');
      }
    }

    return debugInfo;
  }

  // Configure Firebase notification settings for better display
  Future<void> _configureFirebaseNotificationSettings() async {
    try {
      // Set notification presentation options for better display
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,    // Show alert (heads-up notification)
        badge: true,    // Show badge
        sound: true,    // Play sound
      );

      if (kDebugMode) {
        debugPrint('✅ Configured Firebase notification presentation options');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error configuring Firebase notification settings: $e');
      }
    }
  }

  // Create notification channels for Android (required for FCM to work properly)
  Future<void> _createNotificationChannels() async {
    // Create channel for local app notifications
    const appChannel = AndroidNotificationChannel(
      'com.example.absence_kasau_app',
      'App Notifications',
      description: 'Channel for app notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Create the EXACT channel that Firebase uses for FCM notifications
    // This channel ID is critical for FCM to work properly
    const fcmChannel = AndroidNotificationChannel(
      'high_importance_channel', // Firebase will use this channel
      'High Importance Notifications',
      description: 'Channel for important notifications including FCM',
      importance: Importance.max, // MAX importance for heads-up notifications
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
    );

    // Create the channel that Firebase actually uses by default
    // This is the most important channel for FCM pop-up notifications
    const firebaseDefaultChannel = AndroidNotificationChannel(
      'firebase_default_channel',
      'Firebase Default Channel',
      description: 'Default Firebase notification channel for pop-up notifications',
      importance: Importance.max, // MAX importance for heads-up notifications
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
    );

    // Create a default channel that Firebase might use
    const defaultChannel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'Default notification channel',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Create the channel that matches Firebase's default behavior
    const firebaseChannel = AndroidNotificationChannel(
      'firebase_default',
      'Firebase Default',
      description: 'Default Firebase notification channel',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
    );

    // Create all channels
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(appChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(fcmChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(firebaseChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(firebaseDefaultChannel);

    if (kDebugMode) {
      debugPrint('✅ Created app notification channel: ${appChannel.id}');
      debugPrint('✅ Created FCM notification channel: ${fcmChannel.id}');
      debugPrint('✅ Created default notification channel: ${defaultChannel.id}');
      debugPrint('✅ Created Firebase default channel: ${firebaseChannel.id}');
      debugPrint('✅ Created Firebase default channel: ${firebaseDefaultChannel.id}');
    }
  }

  // Helper method to save notification to local storage
  Future<void> _saveNotificationToLocal(RemoteMessage message) async {
    try {
      final notification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        type: message.data['type'] ?? 'general',
        timestamp: DateTime.now(),
        data: message.data,
      );
      
      await NotificationService.addNotification(notification);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gagal menyimpan notifikasi ke penyimpanan lokal: $e');
      }
    }
  }
}

// Static helper method for background handler
Future<void> _saveNotificationToLocalStatic(RemoteMessage message) async {
  try {
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'general',
      timestamp: DateTime.now(),
      data: message.data,
    );
    
    await NotificationService.addNotification(notification);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Error saving notification to local storage: $e');
    }
  }
}