import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/calculation_history_item.dart';
import '../utils/calculator_constants.dart';

class CalculatorDisplay extends StatelessWidget {
  final String? expression;
  final String? displayValue;
  final bool isLivePreview;
  final bool isError;
  final List<CalculationHistoryItem>? history;
  final Function(String rawValue)? onSelectHistory;

  const CalculatorDisplay({
    super.key,
    this.expression = '',
    this.displayValue = '0',
    this.isLivePreview = false,
    this.isError = false,
    this.history,
    this.onSelectHistory,
  });

  @override
  Widget build(BuildContext context) {
    final safeExpression = expression ?? '';
    final safeDisplay = (displayValue == null || displayValue!.isEmpty)
        ? '0'
        : displayValue!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(CalculatorSpacing.displayRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 22.0),
          decoration: BoxDecoration(
            color: const Color(0xFF070B11).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(
              CalculatorSpacing.displayRadius,
            ),
            border: Border.all(
              color: CalculatorColors.primaryCyan.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: CalculatorColors.primaryCyan.withValues(alpha: 0.1),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 1. Smaller Top Field: Exactly 1 previous calculation history (e.g. "9 × 9")
              Container(
                alignment: Alignment.centerRight,
                height: 28,
                child: SingleChildScrollView(
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    safeExpression.isEmpty ? ' ' : safeExpression,
                    style: const TextStyle(
                      color: CalculatorColors.textSecondary,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),

              const SizedBox(height: 12.0),

              // 2. Large Bottom Field: Active calculation while typing, or result after "="
              Container(
                alignment: Alignment.centerRight,
                height: 64,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    safeDisplay,
                    style: TextStyle(
                      color: isError
                          ? const Color(0xFFFF6961)
                          : CalculatorColors.textPrimary,
                      fontSize: isError ? 32.0 : 56.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
