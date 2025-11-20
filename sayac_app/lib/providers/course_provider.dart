import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/course_model.dart';
import '../models/exam_model.dart';

class CourseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Course> _courses = [];
  Map<int, List<Exam>> _examsByCourse = {};
  List<Exam> _allExams = [];

  List<Course> get courses => _courses;
  List<Exam> examsForCourse(int courseId) => _examsByCourse[courseId] ?? [];
  List<Exam> get allExams => _allExams;

  Future<void> loadCourses() async {
    _courses = await _dbHelper.getCourses();
    // Load all course exams to ensure grades are available
    for (final course in _courses) {
      if (course.id != null) {
        await loadExams(course.id!);
      }
    }
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    await _dbHelper.insertCourse(course);
    await loadCourses();
  }

  Future<void> updateCourse(Course course) async {
    await _dbHelper.updateCourse(course);
    await loadCourses();
  }

  Future<void> deleteCourse(int id) async {
    await _dbHelper.deleteCourse(id);
    _examsByCourse.remove(id);
    await loadCourses();
    await loadAllExams();
  }

  Future<void> loadExams(int courseId) async {
    _examsByCourse[courseId] = await _dbHelper.getExams(courseId);
    notifyListeners();
  }

  Future<void> addExam(Exam exam) async {
    await _dbHelper.insertExam(exam);
    await loadExams(exam.courseId);
  }

  Future<void> updateExam(Exam exam) async {
    await _dbHelper.updateExam(exam);
    await loadExams(exam.courseId);
  }

  Future<void> deleteExam(int id, int courseId) async {
    await _dbHelper.deleteExam(id);
    await loadExams(courseId);
  }

  // Tüm sınavları yükle (takvim için)
  Future<void> loadAllExams() async {
    _allExams = await _dbHelper.getAllExams();
    notifyListeners();
  }

  // Sınavı tamamlandı olarak güncelle
  Future<void> setExamCompleted(int examId, bool isCompleted) async {
    await _dbHelper.updateExamCompleted(examId, isCompleted);
    notifyListeners();
  }

  double calculateCourseAverage(int courseId) {
    final exams = examsForCourse(courseId);
    if (exams.isEmpty) return 0.0;
    double totalWeightedScore = 0;
    int totalWeightOfGradedExams = 0;
    for (final exam in exams) {
      if (exam.grade != null) {
        totalWeightedScore += exam.grade! * exam.weight;
        totalWeightOfGradedExams += exam.weight;
      }
    }
    if (totalWeightOfGradedExams == 0) return 0.0;
    return totalWeightedScore / totalWeightOfGradedExams;
  }

  double? calculateRequiredFinalGrade(int courseId) {
    final course = _courses.firstWhere((c) => c.id == courseId);
    final exams = examsForCourse(courseId);
    double currentScoreContribution = 0;
    int remainingWeight = 0;
    for (final exam in exams) {
      if (exam.grade != null) {
        currentScoreContribution += exam.grade! * (exam.weight / 100.0);
      } else {
        remainingWeight += exam.weight;
      }
    }
    if (remainingWeight == 0) {
      return null;
    }
    double neededPoints = course.targetGrade - currentScoreContribution;
    if (neededPoints <= 0) {
      return 0.0;
    }
    return neededPoints / (remainingWeight / 100.0);
  }

  // Calculate credit-weighted GPA (4.0 scale)
  double calculateWeightedGPA() {
    if (_courses.isEmpty) return 0.0;
    
    double totalWeightedGrade = 0;
    int totalCredits = 0;
    
    for (final course in _courses) {
      final courseAverage = calculateCourseAverage(course.id!);
      if (courseAverage > 0) {
        // Convert from 100 scale to 4.0 scale
        double gradeOn4Scale = (courseAverage / 100.0) * 4.0;
        // Clamp to 4.0 max
        gradeOn4Scale = gradeOn4Scale > 4.0 ? 4.0 : gradeOn4Scale;
        
        totalWeightedGrade += gradeOn4Scale * course.credit;
        totalCredits += course.credit;
      }
    }
    
    if (totalCredits == 0) return 0.0;
    return totalWeightedGrade / totalCredits;
  }
}
