import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../database/database_helper.dart';

class ClassProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Map<String, List<ClassSession>> _classesByDay = {
    'Mon': [],
    'Tue': [],
    'Wed': [],
    'Thu': [],
    'Fri': [],
    'Sat': [],
    'Sun': [],
  };

  Map<String, List<ClassSession>> get classesByDay => _classesByDay;

  List<ClassSession> get allClasses {
    final all = <ClassSession>[];
    _classesByDay.values.forEach((classes) => all.addAll(classes));
    return all;
  }

  Future<void> loadClasses() async {
    try {
      final sessions = await _dbHelper.getClassSessions();
      
      // Clear existing data
      _classesByDay.forEach((key, _) => _classesByDay[key] = []);
      
      // Group by day
      for (var session in sessions) {
        if (_classesByDay.containsKey(session.dayOfWeek)) {
          _classesByDay[session.dayOfWeek]!.add(session);
        }
      }
      
      // Sort each day by start time
      _classesByDay.forEach((day, classes) {
        classes.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
      
      notifyListeners();
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  List<ClassSession> getClassesForDay(String dayOfWeek) {
    return _classesByDay[dayOfWeek] ?? [];
  }

  Future<void> addClass(ClassSession classSession) async {
    try {
      final id = await _dbHelper.insertClassSession(classSession);
      final newSession = classSession.copyWith(id: id);
      
      if (_classesByDay.containsKey(classSession.dayOfWeek)) {
        _classesByDay[classSession.dayOfWeek]!.add(newSession);
        _classesByDay[classSession.dayOfWeek]!
            .sort((a, b) => a.startTime.compareTo(b.startTime));
      }
      
      notifyListeners();
    } catch (e) {
      print('Error adding class: $e');
    }
  }

  Future<void> updateClass(ClassSession classSession) async {
    try {
      await _dbHelper.updateClassSession(classSession);
      
      // Remove from old day if changed
      for (var classes in _classesByDay.values) {
        classes.removeWhere((c) => c.id == classSession.id);
      }
      
      // Add to new day
      if (_classesByDay.containsKey(classSession.dayOfWeek)) {
        _classesByDay[classSession.dayOfWeek]!.add(classSession);
        _classesByDay[classSession.dayOfWeek]!
            .sort((a, b) => a.startTime.compareTo(b.startTime));
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating class: $e');
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      await _dbHelper.deleteClassSession(id);
      
      // Remove from all days
      _classesByDay.forEach((day, classes) {
        classes.removeWhere((c) => c.id == id);
      });
      
      notifyListeners();
    } catch (e) {
      print('Error deleting class: $e');
    }
  }
}
