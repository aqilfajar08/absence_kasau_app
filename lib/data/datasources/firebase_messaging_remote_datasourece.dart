import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/data/datasources/auth_remote_datasource.dart';

// Top-level background handler function - MUST be outside the class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('🌙 Background message received:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Topic: ${message.data['topic'] ?? 'No topic'}');
    print('   Data: ${message.data}');
  }

  // Don't show local notification for FCM messages to avoid duplicates
  // Firebase will automatically display the notification in background
  // Only log the message for debugging purposes
}

class FirebaseMessagingRemoteDatasource {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
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
      print('🔐 Notification permission status: ${settings.authorizationStatus}');
      print('🔐 Alert enabled: ${settings.alert}');
      print('🔐 Badge enabled: ${settings.badge}');
      print('🔐 Sound enabled: ${settings.sound}');
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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});

    final fcmToken = await _firebaseMessaging.getToken();

    if (kDebugMode) {
      print('🔑 FCM Token: $fcmToken');
    }

    // Update FCM token on server if user is authenticated
    if (await AuthLocalDatasource().getAuthData() != null) {
      AuthRemoteDatasource().updateFcmToken(fcmToken!);
    }

    // Subscribe to general topics for auto-send notifications
    await _subscribeToGeneralTopics();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('🔄 FCM Token refreshed: $newToken');
      }
      // TODO: Send new token to your server
      // await _updateTokenOnServer(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print('📱 Foreground message received:');
        print('   Title: ${message.notification?.title}');
        print('   Body: ${message.notification?.body}');
        print('   Topic: ${message.data['topic'] ?? 'No topic'}');
        print('   Data: ${message.data}');
      }
      
      // Show local notification for foreground messages since Firebase won't auto-display them
      if (message.notification != null) {
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
        print('🚀 App opened from notification:');
        print('   Title: ${message.notification?.title}');
        print('   Body: ${message.notification?.body}');
        print('   Topic: ${message.data['topic'] ?? 'No topic'}');
        print('   Data: ${message.data}');
      }
    });

    // Get initial message if app was opened from notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('🚀 App opened from initial notification:');
        print('   Title: ${initialMessage.notification?.title}');
        print('   Body: ${initialMessage.notification?.body}');
        print('   Topic: ${initialMessage.data['topic'] ?? 'No topic'}');
        print('   Data: ${initialMessage.data}');
      }
    }
  }

  // Use this method for custom app notifications and FCM foreground messages
  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'com.example.absence_kasau_app', 'app',
            importance: Importance.max),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Test method to verify notifications are working
  Future<void> testNotification() async {
    try {
      await showNotification(
        title: 'Test Notification',
        body: 'This is a test notification to verify the system is working',
        payLoad: 'test',
      );
      if (kDebugMode) {
        print('✅ Test notification sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending test notification: $e');
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
        print('✅ Subscribed to topics: general, all_users, notifications, broadcast');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subscribing to topics: $e');
      }
    }
  }

  // Method to subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subscribing to topic $topic: $e');
      }
    }
  }

  // Method to unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unsubscribing from topic $topic: $e');
      }
    }
  }

  // Method to get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting FCM token: $e');
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
        print('❌ Error checking notification status: $e');
      }
      return false;
    }
  }

  // Comprehensive debug method to test FCM functionality
  Future<Map<String, dynamic>> debugFCMStatus() async {
    final Map<String, dynamic> debugInfo = {};
    
    try {
      if (kDebugMode) {
        print('🔍 Starting FCM debug diagnostics...');
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
        print('🔍 FCM Debug Info:');
        print('   Token: ${debugInfo['fcm_token']}');
        print('   Has Token: ${debugInfo['has_token']}');
        print('   Notifications Enabled: ${debugInfo['notifications_enabled']}');
        print('   Authorization Status: ${debugInfo['authorization_status']}');
        print('   Local Notification Test: ${debugInfo['local_notification_test']}');
      }

    } catch (e) {
      debugInfo['error'] = e.toString();
      if (kDebugMode) {
        print('❌ Error during FCM debug: $e');
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
        print('✅ Configured Firebase notification presentation options');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configuring Firebase notification settings: $e');
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
      print('✅ Created app notification channel: ${appChannel.id}');
      print('✅ Created FCM notification channel: ${fcmChannel.id}');
      print('✅ Created default notification channel: ${defaultChannel.id}');
      print('✅ Created Firebase default channel: ${firebaseChannel.id}');
      print('✅ Created Firebase default channel: ${firebaseDefaultChannel.id}');
    }
  }
}