import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/exam_model.dart';
import '../providers/course_provider.dart';
import '../services/notification_service.dart';
import '../widgets/drawer_widget.dart';

class ExamScheduleScreen extends StatefulWidget {
  const ExamScheduleScreen({super.key});

  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  bool _notificationsEnabled = false;
  final NotificationService _notificationService = NotificationService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CourseProvider>(context, listen: false);
      provider.loadCourses(); // Load courses for the exams
      // Initialize notifications
      _notificationService.initializeNotifications();
    });
  }

  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });

    if (_notificationsEnabled) {
      _sendNotificationsForUpcomingExams();
    } else {
      _notificationService.cancelAllNotifications();
    }
  }

  void _sendNotificationsForUpcomingExams() {
    final provider = Provider.of<CourseProvider>(context, listen: false);
    final now = DateTime.now();
    final twentyFourHoursFromNow = now.add(const Duration(hours: 24));

    // Get all scheduled exams
    final exams = <Exam>[];
    for (var course in provider.courses) {
      final courseExams = provider.examsForCourse(course.id!);
      exams.addAll(courseExams.where((e) => e.isScheduled));
    }

    // Filter exams within 24 hours
    final upcomingExams = exams.where((exam) {
      return exam.dateTime.isAfter(now) &&
          exam.dateTime.isBefore(twentyFourHoursFromNow);
    }).toList();

    if (upcomingExams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No exams within 24 hours'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Schedule notifications for each upcoming exam
    for (int i = 0; i < upcomingExams.length; i++) {
      final exam = upcomingExams[i];
      _notificationService.scheduleNotification(
        title: 'Sınav Hatırlatması',
        body: '${exam.name} sınavı ${_formatDateTime(exam.dateTime)} saatinde!',
        id: exam.id ?? i,
        scheduledDate: exam.dateTime.subtract(const Duration(hours: 1)),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notifications enabled! ${upcomingExams.length} exam(s) within 24 hours',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pastelMint = const Color(0xFFB7E4C7);
    final pastelLavender = const Color(0xFFC7CEEA);
    final pastelPeach = const Color(0xFFFFDAB9);
    final pastelList = [pastelMint, pastelLavender, pastelPeach];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF112117) : const Color(0xFFF8F9FA),
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: (isDark ? const Color(0xFF112117) : const Color(0xFFF8F9FA)).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.grey[200] : Colors.grey[800], size: 28),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Sınav Takvimi',
          style: TextStyle(
            color: isDark ? Colors.grey[200] : Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: isDark ? Colors.grey[200] : Colors.grey[700]),
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _notificationsEnabled ? Icons.notifications_active : Icons.notifications,
              color: _notificationsEnabled 
                ? (isDark ? Colors.blue[300] : Colors.blue[600])
                : (isDark ? Colors.grey[200] : Colors.grey[700]),
            ),
            onPressed: _toggleNotifications,
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          // Get all scheduled exams from all courses
          final exams = <Exam>[];
          for (var course in provider.courses) {
            final courseExams = provider.examsForCourse(course.id!);
            // Only add exams that are scheduled (not just grades from Course Detail)
            exams.addAll(courseExams.where((e) => e.isScheduled));
          }
          exams.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          
          return Stack(
            children: [
              if (exams.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Sınav Yok', style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 8),
                      Text('İlk sınava eklemek için + butonuna tıkla.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListView.builder(
                    itemCount: exams.length,
                    padding: const EdgeInsets.only(top: 16, bottom: 120),
                    itemBuilder: (context, i) {
                      final exam = exams[i];
                      final iconColor = pastelList[i % pastelList.length];
                      final now = DateTime.now();
                      final diff = exam.dateTime.difference(now);
                      final days = diff.inDays >= 0 ? diff.inDays : 0;
                      final hours = diff.inHours >= 0 ? diff.inHours % 24 : 0;
                      final mins = diff.inMinutes >= 0 ? diff.inMinutes % 60 : 0;
                      
                      return Consumer<CourseProvider>(
                        builder: (context, courseProvider, _) {
                          // Get the current exam state from provider to ensure we have the latest isCompleted value
                          final currentExam = courseProvider.examsForCourse(exam.courseId).firstWhere(
                            (e) => e.id == exam.id,
                            orElse: () => exam,
                          );
                          
                          return Stack(
                            children: [
                              GestureDetector(
                                onLongPress: () => _showExamOptions(context, currentExam, provider),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Icon circle (no icon inside)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: iconColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Card
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF112117) : Colors.white,
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(
                                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          currentExam.name,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: isDark ? Colors.grey[200] : Colors.grey[800],
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Text(
                                                          currentExam.description,
                                                          style: TextStyle(
                                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          _formatDateTime(currentExam.dateTime),
                                                          style: TextStyle(
                                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        Text(
                                                          currentExam.location,
                                                          style: TextStyle(
                                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  _CountdownBox(label: 'Days', value: days.toString().padLeft(2, '0'), isDark: isDark),
                                                  const SizedBox(width: 8),
                                                  _CountdownBox(label: 'Hours', value: hours.toString().padLeft(2, '0'), isDark: isDark),
                                                  const SizedBox(width: 8),
                                                  _CountdownBox(label: 'Mins', value: mins.toString().padLeft(2, '0'), isDark: isDark),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              // FAB
              Positioned(
                bottom: 100,
                right: 24,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: () => _showAddOrEditExamDialog(context),
                  child: const Icon(Icons.add, size: 32),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddOrEditExamDialog(BuildContext context, {Exam? exam}) {
    final provider = Provider.of<CourseProvider>(context, listen: false);
    final _descController = TextEditingController(text: exam?.description ?? '');
    final _date = ValueNotifier<DateTime>(exam?.dateTime ?? DateTime.now());
    final _isCompleted = ValueNotifier<bool>(exam?.isCompleted ?? false);
    final _selectedCourseId = ValueNotifier<int?>(exam?.courseId);
    
    String? initialCourseName;
    if (exam != null) {
      try {
        initialCourseName = provider.courses.firstWhere((c) => c.id == exam.courseId).name;
      } catch (e) {
        initialCourseName = null;
      }
    }
    
    final _selectedCourseName = ValueNotifier<String?>(initialCourseName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(exam == null ? 'S\u0131nav Ekle' : 'S\u0131nav D\u00fczenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Course Selection Button (replaces dropdown)
                if (provider.courses.isNotEmpty)
                  ValueListenableBuilder<String?>(
                    valueListenable: _selectedCourseName,
                    builder: (context, selectedName, _) {
                      return ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text('Dersi Se\u00e7'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: provider.courses.map((course) {
                                      return ListTile(
                                        title: Text(course.name),
                                        onTap: () {
                                          _selectedCourseId.value = course.id;
                                          _selectedCourseName.value = course.name;
                                          Navigator.pop(ctx);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Text(selectedName ?? 'Ders Se\u00e7'),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Tan\u0131m'),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<DateTime>(
                  valueListenable: _date,
                  builder: (context, value, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text('Tarih: ${_formatDate(value)}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: value,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              _date.value = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                value.hour,
                                value.minute,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                ValueListenableBuilder<DateTime>(
                  valueListenable: _date,
                  builder: (context, value, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text('Saat: ${_formatTime(value)}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(value),
                            );
                            if (picked != null) {
                              _date.value = DateTime(
                                value.year,
                                value.month,
                                value.day,
                                picked.hour,
                                picked.minute,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                Row(
                  children: [
                    const Text('Tamamland\u0131'),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isCompleted,
                      builder: (context, value, _) {
                        return Switch(
                          value: value,
                          onChanged: (val) => _isCompleted.value = val,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_selectedCourseId.value == null) {
                  // Show an error if no course is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a course first.')),
                  );
                  return;
                }
                // Get course name for exam name
                final course = provider.courses.firstWhere((c) => c.id == _selectedCourseId.value);
                final newExam = Exam(
                  id: exam?.id,
                  courseId: _selectedCourseId.value!,
                  name: course.name,
                  weight: 0,
                  grade: null,
                  dateTime: _date.value,
                  description: _descController.text,
                  location: '',
                  isCompleted: _isCompleted.value,
                  isScheduled: true,
                );
                if (exam == null) {
                  await provider.addExam(newExam);
                } else {
                  await provider.updateExam(newExam);
                }
                Navigator.pop(context);
              },
              child: Text(exam == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _showExamOptions(BuildContext context, Exam exam, CourseProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddOrEditExamDialog(context, exam: exam);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  await provider.deleteExam(exam.id!, exam.courseId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${_formatDate(dt)} @ ${_formatTime(dt)}';
  }
  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _CountdownBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _CountdownBox({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF23272F) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
