class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Scheduled notifications storage (in-memory for demo)
  final Map<int, ScheduledNotification> _scheduledNotifications = {};
  bool _isInitialized = false;

  Future<void> initializeNotifications() async {
    if (_isInitialized) return;
    _isInitialized = true;
    print('✅ Notification Service Initialized');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required dynamic id,
  }) async {
    // For now, just log to console
    print('📢 NOTIFICATION: $title\n   $body');
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required dynamic id,
    required DateTime scheduledDate,
  }) async {
    // Store notification in memory for tracking
    final notificationId = id is int ? id : 0;
    _scheduledNotifications[notificationId] = ScheduledNotification(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
    final timeUntil = scheduledDate.difference(DateTime.now());
    print('⏰ SCHEDULED NOTIFICATION: $title\n   Scheduled for: ${scheduledDate.toString()}\n   Time until: ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m');
  }

  Future<void> cancelNotification(dynamic id) async {
    final notificationId = id is int ? id : 0;
    _scheduledNotifications.remove(notificationId);
    print('❌ CANCELLED NOTIFICATION: $id');
  }

  Future<void> cancelAllNotifications() async {
    _scheduledNotifications.clear();
    print('❌ CANCELLED ALL NOTIFICATIONS');
  }

  List<ScheduledNotification> getScheduledNotifications() {
    return _scheduledNotifications.values.toList();
  }
}

class ScheduledNotification {
  final String title;
  final String body;
  final DateTime scheduledDate;

  ScheduledNotification({
    required this.title,
    required this.body,
    required this.scheduledDate,
  });
}
