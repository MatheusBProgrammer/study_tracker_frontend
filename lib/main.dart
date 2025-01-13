import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_tracker_frontend/pages/home_page.dart';
import 'package:study_tracker_frontend/pages/login_page.dart';
import 'package:study_tracker_frontend/pages/exam_details_page.dart'; // Importa a página de detalhes do exame
import 'package:study_tracker_frontend/pages/register_page.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Study Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (ctx) => const LoginPage(),
          '/home': (ctx) => const HomePage(),
          "/register": (ctx) => const RegisterPage(),
          '/exam-details': (ctx) => const ExamDetailsPage(),
        },
      ),
    );
  }
}
