import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/calculator_engine.dart';
import '../utils/calculator_constants.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_display.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late final CalculatorEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = CalculatorEngine();
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: CalculatorColors.canvasBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: AnimatedBuilder(
                animation: _engine,
                builder: (context, _) {
                  return Column(
                    children: [
                      const SizedBox(height: 12.0),

                      // Display Panel: 1 top history line, large input/result field
                      Expanded(
                        flex: 8,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: CalculatorDisplay(
                            expression: _engine.topHistory,
                            displayValue: _engine.largeDisplay,
                            isError: _engine.isError,
                          ),
                        ),
                      ),

                      // Responsive Spacer
                      const Spacer(flex: 1),

                      // Keypad Grid (5 Rows x 4 Columns)
                      Expanded(flex: 14, child: _buildKeypad()),

                      const SizedBox(height: 16.0),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const gap = CalculatorSpacing.buttonGap;

    return Column(
      children: [
        // Row 1: AC | ± | % | ÷
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: 'AC',
                  backgroundColor: CalculatorColors.utilityButtonGlass,
                  borderColor: CalculatorColors.utilityButtonBorder,
                  textColor: CalculatorColors.utilityText,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  onPressed: () => _engine.clearAll(),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '±',
                  backgroundColor: CalculatorColors.utilityButtonGlass,
                  borderColor: CalculatorColors.utilityButtonBorder,
                  textColor: CalculatorColors.utilityText,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                  onPressed: () => _engine.toggleSign(),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '%',
                  backgroundColor: CalculatorColors.utilityButtonGlass,
                  borderColor: CalculatorColors.utilityButtonBorder,
                  textColor: CalculatorColors.utilityText,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                  onPressed: () => _engine.inputPercentage(),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '÷',
                  backgroundColor: CalculatorColors.operatorButtonGlass,
                  borderColor: CalculatorColors.operatorButtonBorder,
                  textColor: CalculatorColors.operatorSymbol,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w500,
                  onPressed: () => _engine.inputOperator('÷'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: gap),

        // Row 2: 7 | 8 | 9 | ×
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: '7',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('7'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '8',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('8'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '9',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('9'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '×',
                  backgroundColor: CalculatorColors.operatorButtonGlass,
                  borderColor: CalculatorColors.operatorButtonBorder,
                  textColor: CalculatorColors.operatorSymbol,
                  fontSize: 26.0,
                  fontWeight: FontWeight.w500,
                  onPressed: () => _engine.inputOperator('×'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: gap),

        // Row 3: 4 | 5 | 6 | −
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: '4',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('4'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '5',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('5'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '6',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('6'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '−',
                  backgroundColor: CalculatorColors.operatorButtonGlass,
                  borderColor: CalculatorColors.operatorButtonBorder,
                  textColor: CalculatorColors.operatorSymbol,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w500,
                  onPressed: () => _engine.inputOperator('−'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: gap),

        // Row 4: 1 | 2 | 3 | +
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: '1',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('1'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '2',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('2'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '3',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('3'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '+',
                  backgroundColor: CalculatorColors.operatorButtonGlass,
                  borderColor: CalculatorColors.operatorButtonBorder,
                  textColor: CalculatorColors.operatorSymbol,
                  fontSize: 26.0,
                  fontWeight: FontWeight.w500,
                  onPressed: () => _engine.inputOperator('+'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: gap),

        // Row 5: 0 | . | DEL | =
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: '0',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  onPressed: () => _engine.inputDigit('0'),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '.',
                  backgroundColor: CalculatorColors.numberButtonGlass,
                  borderColor: CalculatorColors.numberButtonBorder,
                  textColor: CalculatorColors.numberText,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  onPressed: () => _engine.inputDecimal(),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  icon: const Icon(
                    Icons.backspace_outlined,
                    size: 22.0,
                    color: CalculatorColors.utilityText,
                  ),
                  backgroundColor: CalculatorColors.utilityButtonGlass,
                  borderColor: CalculatorColors.utilityButtonBorder,
                  textColor: CalculatorColors.utilityText,
                  onPressed: () => _engine.deleteDigit(),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _buildButton(
                  text: '=',
                  backgroundColor: CalculatorColors.primaryCyan,
                  borderColor: CalculatorColors.primaryCyanLight,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CalculatorColors.equalsButtonGradientStart,
                      CalculatorColors.equalsButtonGradientEnd,
                    ],
                  ),
                  textColor: CalculatorColors.equalsText,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w700,
                  isEquals: true,
                  onPressed: () => _engine.computeEquals(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    String? text,
    Widget? icon,
    required Color backgroundColor,
    Color? borderColor,
    Gradient? gradient,
    required Color textColor,
    double fontSize = 24.0,
    FontWeight fontWeight = FontWeight.w600,
    bool isEquals = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox.expand(
      child: CalculatorButton(
        text: text,
        icon: icon,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        gradient: gradient,
        textColor: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        isEquals: isEquals,
        onPressed: () {
          _triggerHaptic();
          onPressed();
        },
      ),
    );
  }
}
