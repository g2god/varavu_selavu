import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';
import 'package:varavu_selavu/features/analytics/presentation/pages/analytics_page.dart';
import 'package:varavu_selavu/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:varavu_selavu/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:varavu_selavu/features/settings/presentation/pages/settings_page.dart';
import 'package:varavu_selavu/features/transactions/presentation/pages/transactions_page.dart';

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;
  DateTime _selectedDate = DateTime.now();
  late final DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = sl<DashboardBloc>()..add(LoadDashboard(monthKey: _selectedDate.toYearMonthKey()));
  }

  void _onMonthChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _dashboardBloc.add(ChangeSelectedMonth(newDate.toYearMonthKey()));
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthKey = _selectedDate.toYearMonthKey();

    final pages = [
      DashboardPage(
        selectedDate: _selectedDate,
        onMonthChanged: _onMonthChanged,
        onNavigateToTransactions: () => setState(() => _currentIndex = 1),
        onNavigateToAnalytics: () => setState(() => _currentIndex = 2),
      ),
      TransactionsPage(currentMonthKey: currentMonthKey),
      AnalyticsPage(currentMonthKey: currentMonthKey),
      SettingsPage(currentMonthKey: currentMonthKey),
    ];

    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            if (index == 0) {
              _dashboardBloc.add(LoadDashboard(monthKey: _selectedDate.toYearMonthKey()));
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
