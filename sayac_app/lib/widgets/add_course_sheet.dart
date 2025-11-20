import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';

class AddCourseSheet extends StatefulWidget {
  const AddCourseSheet({super.key});

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _creditController = TextEditingController();
  final _targetGradeController = TextEditingController();

  String _selectedColorHex = AppColors.courseRed.value.toRadixString(16);

  @override
  Widget build(BuildContext context) {
    final courseColors = [
      AppColors.courseRed,
      AppColors.courseBlue,
      AppColors.courseGreen,
      AppColors.courseYellow,
      AppColors.coursePurple,
      AppColors.courseIndigo,
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Yeni Ders Ekle', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ders Adı'),
              validator: (value) => value!.isEmpty ? 'Lütfen bir ders adı girin' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _creditController,
                    decoration: const InputDecoration(labelText: 'Kredi'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Kredi girin' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _targetGradeController,
                    decoration: const InputDecoration(labelText: 'Hedef Not'),
                    keyboardType: TextInputType.number,
                     validator: (value) => value!.isEmpty ? 'Hedef girin' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Ders Rengi Seç', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: courseColors.length,
                itemBuilder: (context, index) {
                  final color = courseColors[index];
                  final colorHex = color.value.toRadixString(16);
                  final isSelected = _selectedColorHex == colorHex;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorHex = colorHex;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 10),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addCourse,
              child: const Text('Dersi Kaydet'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addCourse() {
    if (_formKey.currentState!.validate()) {
      final newCourse = Course(
        name: _nameController.text,
        credit: int.parse(_creditController.text),
        targetGrade: double.parse(_targetGradeController.text),
        colorHex: _selectedColorHex,
      );

      Provider.of<CourseProvider>(context, listen: false).addCourse(newCourse);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditController.dispose();
    _targetGradeController.dispose();
    super.dispose();
  }
}
