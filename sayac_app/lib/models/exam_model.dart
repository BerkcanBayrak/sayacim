class Exam {
  final int? id;
  final int courseId;
  final String name;
  final int weight;
  final double? grade;
  final DateTime dateTime;
  final String description;
  final String location;
  final bool isCompleted;
  final bool isScheduled;

  Exam({
    this.id,
    required this.courseId,
    required this.name,
    required this.weight,
    this.grade,
    required this.dateTime,
    required this.description,
    required this.location,
    this.isCompleted = false,
    this.isScheduled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'name': name,
      'weight': weight,
      'grade': grade,
      'date_time': dateTime.toIso8601String(),
      'description': description,
      'location': location,
      'is_completed': isCompleted ? 1 : 0,
      'is_scheduled': isScheduled ? 1 : 0,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      courseId: map['course_id'],
      name: map['name'],
      weight: map['weight'],
      grade: map['grade'],
      dateTime: DateTime.parse(map['date_time']),
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      isCompleted: (map['is_completed'] ?? 0) == 1,
      isScheduled: (map['is_scheduled'] ?? 0) == 1,
    );
  }
}
