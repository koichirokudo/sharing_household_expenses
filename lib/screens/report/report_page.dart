import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/extensions/provider_ref_extensions.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../providers/auth_state.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends ConsumerState<ReportPage> {
  bool _isLoading = false;
  late AuthState auth;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      setState(() {
        _isLoading = true;
      });
      await ref.authNotifier.fetchProfile();
      final profileId = ref.profileId;
      final groupId = ref.groupId;
      if (profileId != null && groupId != null) {
        await ref.transactionNotifier.fetchMonthlyTransactions(
          groupId,
          profileId,
          DateTime.now(),
        );
        ref.transactionNotifier.calculateCurrentTotals();
        ref.transactionNotifier.generateBarChartData(profileId);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  List<BarChartGroupData> _generateBarGroup(Map<String, double> data) {
    final barGroup = data.entries.map((entry) {
      final categoryName = entry.key;
      final value = entry.value;
      final index = data.keys.toList().indexOf(categoryName) + 1;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 20,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return barGroup;
  }

  double _getMaxValue(Map<String, double> data) {
    return (data.isNotEmpty ? data.values.reduce((a, b) => a > b ? a : b) : 0) *
        1.5;
  }

  Widget _buildTitleRow(bool shared, String type) {
    String title = '';

    if (shared && type == 'expense') {
      title = 'グループ支出';
    } else if (shared && type == 'income') {
      title = 'グループ収入';
    } else if (!shared && type == 'expense') {
      title = '個人支出';
    } else if (!shared && type == 'income') {
      title = '個人収入';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBarChart(
    Map<String, double> data,
    List<BarChartGroupData> barGroup,
    double maxY,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            maxY: maxY,
            rotationQuarterTurns: 1,
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt() - 1;
                    if (index >= 0 && index < data.keys.length) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          data.keys.elementAt(index),
                          style: TextStyle(
                            fontSize: 12,
                          ), // Adjust font size as needed
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: false,
            ),
            borderData: FlBorderData(
              border: const Border(
                top: BorderSide.none,
                right: BorderSide.none,
                left: BorderSide.none,
                bottom: BorderSide.none,
              ),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                direction: TooltipDirection.auto,
                tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                tooltipHorizontalOffset: 2,
                getTooltipColor: (_) => Colors.transparent,
                fitInsideVertically: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final value = rod.toY;
                  return BarTooltipItem(
                    convertToYenFormat(amount: value.toInt()),
                    // ツールチップに表示する値
                    TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                tooltipBorder: BorderSide.none,
              ),
            ),
            barGroups: barGroup,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharedExpense = ref.transactionState.sharedExpenseSections;
    final sharedIncome = ref.transactionState.sharedIncomeSections;
    final privateExpense = ref.transactionState.privateExpenseSections;
    final privateIncome = ref.transactionState.privateIncomeSections;

    final sharedExpenseBarGroup = _generateBarGroup(sharedExpense);
    final sharedIncomeBarGroup = _generateBarGroup(sharedIncome);
    final privateExpenseBarGroup = _generateBarGroup(privateExpense);
    final privateIncomeBarGroup = _generateBarGroup(privateIncome);

    final sharedExpenseMaxY = _getMaxValue(sharedExpense);
    final sharedIncomeMaxY = _getMaxValue(sharedIncome);
    final privateExpenseMaxY = _getMaxValue(privateExpense);
    final privateIncomeMaxY = _getMaxValue(privateIncome);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('今月のレポート'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTitleRow(true, 'income'),
            const Divider(height: 1, color: Colors.black12),
            _buildBarChart(
              sharedIncome,
              sharedIncomeBarGroup,
              sharedIncomeMaxY,
            ),
            _buildTitleRow(true, 'expense'),
            const Divider(height: 1, color: Colors.black12),
            _buildBarChart(
              sharedExpense,
              sharedExpenseBarGroup,
              sharedExpenseMaxY,
            ),
            _buildTitleRow(false, 'income'),
            const Divider(height: 1, color: Colors.black12),
            _buildBarChart(
              privateIncome,
              privateIncomeBarGroup,
              privateIncomeMaxY,
            ),
            _buildTitleRow(false, 'expense'),
            const Divider(height: 1, color: Colors.black12),
            _buildBarChart(
              privateExpense,
              privateExpenseBarGroup,
              privateExpenseMaxY,
            ),
          ],
        ),
      ),
    );
  }
}
