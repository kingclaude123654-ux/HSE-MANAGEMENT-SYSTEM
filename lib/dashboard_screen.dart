import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'incident_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Incident> _incidents = [];
  int totalCount = 0;
  int openActions = 0;
  int closedActions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final res = await DatabaseHelper.instance.fetchAllIncidents();
    int open = 0;
    int closed = 0;
    for (var item in res) {
      if (item.actionStatus == 'Open') open++;
      if (item.actionStatus == 'Closed') closed++;
    }
    setState(() {
      _incidents = res;
      totalCount = res.length;
      openActions = open;
      closedActions = closed;
      _isLoading = false;
    });
  }

  Future<void> _generateAndSharePDF(Incident incident) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 0, text: "INCIDENT INVESTIGATION REPORT"),
                pw.SizedBox(height: 10),
                pw.Text("Incident Ref: ${incident.refNumber}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("Date Logged: ${incident.dateReported}"),
                pw.Text("Severity Index: ${incident.severity}"),
                pw.Divider(),
                pw.Text("Location Details", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text("Project: ${incident.project} | Worksite: ${incident.worksite}"),
                pw.Text("Exact Spot: ${incident.exactLocation}"),
                pw.SizedBox(height: 12),
                pw.Text("Root Cause Engineering (5 Whys Analysis)", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text("Why 1 (Immediate): ${incident.why1}"),
                pw.Text("Why 2: ${incident.why2}"),
                pw.Text("Why 3: ${incident.why3}"),
                pw.Text("Why 4: ${incident.why4}"),
                pw.Text("Why 5 (Root System): ${incident.why5}"),
                pw.SizedBox(height: 12),
                pw.Text("Classification Vectors", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text("Direct Cause: ${incident.directCause}"),
                pw.Text("Systemic Root: ${incident.rootCause}"),
                pw.Divider(),
                pw.Text("Corrective Action Plan (CAPA)", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text("Remedial Instruction: ${incident.actionItem}"),
                pw.Text("Assigned Action Owner: ${incident.actionAssignee}"),
                pw.Text("Current Safety Status: ${incident.actionStatus}"),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: '${incident.refNumber}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSE Dashboard & Reports', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildStatRow(),
                  const SizedBox(height: 24),
                  const Text('Severity Metrics Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(color: Colors.red.shade700, value: 40, title: 'Major', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          PieChartSectionData(color: Colors.orange.shade700, value: 35, title: 'Sig', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          PieChartSectionData(color: Colors.yellow.shade800, value: 25, title: 'Minor', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Recent Incident Records Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _incidents.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text("No records caught in local database.")),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _incidents.length,
                          itemBuilder: (context, index) {
                            final item = _incidents[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text("${item.refNumber} [${item.severity}]", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text("Project: ${item.project}\nRoot Cause: ${item.rootCause}", style: const TextStyle(fontSize: 12)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                  onPressed: () => _generateAndSharePDF(item),
                                ),
                              ),
                            );
                          },
                        ),
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
