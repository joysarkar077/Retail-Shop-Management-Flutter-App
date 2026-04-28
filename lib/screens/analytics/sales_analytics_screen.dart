import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  String _selectedPeriod = 'week';
  Map<String, dynamic>? _summary;
  List<dynamic> _revenueSeries = [];
  List<dynamic> _topProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final summary = await AnalyticsService.getSummary(
        period: _selectedPeriod,
      );
      final series = await AnalyticsService.getRevenueSeries(
        period: _selectedPeriod,
      );
      final top = await AnalyticsService.getTopProducts(limit: 5);

      if (mounted) {
        setState(() {
          _summary = summary;
          _revenueSeries = series;
          _topProducts = top;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPeriodPill(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
        _fetchData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPeriodPill('today', 'Today'),
                      _buildPeriodPill('week', 'This Week'),
                      _buildPeriodPill('month', 'This Month'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Summary Cards
                  Row(
                    children: [
                      _SummaryCard(
                        title: 'Orders',
                        value: '${_summary?['orderCount'] ?? 0}',
                        icon: Icons.receipt,
                      ),
                      const SizedBox(width: 8),
                      _SummaryCard(
                        title: 'Revenue',
                        value:
                            '৳ ${_summary?['totalRevenue']?.toStringAsFixed(0) ?? 0}',
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(width: 8),
                      _SummaryCard(
                        title: 'Avg Order',
                        value:
                            '৳ ${_summary?['avgOrderValue']?.toStringAsFixed(0) ?? 0}',
                        icon: Icons.analytics,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Revenue Chart
                  const Text(
                    'Revenue Trend',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: _revenueSeries.isEmpty
                        ? const Center(child: Text('No data for this period'))
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 &&
                                          value.toInt() <
                                              _revenueSeries.length) {
                                        final dateStr =
                                            _revenueSeries[value
                                                    .toInt()]['date']
                                                as String;
                                        final parts = dateStr.split('-');
                                        return Text(
                                          '${parts[2]}/${parts[1]}',
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _revenueSeries.asMap().entries.map((
                                    e,
                                  ) {
                                    return FlSpot(
                                      e.key.toDouble(),
                                      (e.value['revenue'] as num).toDouble(),
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  color: Colors.green,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                  // Top Products
                  const Text(
                    'Top Selling Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._topProducts.asMap().entries.map((e) {
                    final index = e.key + 1;
                    final product = e.value;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(product['_id']),
                      subtitle: Text('Qty: ${product['totalQty']}'),
                      trailing: Text(
                        '৳ ${product['totalRevenue']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.green[700], size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.green[900]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
