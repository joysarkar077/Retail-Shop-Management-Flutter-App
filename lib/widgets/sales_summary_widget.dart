import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class SalesSummaryWidget extends StatefulWidget {
  final String? shopId;
  final bool darkTheme;

  const SalesSummaryWidget({
    super.key, 
    this.shopId,
    this.darkTheme = true,
  });

  @override
  State<SalesSummaryWidget> createState() => _SalesSummaryWidgetState();
}

class _SalesSummaryWidgetState extends State<SalesSummaryWidget> {
  bool _isLoading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _isLoading = true);
    try {
      final summary = await AnalyticsService.getSummary(
        period: 'today',
        shopId: widget.shopId,
      );
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.darkTheme ? Colors.white : Colors.black87;
    final subtitleColor = widget.darkTheme ? Colors.white70 : Colors.black54;
    final cardColor = widget.darkTheme ? Colors.white.withOpacity(0.2) : Colors.grey[200];

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(
            color: widget.darkTheme ? Colors.white : Colors.indigo,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Snapshot',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniCard(
                'Orders',
                '${_summary?['orderCount'] ?? 0}',
                Icons.receipt,
                textColor,
                subtitleColor,
                cardColor,
              ),
              const SizedBox(width: 8),
              _buildMiniCard(
                'Revenue',
                '৳ ${_summary?['totalRevenue']?.toStringAsFixed(0) ?? 0}',
                Icons.attach_money,
                textColor,
                subtitleColor,
                cardColor,
              ),
              const SizedBox(width: 8),
              _buildMiniCard(
                'Avg Order',
                '৳ ${_summary?['avgOrderValue']?.toStringAsFixed(0) ?? 0}',
                Icons.analytics,
                textColor,
                subtitleColor,
                cardColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(
    String title, 
    String value, 
    IconData icon,
    Color textColor,
    Color subtitleColor,
    Color? cardColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: subtitleColor),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
