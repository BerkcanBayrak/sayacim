class ClassSession {
  final int? id;
  final int? courseId; // Nullable - class can exist without a linked course
  final String courseName;
  final String dayOfWeek; // Pazartesi, Salı, Çarşamba, Perşembe, Cuma, Cumartesi, Pazar
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final String location; // Classroom / Location
  final String? color; // Optional: for UI color coding

  ClassSession({
    this.id,
    this.courseId,
    required this.courseName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'course_name': courseName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'color': color,
    };
  }

  factory ClassSession.fromMap(Map<String, dynamic> map) {
    return ClassSession(
      id: map['id'],
      courseId: map['course_id'],
      courseName: map['course_name'],
      dayOfWeek: map['day_of_week'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      location: map['location'],
      color: map['color'],
    );
  }

  ClassSession copyWith({
    int? id,
    int? courseId,
    String? courseName,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    String? color,
  }) {
    return ClassSession(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      color: color ?? this.color,
    );
  }

  // Helper method to get duration in minutes
  int getDurationInMinutes() {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return endMinutes - startMinutes;
  }

  // Helper method to parse time string to DateTime
  static DateTime parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  // Get offset from top based on start time (for positioning in timeline)
  double getTopOffset() {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final totalMinutes = hour * 60 + minute;
    // 1 hour = 64px (4rem)
    return (totalMinutes / 60) * 64;
  }

  // Get height based on duration (for sizing in timeline)
  double getHeight() {
    final durationMinutes = getDurationInMinutes();
    // 1 hour = 64px (4rem)
    return (durationMinutes / 60) * 64;
  }
}
