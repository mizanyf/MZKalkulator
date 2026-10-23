import 'package:flutter/foundation.dart';

import '../models/calculation_history_item.dart';
import 'history_service.dart';

class CalculatorEngine extends ChangeNotifier {
  String _currentNumber = '0';
  final List<String> _tokens = [];
  final List<CalculationHistoryItem> _history = [];

  String _topHistory = '';
  bool _isNewNumber = true;
  bool _hasComputed = false;
  bool _isError = false;
  String _errorMessage = '';

  // Repeated equals support
  String? _lastOperator;
  double? _lastOperand;

  CalculatorEngine() {
    _loadInitialHistory();
  }

  Future<void> _loadInitialHistory() async {
    final list = await HistoryService.instance.loadHistory();
    _history.clear();
    _history.addAll(list);
    if (_history.isNotEmpty) {
      _topHistory = _history.first.expression;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Getters for UI
  // ---------------------------------------------------------------------------

  bool get isError => _isError;
  String get errorMessage {
    try {
      return _errorMessage.isEmpty ? 'Error' : _errorMessage;
    } catch (_) {
      return 'Error';
    }
  }

  /// Exactly 1 previous calculation history displayed in the smaller top field
  String get topHistory {
    try {
      return _topHistory;
    } catch (_) {
      return '';
    }
  }

  /// Backward-compatible alias for existing tests / widgets
  String get expression => topHistory;

  /// The large main field:
  /// - While typing: displays current formula directly (e.g. "9", "9 ×", "9 × 9")
  /// - When '=' is clicked: displays the calculated result (e.g. "81")
  String get largeDisplay {
    try {
      if (_isError) {
        return errorMessage;
      }

      if (_hasComputed) {
        return formatNumberString(_currentNumber);
      }

      List<String> tokens;
      try {
        tokens = _tokens;
      } catch (_) {
        tokens = const [];
      }

      if (tokens.isEmpty) {
        return _isNewNumber ? '0' : formatNumberString(_currentNumber);
      }

      final buffer = StringBuffer();
      for (int i = 0; i < tokens.length; i++) {
        final token = tokens[i];
        if (_isOperator(token)) {
          buffer.write(' ${_displayOperator(token)} ');
        } else {
          buffer.write(formatNumberString(token));
        }
      }

      if (!_isNewNumber) {
        buffer.write(formatNumberString(_currentNumber));
      }

      final res = buffer.toString().trim();
      return res.isEmpty ? '0' : res;
    } catch (_) {
      return '0';
    }
  }

  /// Backward-compatible alias for formattedDisplay
  String get formattedDisplay => largeDisplay;

  List<CalculationHistoryItem> get history {
    try {
      return List.unmodifiable(_history);
    } catch (_) {
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // User Inputs
  // ---------------------------------------------------------------------------

  /// Input a digit '0' - '9'
  void inputDigit(String digit) {
    if (_isError) {
      clearAll();
    }

    if (_hasComputed) {
      // Starting fresh number after equals
      _tokens.clear();
      _currentNumber = digit;
      _hasComputed = false;
      _isNewNumber = false;
      _lastOperator = null;
      _lastOperand = null;
      notifyListeners();
      return;
    }

    if (_isNewNumber) {
      _currentNumber = digit;
      _isNewNumber = false;
    } else {
      if (_currentNumber == '0') {
        _currentNumber = digit;
      } else {
        if (_currentNumber.replaceAll(RegExp(r'[,-]'), '').length < 15) {
          _currentNumber += digit;
        }
      }
    }
    notifyListeners();
  }

  /// Input decimal point '.'
  void inputDecimal() {
    if (_isError) {
      clearAll();
    }

    if (_hasComputed) {
      _tokens.clear();
      _currentNumber = '0.';
      _hasComputed = false;
      _isNewNumber = false;
      _lastOperator = null;
      _lastOperand = null;
      notifyListeners();
      return;
    }

    if (_isNewNumber) {
      _currentNumber = '0.';
      _isNewNumber = false;
    } else if (!_currentNumber.contains('.')) {
      _currentNumber += '.';
    }
    notifyListeners();
  }

  /// Delete last character (DEL)
  void deleteDigit() {
    if (_isError) {
      clearAll();
      return;
    }

    if (_hasComputed) {
      _currentNumber = '0';
      _isNewNumber = true;
      notifyListeners();
      return;
    }

    if (!_isNewNumber) {
      if (_currentNumber.length <= 1 ||
          (_currentNumber.length == 2 && _currentNumber.startsWith('-'))) {
        _currentNumber = '0';
        _isNewNumber = true;
      } else {
        _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
        if (_currentNumber == '-' || _currentNumber.isEmpty) {
          _currentNumber = '0';
          _isNewNumber = true;
        }
      }
      notifyListeners();
      return;
    }

    // If between numbers and tokens exist, remove last operator
    if (_tokens.isNotEmpty && _isOperator(_tokens.last)) {
      _tokens.removeLast();
      if (_tokens.isNotEmpty) {
        _currentNumber = _tokens.removeLast();
        _isNewNumber = false;
      } else {
        _currentNumber = '0';
        _isNewNumber = true;
      }
      notifyListeners();
    }
  }

  /// Toggle positive / negative (±)
  void toggleSign() {
    if (_isError) return;

    if (_currentNumber == '0' || _currentNumber == '0.') {
      return;
    }

    if (_currentNumber.startsWith('-')) {
      _currentNumber = _currentNumber.substring(1);
    } else {
      _currentNumber = '-$_currentNumber';
    }

    if (_hasComputed) {
      _tokens.clear();
      _hasComputed = false;
    }

    notifyListeners();
  }

  /// Percentage button (%)
  void inputPercentage() {
    if (_isError) return;

    final double? currentVal = double.tryParse(_currentNumber);
    if (currentVal == null) return;

    double resultVal;

    if (_tokens.isNotEmpty && _isOperator(_tokens.last)) {
      final String prevOp = _tokens.last;
      final double? baseVal = _tokens.length >= 2
          ? double.tryParse(_tokens[_tokens.length - 2])
          : null;

      if ((prevOp == '+' || prevOp == '−' || prevOp == '-') &&
          baseVal != null) {
        resultVal = baseVal * (currentVal / 100.0);
      } else {
        resultVal = currentVal / 100.0;
      }
    } else {
      resultVal = currentVal / 100.0;
    }

    _currentNumber = _formatRawNumber(resultVal);
    _isNewNumber = false;
    notifyListeners();
  }

  /// Operator input: '+', '−', '×', '÷'
  void inputOperator(String op) {
    if (_isError) {
      clearAll();
    }

    final normalizedOp = _normalizeOperator(op);

    if (_hasComputed) {
      // Keep previous formula in topHistory without appending result
      _tokens.clear();
      _tokens.add(_currentNumber);
      _tokens.add(normalizedOp);
      _isNewNumber = true;
      _hasComputed = false;
      _lastOperator = null;
      _lastOperand = null;
      notifyListeners();
      return;
    }

    // If user tapped another operator consecutively, replace it
    if (_isNewNumber && _tokens.isNotEmpty && _isOperator(_tokens.last)) {
      _tokens[_tokens.length - 1] = normalizedOp;
      notifyListeners();
      return;
    }

    // Add current number and new operator
    _tokens.add(_currentNumber);
    _tokens.add(normalizedOp);
    _isNewNumber = true;
    notifyListeners();
  }

  /// Equals button (=)
  void computeEquals() {
    if (_isError) {
      clearAll();
      return;
    }

    // Repeated equals handling
    if (_hasComputed && _lastOperator != null && _lastOperand != null) {
      final double? currentVal = double.tryParse(_currentNumber);
      if (currentVal == null) return;

      final previousFormatted = formatNumberString(_currentNumber);
      final double resultVal = _calculateBinary(
        currentVal,
        _lastOperator!,
        _lastOperand!,
      );

      if (_isError) {
        notifyListeners();
        return;
      }

      final opDisplay = _displayOperator(_lastOperator!);
      final operandDisplay = formatNumberString(
        _formatRawNumber(_lastOperand!),
      );
      _topHistory = '$previousFormatted $opDisplay $operandDisplay';
      _currentNumber = _formatRawNumber(resultVal);

      _pushHistory(
        _topHistory,
        formatNumberString(_currentNumber),
        _currentNumber,
      );
      notifyListeners();
      return;
    }

    if (_tokens.isEmpty) {
      return;
    }

    // Commit current number into tokens
    if (!_isNewNumber || _tokens.length % 2 == 1) {
      _tokens.add(_currentNumber);
    }

    if (_tokens.length >= 3) {
      _lastOperator = _tokens[_tokens.length - 2];
      _lastOperand = double.tryParse(_tokens.last);
    }

    // Formula moves to top field:
    final formula = _buildFullExpressionDisplay();
    final evalResult = _evaluateTokens(List<String>.from(_tokens));

    if (evalResult == null || _isError) {
      _isError = true;
      if (_errorMessage.isEmpty) {
        _errorMessage = 'Error';
      }
      notifyListeners();
      return;
    }

    _topHistory = formula;
    _currentNumber = _formatRawNumber(evalResult);
    _hasComputed = true;
    _isNewNumber = true;

    _pushHistory(formula, formatNumberString(_currentNumber), _currentNumber);
    notifyListeners();
  }

  /// Clear all (AC)
  void clearAll() {
    _currentNumber = '0';
    _tokens.clear();
    _topHistory = '';
    _isNewNumber = true;
    _hasComputed = false;
    _isError = false;
    _errorMessage = '';
    _lastOperator = null;
    _lastOperand = null;
    notifyListeners();
  }

  /// Restore from history
  void loadFromHistory(String rawValue) {
    clearAll();
    _currentNumber = rawValue;
    _isNewNumber = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internal Math Evaluation
  // ---------------------------------------------------------------------------

  double? _evaluateTokens(List<String> tokens) {
    if (tokens.isEmpty) return null;

    // Precedence 2: Multiplication and Division
    final List<String> intermediate = [];
    int i = 0;
    while (i < tokens.length) {
      final token = tokens[i];
      if (token == '×' || token == '*' || token == '÷' || token == '/') {
        if (intermediate.isEmpty || i + 1 >= tokens.length) {
          _isError = true;
          _errorMessage = 'Error';
          return null;
        }

        final left = double.tryParse(intermediate.removeLast());
        final right = double.tryParse(tokens[i + 1]);

        if (left == null || right == null) {
          _isError = true;
          _errorMessage = 'Error';
          return null;
        }

        if ((token == '÷' || token == '/') && right == 0) {
          _isError = true;
          _errorMessage = 'Cannot divide by zero';
          return null;
        }

        final double res = (token == '×' || token == '*')
            ? (left * right)
            : (left / right);
        intermediate.add(_formatRawNumber(res));
        i += 2;
      } else {
        intermediate.add(token);
        i++;
      }
    }

    // Precedence 1: Addition and Subtraction
    if (intermediate.isEmpty) return null;
    double accumulator = double.tryParse(intermediate[0]) ?? 0.0;
    int j = 1;

    while (j < intermediate.length) {
      final op = intermediate[j];
      if (j + 1 >= intermediate.length) break;
      final right = double.tryParse(intermediate[j + 1]);
      if (right == null) {
        _isError = true;
        _errorMessage = 'Error';
        return null;
      }

      if (op == '+') {
        accumulator += right;
      } else if (op == '−' || op == '-') {
        accumulator -= right;
      }
      j += 2;
    }

    return _cleanDouble(accumulator);
  }

  double _calculateBinary(double a, String op, double b) {
    if (op == '÷' || op == '/') {
      if (b == 0) {
        _isError = true;
        _errorMessage = 'Cannot divide by zero';
        return 0.0;
      }
      return _cleanDouble(a / b);
    } else if (op == '×' || op == '*') {
      return _cleanDouble(a * b);
    } else if (op == '+') {
      return _cleanDouble(a + b);
    } else if (op == '−' || op == '-') {
      return _cleanDouble(a - b);
    }
    return b;
  }

  double _cleanDouble(double val) {
    if (val.isInfinite || val.isNaN) {
      _isError = true;
      _errorMessage = 'Error';
      return 0.0;
    }
    final rounded = double.parse(val.toStringAsPrecision(12));
    if ((rounded - rounded.roundToDouble()).abs() < 1e-11) {
      return rounded.roundToDouble();
    }
    return rounded;
  }

  void _pushHistory(String expr, String formattedRes, String rawRes) {
    if (expr.isEmpty || formattedRes.isEmpty || _isError) return;
    final item = CalculationHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      expression: expr,
      result: formattedRes,
      rawResult: rawRes,
      timestamp: DateTime.now(),
    );
    _history.insert(0, item);
    if (_history.length > 50) {
      _history.removeRange(50, _history.length);
    }
    HistoryService.instance.addHistory(item);
  }

  String _formatRawNumber(double val) {
    if (val.isInfinite || val.isNaN) return '0';
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    String str = val.toStringAsFixed(10);
    str = str.replaceAll(RegExp(r'0+$'), '');
    str = str.replaceAll(RegExp(r'\.$'), '');
    return str;
  }

  static String formatNumberString(String input) {
    if (input.isEmpty) return '0';
    if (input == 'Cannot divide by zero' || input == 'Error') {
      return input;
    }

    final isNegative = input.startsWith('-');
    final cleanInput = isNegative ? input.substring(1) : input;

    final parts = cleanInput.split('.');
    final integerPart = parts[0];
    final hasDecimal = input.contains('.');
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();
    final len = integerPart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }

    String result = buffer.toString();
    if (result.isEmpty) result = '0';

    if (hasDecimal) {
      result += '.$decimalPart';
    }

    return isNegative ? '-$result' : result;
  }

  String _buildFullExpressionDisplay() {
    final buffer = StringBuffer();
    for (int i = 0; i < _tokens.length; i++) {
      final token = _tokens[i];
      if (_isOperator(token)) {
        buffer.write(' ${_displayOperator(token)} ');
      } else {
        buffer.write(formatNumberString(token));
      }
    }
    return buffer.toString().trim();
  }

  bool _isOperator(String token) {
    return token == '+' ||
        token == '−' ||
        token == '-' ||
        token == '×' ||
        token == '*' ||
        token == '÷' ||
        token == '/';
  }

  String _normalizeOperator(String op) {
    if (op == 'x' || op == 'X' || op == '*') return '×';
    if (op == '/') return '÷';
    if (op == '-') return '−';
    return op;
  }

  String _displayOperator(String op) {
    if (op == '*') return '×';
    if (op == '/') return '÷';
    if (op == '-') return '−';
    return op;
  }
}
