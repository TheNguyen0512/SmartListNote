import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/features/analytics/domain/analytics_provider.dart';
import 'package:smartlist/localization/app_localizations.dart';

class MonthlyOverview extends StatelessWidget {
  final DateTime currentMonth;

  const MonthlyOverview({super.key, required this.currentMonth});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = Provider.of<AnalyticsProvider>(context);

    final overview = provider.getMonthlyOverview(currentMonth);

    return Card(
      margin: EdgeInsets.all(AppSizes.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.getString('monthlyOverview'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppSizes.spacingMedium(context)),
            _buildPriorityRow(
              context,
              color: Colors.red,
              label: localizations.getString('priorityHigh'),
              count: overview['highPrio'] ?? 0, // Default to 0 if null
            ),
            SizedBox(height: AppSizes.spacingSmall(context)),
            _buildPriorityRow(
              context,
              color: Colors.yellow,
              label: localizations.getString('priorityMedium'),
              count: overview['mediumPrio'] ?? 0, // Default to 0 if null
            ),
            SizedBox(height: AppSizes.spacingSmall(context)),
            _buildPriorityRow(
              context,
              color: Colors.green,
              label: localizations.getString('priorityLow'),
              count: overview['lowPrio'] ?? 0, // Default to 0 if null
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityRow(BuildContext context,
      {required Color color, required String label, required int count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall(context)),
            Text(label, style: TextStyle(fontSize: 14)),
          ],
        ),
        Text('$count tasks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}