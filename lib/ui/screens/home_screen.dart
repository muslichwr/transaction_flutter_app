import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app/theme/app_theme.dart';
import '../../app/routes/routes.dart';
import '../../data/models/customer.dart';
import '../../data/models/transaction.dart';
import '../../data/providers/app_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../screens/customer_list_screen.dart';
import '../screens/transaction_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const _DashboardTab(),
    const CustomerListScreen(),
    const TransactionListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addTransaction);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Customers',
                    value: appProvider.totalCustomers.toString(),
                    icon: Icons.people,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Total Debt',
                    value: currencyFormat.format(appProvider.totalDebt),
                    icon: Icons.account_balance_wallet,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Today\'s Transactions',
                    value: appProvider.todayTransactionsCount.toString(),
                    icon: Icons.today,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Today\'s Amount',
                    value: currencyFormat.format(
                      appProvider.todayTransactionsTotal,
                    ),
                    icon: Icons.paid,
                    color:
                        appProvider.todayTransactionsTotal >= 0
                            ? AppColors.debit
                            : AppColors.credit,
                  ),
                ),
              ],
            ),

            // Quick actions
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Quick Actions'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  Icons.person_add,
                  'Add Customer',
                  AppRoutes.addCustomer,
                ),
                _buildActionButton(
                  context,
                  Icons.add_card,
                  'Add Transaction',
                  AppRoutes.addTransaction,
                ),
                _buildActionButton(
                  context,
                  Icons.search,
                  'Find Customer',
                  AppRoutes.customerList,
                ),
              ],
            ),

            // Recent transactions
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(context, 'Recent Transactions'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.transactionList);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentTransactions(context, appProvider),

            // Customers with highest debt
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Highest Debt Customers'),
            const SizedBox(height: 16),
            _buildDebtChart(context, appProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    AppProvider appProvider,
  ) {
    final recentTransactions = appProvider.recentTransactions;

    if (recentTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No recent transactions'),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: recentTransactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = recentTransactions[index];
        final customer = appProvider.getCustomerById(transaction.customerId);

        return TransactionListItem(
          transaction: transaction,
          customerName: customer?.name ?? 'Unknown Customer',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.transactionDetail,
              arguments: transaction.id,
            );
          },
        );
      },
    );
  }

  Widget _buildDebtChart(BuildContext context, AppProvider appProvider) {
    // Get top 5 customers by debt
    final topCustomers = List<Customer>.from(appProvider.customers)
      ..sort((a, b) => b.totalDebt.compareTo(a.totalDebt));
    final displayCustomers = topCustomers.take(5).toList();

    if (displayCustomers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No customer data available'),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          displayCustomers.isEmpty
              ? const Center(child: Text('No customer data'))
              : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topCustomers[0].totalDebt * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${displayCustomers[groupIndex].name}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: currencyFormat.format(rod.toY),
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < displayCustomers.length) {
                            final name =
                                displayCustomers[value.toInt()].name.split(
                                  ' ',
                                )[0];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups:
                      displayCustomers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final customer = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: customer.totalDebt,
                              color: AppColors.primary.withOpacity(0.7),
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
