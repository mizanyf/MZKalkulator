import 'package:flutter_test/flutter_test.dart';
import 'package:mzkalkulator/services/calculator_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CalculatorEngine Tests', () {
    test('Initial state is 0 and empty top history', () {
      final engine = CalculatorEngine();
      expect(engine.largeDisplay, '0');
      expect(engine.topHistory, '');
      expect(engine.isError, false);
    });

    test('User requested scenario: 9 × 9 typed in large field, = moves 9 × 9 to top and shows 81 in large field, then chained with 1 history line', () {
      final engine = CalculatorEngine();
      // Type 9 directly in large field
      engine.inputDigit('9');
      expect(engine.largeDisplay, '9');
      expect(engine.topHistory, '');

      // Type ×
      engine.inputOperator('×');
      expect(engine.largeDisplay, '9 ×');
      expect(engine.topHistory, '');

      // Type 9
      engine.inputDigit('9');
      expect(engine.largeDisplay, '9 × 9');
      expect(engine.topHistory, ''); // No premature result!

      // Press =
      engine.computeEquals();
      // Result 81 appears in large field, formula 9 × 9 moves to top field
      expect(engine.largeDisplay, '81');
      expect(engine.topHistory, '9 × 9');

      // Now multiply again in the large field (topHistory retains clean formula without = 81):
      engine.inputOperator('×');
      expect(engine.largeDisplay, '81 ×');
      expect(engine.topHistory, '9 × 9');

      engine.inputDigit('2');
      expect(engine.largeDisplay, '81 × 2');

      engine.computeEquals();
      expect(engine.largeDisplay, '162');
      expect(engine.topHistory, '81 × 2');
    });

    test('Operator Precedence: 2 + 3 × 4 in large field = 14', () {
      final engine = CalculatorEngine();
      engine.inputDigit('2');
      engine.inputOperator('+');
      engine.inputDigit('3');
      engine.inputOperator('×');
      engine.inputDigit('4');
      expect(engine.largeDisplay, '2 + 3 × 4');

      engine.computeEquals();
      expect(engine.largeDisplay, '14');
      expect(engine.topHistory, '2 + 3 × 4');
    });

    test('Division by zero displays error in large field', () {
      final engine = CalculatorEngine();
      engine.inputDigit('5');
      engine.inputOperator('÷');
      engine.inputDigit('0');
      engine.computeEquals();

      expect(engine.isError, true);
      expect(engine.largeDisplay, 'Cannot divide by zero');
    });

    test('Decimal input and formatting', () {
      final engine = CalculatorEngine();
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputDigit('0');
      expect(engine.largeDisplay, '1,000');

      engine.inputDecimal();
      expect(engine.largeDisplay, '1,000.');

      engine.inputDigit('5');
      expect(engine.largeDisplay, '1,000.5');

      // Cannot input second decimal
      engine.inputDecimal();
      expect(engine.largeDisplay, '1,000.5');
    });

    test('Delete digit (DEL)', () {
      final engine = CalculatorEngine();
      engine.inputDigit('1');
      engine.inputDigit('2');
      engine.inputDigit('3');
      expect(engine.largeDisplay, '123');

      engine.deleteDigit();
      expect(engine.largeDisplay, '12');

      engine.deleteDigit();
      expect(engine.largeDisplay, '1');

      engine.deleteDigit();
      expect(engine.largeDisplay, '0');
    });

    test('Sign toggle (±)', () {
      final engine = CalculatorEngine();
      engine.inputDigit('4');
      engine.inputDigit('2');
      expect(engine.largeDisplay, '42');

      engine.toggleSign();
      expect(engine.largeDisplay, '-42');

      engine.toggleSign();
      expect(engine.largeDisplay, '42');
    });

    test('Repeated equals: 5 + 2 = 7, = 9, = 11', () {
      final engine = CalculatorEngine();
      engine.inputDigit('5');
      engine.inputOperator('+');
      engine.inputDigit('2');
      engine.computeEquals();
      expect(engine.largeDisplay, '7');

      engine.computeEquals();
      expect(engine.largeDisplay, '9');

      engine.computeEquals();
      expect(engine.largeDisplay, '11');
    });

    test('Clear All (AC)', () {
      final engine = CalculatorEngine();
      engine.inputDigit('9');
      engine.inputOperator('×');
      engine.inputDigit('9');
      engine.computeEquals();
      engine.clearAll();

      expect(engine.largeDisplay, '0');
      expect(engine.topHistory, '');
      expect(engine.isError, false);
    });

    test('Chaining multiple operations: 9 × 9 = 81, + 19 = 100, ÷ 4 = 25', () {
      final engine = CalculatorEngine();
      // 9 × 9 = 81
      engine.inputDigit('9');
      engine.inputOperator('×');
      engine.inputDigit('9');
      engine.computeEquals();
      expect(engine.largeDisplay, '81');
      expect(engine.topHistory, '9 × 9');

      // + 19 = 100
      engine.inputOperator('+');
      expect(engine.largeDisplay, '81 +');
      expect(engine.topHistory, '9 × 9');
      engine.inputDigit('1');
      engine.inputDigit('9');
      expect(engine.largeDisplay, '81 + 19');
      engine.computeEquals();
      expect(engine.largeDisplay, '100');
      expect(engine.topHistory, '81 + 19');

      // ÷ 4 = 25
      engine.inputOperator('÷');
      expect(engine.largeDisplay, '100 ÷');
      expect(engine.topHistory, '81 + 19');
      engine.inputDigit('4');
      expect(engine.largeDisplay, '100 ÷ 4');
      engine.computeEquals();
      expect(engine.largeDisplay, '25');
      expect(engine.topHistory, '100 ÷ 4');
    });

    test('Typing a fresh digit after equals starts a new calculation and keeps 1 previous history', () {
      final engine = CalculatorEngine();
      // 5 + 5 = 10
      engine.inputDigit('5');
      engine.inputOperator('+');
      engine.inputDigit('5');
      engine.computeEquals();
      expect(engine.largeDisplay, '10');
      expect(engine.topHistory, '5 + 5');

      // Typing '3' directly starts new calculation '3'
      engine.inputDigit('3');
      expect(engine.largeDisplay, '3');
      expect(engine.topHistory, '5 + 5');

      engine.inputOperator('×');
      engine.inputDigit('4');
      expect(engine.largeDisplay, '3 × 4');
      engine.computeEquals();
      expect(engine.largeDisplay, '12');
      expect(engine.topHistory, '3 × 4');
    });

    test('Percentage: 200 + 10% = 220', () {
      final engine = CalculatorEngine();
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputOperator('+');
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.inputPercentage();
      expect(engine.largeDisplay, '200 + 20');
      engine.computeEquals();
      expect(engine.largeDisplay, '220');
      expect(engine.topHistory, '200 + 20');
    });
  });
}
