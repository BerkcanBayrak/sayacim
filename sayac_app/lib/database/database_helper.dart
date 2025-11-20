import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/course_model.dart';
import '../models/exam_model.dart';
import '../models/class_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'grade_tracker.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE exams ADD COLUMN is_scheduled INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 3) {
      // Create class_sessions table for weekly schedule
      await db.execute('''
        CREATE TABLE IF NOT EXISTS class_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          course_id INTEGER NOT NULL,
          course_name TEXT NOT NULL,
          day_of_week TEXT NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          location TEXT NOT NULL,
          color TEXT,
          FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        credit INTEGER NOT NULL,
        target_grade REAL NOT NULL,
        color_hex TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        weight INTEGER NOT NULL,
        grade REAL,
        date_time TEXT NOT NULL,
        description TEXT,
        location TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        is_scheduled INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE class_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        course_name TEXT NOT NULL,
        day_of_week TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        location TEXT NOT NULL,
        color TEXT,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertCourse(Course course) async {
    final db = await database;
    return await db.insert('courses', course.toMap());
  }

  Future<List<Course>> getCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  Future<int> updateCourse(Course course) async {
    final db = await database;
    return await db.update('courses', course.toMap(), where: 'id = ?', whereArgs: [course.id]);
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertExam(Exam exam) async {
    final db = await database;
    return await db.insert('exams', exam.toMap());
  }

  Future<List<Exam>> getExams(int courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exams', where: 'course_id = ?', whereArgs: [courseId]);
    return List.generate(maps.length, (i) {
      return Exam.fromMap(maps[i]);
    });
  }

  // Tüm sınavları getir (takvim için)
  Future<List<Exam>> getAllExams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exams');
    return List.generate(maps.length, (i) {
      return Exam.fromMap(maps[i]);
    });
  }

  Future<int> updateExam(Exam exam) async {
    final db = await database;
    return await db.update('exams', exam.toMap(), where: 'id = ?', whereArgs: [exam.id]);
  }

  // Sınavı tamamlandı olarak güncelle
  Future<int> updateExamCompleted(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'exams',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExam(int id) async {
    final db = await database;
    return await db.delete('exams', where: 'id = ?', whereArgs: [id]);
  }

  // Class Sessions CRUD operations
  Future<int> insertClassSession(ClassSession classSession) async {
    final db = await database;
    try {
      return await db.insert('class_sessions', {
        'course_id': classSession.courseId,
        'course_name': classSession.courseName,
        'day_of_week': classSession.dayOfWeek,
        'start_time': classSession.startTime,
        'end_time': classSession.endTime,
        'location': classSession.location,
        'color': classSession.color,
      });
    } catch (e) {
      // If foreign key constraint fails, insert with NULL course_id
      return await db.insert('class_sessions', {
        'course_id': null,
        'course_name': classSession.courseName,
        'day_of_week': classSession.dayOfWeek,
        'start_time': classSession.startTime,
        'end_time': classSession.endTime,
        'location': classSession.location,
        'color': classSession.color,
      });
    }
  }

  Future<List<ClassSession>> getClassSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('class_sessions');
    return List.generate(maps.length, (i) {
      return ClassSession.fromMap(maps[i]);
    });
  }

  Future<List<ClassSession>> getClassSessionsByDay(String dayOfWeek) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'class_sessions',
      where: 'day_of_week = ?',
      whereArgs: [dayOfWeek],
      orderBy: 'start_time ASC',
    );
    return List.generate(maps.length, (i) {
      return ClassSession.fromMap(maps[i]);
    });
  }

  Future<int> updateClassSession(ClassSession classSession) async {
    final db = await database;
    return await db.update(
      'class_sessions',
      {
        'course_id': classSession.courseId,
        'course_name': classSession.courseName,
        'day_of_week': classSession.dayOfWeek,
        'start_time': classSession.startTime,
        'end_time': classSession.endTime,
        'location': classSession.location,
        'color': classSession.color,
      },
      where: 'id = ?',
      whereArgs: [classSession.id],
    );
  }

  Future<int> deleteClassSession(int id) async {
    final db = await database;
    return await db.delete('class_sessions', where: 'id = ?', whereArgs: [id]);
  }
}
