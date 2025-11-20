import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../models/exam_model.dart';
import '../providers/course_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadExams(widget.course.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF112117) : const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: Text(
          widget.course.name,
          style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
        ),
        backgroundColor: isDark ? const Color(0xFF112117) : const Color(0xFFF6F8F6),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Provider.of<CourseProvider>(context, listen: false).deleteCourse(widget.course.id!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          final courseAverage = provider.calculateCourseAverage(widget.course.id!);
          final requiredGrade = provider.calculateRequiredFinalGrade(widget.course.id!);
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeaderStats(courseAverage, isDark),
              if (requiredGrade != null && requiredGrade > 0)
                _buildInsightCard(requiredGrade, isDark),
              const SizedBox(height: 24),
              Text(
                'Sınavlar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
              ...provider.examsForCourse(widget.course.id!).map((exam) => _buildExamTile(exam, provider, isDark)),
            ],
          );
        },
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExamDialog(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  Widget _buildHeaderStats(double courseAverage, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1A2C22) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(label: 'Ortalama', value: courseAverage.toStringAsFixed(2), isDark: isDark),
            _StatItem(label: 'Kredi', value: widget.course.credit.toString(), isDark: isDark),
            _StatItem(label: 'Hedef', value: widget.course.targetGrade.toStringAsFixed(0), isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(double requiredGrade, bool isDark) {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.2 : 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Hedefe ulaşmak için kalan sınavlardan ortalama en az ${requiredGrade.toStringAsFixed(2)} alman gerekiyor.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildExamTile(Exam exam, CourseProvider provider, bool isDark) {
    return ListTile(
      title: Text(
        exam.name,
        style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
      ),
      subtitle: Text(
        'Ağırlık: ${exam.weight}%',
        style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
      ),
      trailing: Text(
        exam.grade?.toStringAsFixed(2) ?? 'Girilmedi',
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.grey[200] : Colors.grey[800],
        ),
      ),
      onTap: () => _showAddExamDialog(exam: exam),
    );
  }

  void _showAddExamDialog({Exam? exam}) {
    final _weightController = TextEditingController(text: exam?.weight.toString());
    final _gradeController = TextEditingController(text: exam?.grade?.toString());
    final _descController = TextEditingController(text: exam?.description ?? '');
    final _date = ValueNotifier<DateTime>(exam?.dateTime ?? DateTime.now());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(exam == null ? 'Yeni Sınav Ekle' : 'Sınavı Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _weightController, decoration: const InputDecoration(labelText: 'Ağırlık (%)'), keyboardType: TextInputType.number),
                TextField(controller: _gradeController, decoration: const InputDecoration(labelText: 'Puan'), keyboardType: TextInputType.number),
                TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Açıklama')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                final newExam = Exam(
                  id: exam?.id,
                  courseId: widget.course.id!,
                  name: widget.course.name,
                  weight: int.tryParse(_weightController.text) ?? 0,
                  grade: _gradeController.text.isNotEmpty ? double.parse(_gradeController.text) : null,
                  dateTime: _date.value,
                  description: _descController.text,
                  location: '',
                  isCompleted: exam?.isCompleted ?? false,
                  isScheduled: false,
                );
                if (exam == null) {
                  Provider.of<CourseProvider>(context, listen: false).addExam(newExam);
                } else {
                   Provider.of<CourseProvider>(context, listen: false).updateExam(newExam);
                }
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _StatItem({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[200] : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
