import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/features/analytics/domain/analytics_provider.dart';
import 'package:smartlist/features/analytics/presentation/widgets/calendar_view.dart';
import 'package:smartlist/features/analytics/presentation/widgets/monthly_overview.dart';
import 'package:smartlist/features/analytics/presentation/widgets/productivity_chart.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/routing/route_paths.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  AnalyticsScreenState createState() => AnalyticsScreenState();
}

class AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  int _selectedIndex = 1;

  void _onTabTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      context.go(RoutePaths.noteList); // Navigate to AnalyticsScreen
      setState(() => _selectedIndex = 1);
    } else if (index == 2) {
      context.go(RoutePaths.settings);
      setState(() => _selectedIndex = 1);
    }
  }

  @override
  void initState() {
    super.initState();
    // Schedule provider access after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(
        context,
        listen: false,
      ).loadAnalyticsData(month: _currentMonth);
    });
  }

  void _navigateMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + direction,
        1,
      );
    });
    // Reload data for the new month
    Provider.of<AnalyticsProvider>(
      context,
      listen: false,
    ).loadAnalyticsData(month: _currentMonth);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.getString('analyticsTitle'))),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                localizations.getString(provider.errorMessage!),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.error),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _navigateMonth(-1),
                      ),
                      Text(
                        '${_currentMonth.month} ${_currentMonth.year}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _navigateMonth(1),
                      ),
                    ],
                  ),
                ),
                CalendarView(
                  currentMonth: _currentMonth,
                  selectedDate: _selectedDate,
                  onDateSelected: _onDateSelected,
                ),
                MonthlyOverview(currentMonth: _currentMonth),
                ProductivityChart(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade500,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.note),
            label: localizations.getString('tasks'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: localizations.getString('calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: localizations.getString('settings'),
          ),
        ],
      ),
    );
  }
}
