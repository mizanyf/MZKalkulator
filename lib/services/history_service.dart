import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/calculation_history_item.dart';

class HistoryService {
  static const String _storageKey = 'mz_calculator_history';
  static const int _maxItems = 100;

  static final HistoryService instance = HistoryService._internal();
  HistoryService._internal();

  Future<List<CalculationHistoryItem>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey);
      if (rawList == null || rawList.isEmpty) {
        return [];
      }
      return rawList.map((itemStr) {
        final Map<String, dynamic> json =
            jsonDecode(itemStr) as Map<String, dynamic>;
        return CalculationHistoryItem.fromJson(json);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addHistory(CalculationHistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHistory = await loadHistory();

      // Insert new item at the top
      currentHistory.insert(0, item);
      if (currentHistory.length > _maxItems) {
        currentHistory.removeRange(_maxItems, currentHistory.length);
      }

      final encodedList = currentHistory
          .map((e) => jsonEncode(e.toJson()))
          .toList();
      await prefs.setStringList(_storageKey, encodedList);
    } catch (_) {
      // Graceful fallback if storage fails
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}
