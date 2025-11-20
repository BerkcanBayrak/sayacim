import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import 'course_detail_screen.dart';
import '../widgets/add_course_sheet.dart';
import '../widgets/drawer_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to load data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF112117) : const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: Text(
          'Derslerim',
          style: TextStyle(
            color: isDark ? Colors.grey[200] : Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF112117) : const Color(0xFFF6F8F6),
        elevation: 0,
        centerTitle: true,
      ),
      drawer: const DrawerWidget(),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.courses.isEmpty) {
            return Center(
              child: Text(
                'Henüz ders eklenmedi.',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
            itemCount: provider.courses.length,
            itemBuilder: (context, index) {
              final course = provider.courses[index];
              final courseAverage = provider.calculateCourseAverage(course.id!);

              return Card(
                color: isDark ? const Color(0xFF1A2C22) : Colors.white,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailScreen(course: course),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(int.parse("0xFF${course.colorHex}")),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${course.credit} Kredi  •  Hedef: ${course.targetGrade.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 35.0,
                          lineWidth: 8.0,
                          percent: courseAverage / 100,
                          center: Text(
                            courseAverage.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.grey[200] : Colors.grey[800],
                            ),
                          ),
                          progressColor: Color(int.parse("0xFF${course.colorHex}")),
                          backgroundColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddCourseSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
