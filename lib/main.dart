import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'symptom_input_screen.dart';
import 'upload_report_screen.dart';
import 'results_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("❌ Failed to load .env: $e");
  }

  runApp(const SecondOpinionApp());
}

class SecondOpinionApp extends StatelessWidget {
  const SecondOpinionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Second Opinion',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SymptomInputScreen(),
      routes: {
        '/upload': (context) => const UploadReportScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}
