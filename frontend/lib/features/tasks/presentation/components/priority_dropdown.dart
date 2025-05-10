import 'package:flutter/material.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/tasks/domain/entities/task.dart';

class PriorityDropdown extends StatelessWidget {
  final Priority? selectedPriority;
  final ValueChanged<Priority?> onChanged;

  const PriorityDropdown({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textSecondary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<Priority>(
        value: selectedPriority,
        onChanged: onChanged,
        items: Priority.values.map((priority) {
          String label;
          switch (priority) {
            case Priority.low:
              label = localizations.priorityLow;
              break;
            case Priority.medium:
              label = localizations.priorityMedium;
              break;
            case Priority.high:
              label = localizations.priorityHigh;
              break;
          }
          return DropdownMenuItem<Priority>(
            value: priority,
            child: Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.3, // Responsive width
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }).toList(),
        isExpanded: true,
        underline: const SizedBox(),
        style: Theme.of(context).textTheme.bodyMedium,
        dropdownColor: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}