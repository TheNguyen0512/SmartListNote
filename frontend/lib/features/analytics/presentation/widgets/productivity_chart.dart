import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/features/analytics/domain/analytics_provider.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/localization/app_localizations.dart';

class ProductivityChart extends StatelessWidget {
  const ProductivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = Provider.of<AnalyticsProvider>(context);
    final overview = provider.getMonthlyOverview(DateTime.now());

    return Card(
      margin: EdgeInsets.all(AppSizes.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.getString('productivityChart'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppSizes.spacingMedium(context)),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: (overview['highPrio'] ?? 0).toDouble(),
                          color: Colors.red,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: (overview['mediumPrio'] ?? 0).toDouble(),
                          color: Colors.yellow,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: (overview['lowPrio'] ?? 0).toDouble(),
                          color: Colors.green,
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text(localizations.getString('priorityHigh'));
                            case 1:
                              return Text(localizations.getString('priorityMedium'));
                            case 2:
                              return Text(localizations.getString('priorityLow'));
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
