class CalculationHistoryItem {
  final String id;
  final String expression;
  final String result;
  final String rawResult;
  final DateTime timestamp;

  CalculationHistoryItem({
    required this.id,
    required this.expression,
    required this.result,
    required this.rawResult,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expression': expression,
      'result': result,
      'rawResult': rawResult,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CalculationHistoryItem.fromJson(Map<String, dynamic> json) {
    return CalculationHistoryItem(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      expression: json['expression'] as String? ?? '',
      result: json['result'] as String? ?? '',
      rawResult:
          json['rawResult'] as String? ?? json['result'] as String? ?? '0',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
