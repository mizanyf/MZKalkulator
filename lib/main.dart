import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/calculator_screen.dart';
import 'utils/calculator_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MZCalculatorApp());
}

class MZCalculatorApp extends StatelessWidget {
  const MZCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MZ Kalkulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CalculatorColors.canvasBackground,
        colorScheme: const ColorScheme.dark(
          primary: CalculatorColors.primaryCyan,
          surface: CalculatorColors.canvasBackground,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}
