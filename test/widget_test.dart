import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mzkalkulator/main.dart';
import 'package:mzkalkulator/widgets/calculator_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'MZ Calculator full black UI renders 9 × 9 directly in large field, = moves formula to top and shows 81 in large field, chaining with 1 history line',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MZCalculatorApp());
      await tester.pumpAndSettle();

      // Header title and logo are removed from the UI as requested
      expect(find.text('MZ Calculator'), findsNothing);
      expect(find.byType(Image), findsNothing);

      // Verify that the old top-right history icon is not present
      expect(find.byIcon(Icons.history_rounded), findsNothing);

      // Tap 9 on the keypad
      await tester.tap(find.widgetWithText(CalculatorButton, '9'));
      await tester.pumpAndSettle();

      // Tap ×
      await tester.tap(find.widgetWithText(CalculatorButton, '×'));
      await tester.pumpAndSettle();

      // Tap 9 again
      await tester.tap(find.widgetWithText(CalculatorButton, '9'));
      await tester.pumpAndSettle();

      // User requested: "untuk perhitungan langsung saja di field yang besar"
      expect(find.text('9 × 9'), findsOneWidget);

      // Result has NOT appeared yet (User requested: "hasil perhitungan muncul setelah dikik samadengan jangan langsung muncul begitu")
      expect(find.text('81'), findsNothing);

      // Tap =
      await tester.tap(find.widgetWithText(CalculatorButton, '='));
      await tester.pumpAndSettle();

      // User requested: "dan di samadengan nanti hasilnya difield yang besar sementara perintah perhitungan pindah difield atas yang lebih kecil"
      expect(find.text('81'), findsOneWidget);
      expect(find.text('9 × 9'), findsOneWidget);

      // User requested: "dan hasilnya bisa dihitung lagi di field besar namun untuk history diatas saya mau hanya 1 history perhitungan saja"
      // Tap ×
      await tester.tap(find.widgetWithText(CalculatorButton, '×'));
      await tester.pumpAndSettle();

      // Tap 2
      await tester.tap(find.widgetWithText(CalculatorButton, '2'));
      await tester.pumpAndSettle();

      expect(find.text('81 × 2'), findsOneWidget);

      // Tap =
      await tester.tap(find.widgetWithText(CalculatorButton, '='));
      await tester.pumpAndSettle();

      expect(find.text('162'), findsOneWidget);
      expect(find.text('81 × 2'), findsOneWidget);

      // Tap AC
      await tester.tap(find.widgetWithText(CalculatorButton, 'AC'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsWidgets);
    },
  );
}
