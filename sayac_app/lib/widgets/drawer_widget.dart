import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../core/constants/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/course_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/exam_schedule_screen.dart';
import '../screens/weekly_schedule_screen.dart';
import '../screens/home_screen.dart';
import '../screens/dining_menu_screen.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final weightedGPA = courseProvider.calculateWeightedGPA();
    
    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF6F8F6),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: userProvider.userProfile.profileImagePath != null
                      ? FileImage(File(userProvider.userProfile.profileImagePath!))
                      : null,
                  child: userProvider.userProfile.profileImagePath == null
                      ? const Icon(Icons.person, size: 30, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  userProvider.userProfile.name.isEmpty ? 'Kullanıcı' : userProvider.userProfile.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                Text(
                  'Genel Ortalama: ${weightedGPA.toStringAsFixed(2)}/4.0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home_outlined, color: isDark ? Colors.grey[400] : Colors.grey[800]),
            title: Text(
              'Ana Sayfa',
              style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today_outlined, color: isDark ? Colors.grey[400] : Colors.grey[800]),
            title: Text(
              'Sınav Takvimi',
              style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ExamScheduleScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.schedule_outlined, color: isDark ? Colors.grey[400] : Colors.grey[800]),
            title: Text(
              'Haftalık Program',
              style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WeeklyScheduleScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.restaurant_menu, color: isDark ? Colors.grey[400] : Colors.grey[800]),
            title: Text(
              'Yemek Menüsü',
              style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiningMenuScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: isDark ? Colors.grey[400] : Colors.grey[800]),
            title: Text(
              'Ayarlar',
              style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800]),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
