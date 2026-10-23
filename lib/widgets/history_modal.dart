import 'package:flutter/material.dart';

import '../models/calculation_history_item.dart';
import '../services/history_service.dart';
import '../utils/calculator_constants.dart';

class HistoryModal extends StatefulWidget {
  final Function(String rawValue) onSelectResult;

  const HistoryModal({super.key, required this.onSelectResult});

  static Future<void> show(
    BuildContext context, {
    required Function(String) onSelectResult,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => HistoryModal(onSelectResult: onSelectResult),
    );
  }

  @override
  State<HistoryModal> createState() => _HistoryModalState();
}

class _HistoryModalState extends State<HistoryModal> {
  List<CalculationHistoryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await HistoryService.instance.loadHistory();
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAll() async {
    await HistoryService.instance.clearHistory();
    if (mounted) {
      setState(() {
        _items = [];
      });
    }
  }

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
      decoration: const BoxDecoration(
        color: CalculatorColors.sheetBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        border: Border(
          top: BorderSide(color: CalculatorColors.sheetBorder, width: 1.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: CalculatorColors.accentLime.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: CalculatorColors.accentLime,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Flexible(
                        child: Text(
                          'History',
                          style: TextStyle(
                            color: CalculatorColors.textPrimary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_items.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      size: 18,
                      color: Color(0xFFFF6961),
                    ),
                    label: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Color(0xFFFF6961),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      backgroundColor: const Color(0x1AFF6961),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(color: CalculatorColors.dividerColor, height: 1),

          // Body
          Flexible(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: CalculatorColors.accentLime,
                    ),
                  )
                : _items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CalculatorColors.sheetBorder,
                            ),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            size: 36,
                            color: CalculatorColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No calculations yet',
                          style: TextStyle(
                            color: CalculatorColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Previous calculations will be saved here so you can tap to reuse results.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CalculatorColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return InkWell(
                        onTap: () {
                          widget.onSelectResult(item.rawResult);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 14.0,
                          ),
                          decoration: BoxDecoration(
                            color: CalculatorColors.sheetCardBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: CalculatorColors.sheetBorder,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.expression,
                                      style: const TextStyle(
                                        color: CalculatorColors.textSecondary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '= ${item.result}',
                                      style: const TextStyle(
                                        color: CalculatorColors.accentLime,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatRelativeTime(item.timestamp),
                                    style: const TextStyle(
                                      color: Color(0xFF636366),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CalculatorColors.accentLime
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Use',
                                          style: TextStyle(
                                            color: CalculatorColors.accentLime,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 10,
                                          color: CalculatorColors.accentLime,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
