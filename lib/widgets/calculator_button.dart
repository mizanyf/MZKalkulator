import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/calculator_constants.dart';

class CalculatorButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Gradient? gradient;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isEquals;
  final VoidCallback onPressed;

  const CalculatorButton({
    super.key,
    this.text,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.gradient,
    required this.onPressed,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.w600,
    this.isEquals = false,
  }) : assert(
         text != null || icon != null,
         'Either text or icon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(CalculatorSpacing.buttonRadius),
        border: Border.all(
          color:
              borderColor ??
              CalculatorColors.primaryCyan.withValues(alpha: 0.25),
          width: 1.1,
        ),
        boxShadow: isEquals
            ? [
                BoxShadow(
                  color: CalculatorColors.primaryCyan.withValues(alpha: 0.5),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CalculatorSpacing.buttonRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(
                CalculatorSpacing.buttonRadius,
              ),
              splashColor: isEquals
                  ? Colors.black.withValues(alpha: 0.2)
                  : CalculatorColors.primaryCyan.withValues(alpha: 0.2),
              highlightColor: isEquals
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.08),
              child: Center(
                child:
                    icon ??
                    Text(
                      text ?? '',
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        letterSpacing: -0.5,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
