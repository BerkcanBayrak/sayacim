class Course {
  final int? id;
  final String name;
  final int credit;
  final double targetGrade;
  final String colorHex;

  Course({
    this.id,
    required this.name,
    required this.credit,
    required this.targetGrade,
    required this.colorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'credit': credit,
      'target_grade': targetGrade,
      'color_hex': colorHex,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      credit: map['credit'],
      targetGrade: map['target_grade'],
      colorHex: map['color_hex'],
    );
  }
}
