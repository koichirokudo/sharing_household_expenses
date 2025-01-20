import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/extensions/provider_ref_extensions.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../providers/auth_state.dart';

class ReportPage extends ConsumerStatefulWidget {
  final bool shared;

  const ReportPage({
    super.key,
    required this.shared,
  });

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends ConsumerState<ReportPage> {
  bool _isLoading = false;
  late AuthState auth;
  late bool shared;

  @override
  void initState() {
    super.initState();
    shared = widget.shared;
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

  List<BarChartGroupData> _generateBarGroup(
      Map<String, double> data, String type) {
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
            color: type == 'income' ? Colors.green : Colors.red,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
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
        aspectRatio: 1.2,
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
                          ),
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
    List<BarChartGroupData> sharedExpenseBarGroup = [];
    List<BarChartGroupData> sharedIncomeBarGroup = [];
    List<BarChartGroupData> privateExpenseBarGroup = [];
    List<BarChartGroupData> privateIncomeBarGroup = [];
    double sharedExpenseMaxY = 0.0;
    double sharedIncomeMaxY = 0.0;
    double privateExpenseMaxY = 0.0;
    double privateIncomeMaxY = 0.0;

    if (shared) {
      sharedExpenseBarGroup = _generateBarGroup(sharedExpense, 'expense');
      sharedIncomeBarGroup = _generateBarGroup(sharedIncome, 'income');
      sharedExpenseMaxY = _getMaxValue(sharedExpense);
      sharedIncomeMaxY = _getMaxValue(sharedIncome);
    } else {
      privateExpenseBarGroup = _generateBarGroup(privateExpense, 'expense');
      privateIncomeBarGroup = _generateBarGroup(privateIncome, 'income');
      privateExpenseMaxY = _getMaxValue(privateExpense);
      privateIncomeMaxY = _getMaxValue(privateIncome);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('今月のレポート'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (shared) ...[
              _buildTitleRow(shared, 'income'),
              const Divider(height: 1, color: Colors.black12),
              _buildBarChart(
                sharedIncome,
                sharedIncomeBarGroup,
                sharedIncomeMaxY,
              ),
              _buildTitleRow(shared, 'expense'),
              const Divider(height: 1, color: Colors.black12),
              _buildBarChart(
                sharedExpense,
                sharedExpenseBarGroup,
                sharedExpenseMaxY,
              ),
            ] else ...[
              _buildTitleRow(shared, 'income'),
              const Divider(height: 1, color: Colors.black12),
              _buildBarChart(
                privateIncome,
                privateIncomeBarGroup,
                privateIncomeMaxY,
              ),
              _buildTitleRow(shared, 'expense'),
              const Divider(height: 1, color: Colors.black12),
              _buildBarChart(
                privateExpense,
                privateExpenseBarGroup,
                privateExpenseMaxY,
              ),
            ],
            const SizedBox(height: 46),
          ],
        ),
      ),
    );
  }
}
