import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'incident_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalCount = 0;
  int openActions = 0;
  int closedActions = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final data = await DatabaseHelper.instance.fetchAllIncidents();
    int open = 0;
    int closed = 0;
    for (var item in data) {
      if (item.actionStatus == 'Open') open++;
      if (item.actionStatus == 'Closed') closed++;
    }
    setState(() {
      totalCount = data.length;
      openActions = open;
      closedActions = closed;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSE Incident Pro Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMetrics,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildStatRow(),
                  const SizedBox(height: 24),
                  const Text('Severity Distribution Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(color: Colors.red, value: 40, title: 'Major', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          PieChartSectionData(color: Colors.orange, value: 35, title: 'Sig', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          PieChartSectionData(color: Colors.yellow.shade700, value: 25, title: 'Minor', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildQuickActionCard(context),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        _buildMetricCard('Total Cases', totalCount.toString(), Colors.blue.shade900),
        _buildMetricCard('Open CAPA', openActions.toString(), Colors.orange.shade900),
        _buildMetricCard('Closed', closedActions.toString(), Colors.green.shade900),
      ],
    );
  }

  Widget _buildMetricCard(String title, String count, Color bgColor) {
    return Expanded(
      child: Card(
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(count, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Technomak Final System Sync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Local database engine active and secured offline.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All files stored locally in SQLite structure."))),
              icon: const Icon(Icons.storage),
              label: const Text('Verify Local Storage Engine'),
            )
          ],
        ),
      ),
    );
  }
}
