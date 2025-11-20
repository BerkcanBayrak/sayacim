import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sayac_app/providers/course_provider.dart';
import 'package:sayac_app/providers/theme_provider.dart';
import 'package:sayac_app/providers/user_provider.dart';
import 'package:sayac_app/screens/home_screen.dart';
import 'package:sayac_app/core/theme/app_theme.dart';
import 'package:sayac_app/services/notification_service.dart';
import 'package:sayac_app/providers/class_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CourseProvider()),
        ChangeNotifierProvider(create: (context) => ClassProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Grade Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
