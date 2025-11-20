import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/class_provider.dart';
import '../providers/course_provider.dart';
import '../models/class_model.dart';
import '../core/constants/app_colors.dart';
import '../widgets/drawer_widget.dart';

class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  late String _selectedDay;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedDay = daysOfWeek[0];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ClassProvider>(context, listen: false);
      provider.loadClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F8),
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: (isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F8)).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.grey[200] : Colors.grey[800], size: 28),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Schedule',
          style: TextStyle(
            color: isDark ? Colors.grey[200] : Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Day Selector Tabs
          Container(
            color: isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: daysOfWeek.map((day) {
                  final isSelected = _selectedDay == day;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 5,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? Colors.grey[600] : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
          // Timeline
          Expanded(
            child: Consumer<ClassProvider>(
              builder: (context, provider, _) {
                final classes = provider.getClassesForDay(_selectedDay);

                if (classes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No classes on $_selectedDay',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        ...classes.map((classSession) {
                          return _buildClassCard(context, classSession, isDark);
                        }).toList(),
                        const SizedBox(height: 100), // Bottom padding for FAB
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddClassDialog(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassSession classSession, bool isDark) {
    // Generate a color for the class based on courseName hash
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF472B6), // Pink
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Rose
    ];
    final colorIndex = classSession.courseName.hashCode.abs() % colors.length;
    final classColor = colors[colorIndex];

    return GestureDetector(
      onLongPress: () => _showClassOptions(context, classSession),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: classColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: classColor.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classSession.courseName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: classColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        classSession.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: classColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    '${classSession.startTime} - ${classSession.endTime}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: classColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    final _locationController = TextEditingController();
    final _startTimeNotifier = ValueNotifier<String>('09:00');
    final _endTimeNotifier = ValueNotifier<String>('10:00');
    final _selectedDayNotifier = ValueNotifier<String>(_selectedDay);
    final _selectedCourseId = ValueNotifier<int?>(null);
    final _selectedCourseName = ValueNotifier<String?>('Select Course');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF201933),
          title: const Text(
            'Add New Class',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Name',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                // Course Selection Button
                if (courseProvider.courses.isNotEmpty)
                  ValueListenableBuilder<String?>(
                    valueListenable: _selectedCourseName,
                    builder: (context, selectedName, _) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF151022),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFF201933),
                                title: const Text(
                                  'Select Course',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: courseProvider.courses.map((course) {
                                      return ListTile(
                                        title: Text(
                                          course.name,
                                          style: const TextStyle(color: Colors.white),
                                        ),
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
                        child: Text(
                          selectedName ?? 'Select Course',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151022),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[600]!),
                    ),
                    child: Text(
                      'No courses available. Add a course first.',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Day of the Week',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: _selectedDayNotifier,
                  builder: (context, selectedDay, _) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                          final isSelected = selectedDay == day;
                          return GestureDetector(
                            onTap: () => _selectedDayNotifier.value = day,
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF7f55f1) : const Color(0xFF2d2348),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(
                                day,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<String>(
                            valueListenable: _startTimeNotifier,
                            builder: (context, startTime, _) {
                              return GestureDetector(
                                onTap: () => _showTimePicker(context, _startTimeNotifier),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF151022),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF403267)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Text(
                                    startTime,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Time',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<String>(
                            valueListenable: _endTimeNotifier,
                            builder: (context, endTime, _) {
                              return GestureDetector(
                                onTap: () => _showTimePicker(context, _endTimeNotifier),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF151022),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF403267)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Text(
                                    endTime,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Classroom / Location',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. Room 404, Building B',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF151022),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF403267)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF403267)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (_selectedCourseName.value != null &&
                    _selectedCourseName.value != 'Select Course' &&
                    _locationController.text.isNotEmpty) {
                  final newClass = ClassSession(
                    courseId: _selectedCourseId.value,
                    courseName: _selectedCourseName.value!,
                    dayOfWeek: _selectedDayNotifier.value,
                    startTime: _startTimeNotifier.value,
                    endTime: _endTimeNotifier.value,
                    location: _locationController.text,
                  );
                  classProvider.addClass(newClass);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class added successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Add Class', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showTimePicker(BuildContext context, ValueNotifier<String> timeNotifier) {
    showDialog(
      context: context,
      builder: (context) {
        int hour = int.parse(timeNotifier.value.split(':')[0]);
        int minute = int.parse(timeNotifier.value.split(':')[1]);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF201933),
              title: const Text(
                'Select Time',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Hours
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              hour = (hour + 1) % 24;
                            });
                          },
                          icon: const Icon(Icons.arrow_upward, color: Colors.white),
                        ),
                        Text(
                          hour.toString().padLeft(2, '0'),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              hour = (hour - 1 + 24) % 24;
                            });
                          },
                          icon: const Icon(Icons.arrow_downward, color: Colors.white),
                        ),
                      ],
                    ),
                    const Text(':', style: TextStyle(color: Colors.white, fontSize: 24)),
                    // Minutes
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              minute = (minute + 5) % 60;
                            });
                          },
                          icon: const Icon(Icons.arrow_upward, color: Colors.white),
                        ),
                        Text(
                          minute.toString().padLeft(2, '0'),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              minute = (minute - 5 + 60) % 60;
                            });
                          },
                          icon: const Icon(Icons.arrow_downward, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    timeNotifier.value =
                        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                    Navigator.pop(context);
                  },
                  child: const Text('Set', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showClassOptions(BuildContext context, ClassSession classSession) {
    final provider = Provider.of<ClassProvider>(context, listen: false);

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
                  // TODO: Implement edit
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit not yet implemented')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  provider.deleteClass(classSession.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class deleted')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
