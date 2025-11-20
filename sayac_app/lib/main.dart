import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unimate/providers/course_provider.dart';
import 'package:unimate/providers/theme_provider.dart';
import 'package:unimate/providers/user_provider.dart';
import 'package:unimate/screens/home_screen.dart';
import 'package:unimate/core/theme/app_theme.dart';
import 'package:unimate/services/notification_service.dart';
import 'package:unimate/providers/class_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initializeNotifications();
  
  // Provider'ları initialize et
  final themeProvider = ThemeProvider();
  final userProvider = UserProvider();
  await themeProvider.init();
  await userProvider.init();
  
  runApp(MyApp(themeProvider: themeProvider, userProvider: userProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final UserProvider userProvider;
  
  const MyApp({
    super.key,
    required this.themeProvider,
    required this.userProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CourseProvider()),
        ChangeNotifierProvider(create: (context) => ClassProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: userProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) {
          return MaterialApp(
            title: 'Grade Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
