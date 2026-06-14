import 'package:flutter/material.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final res = await DatabaseHelper.instance.fetchAllIncidents();
    setState(() {
      _incidents = res;
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
              cross pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 0, text: "TECHNOMAK HSE INVESTIGATION REPORT"),
                pw.SizedBox(height: 10),
                pw.Text("Incident Ref: ${incident.refNumber}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("Date Logged: ${incident.dateReported}"),
                pw.Text("Severity Index: ${incident.severity}"),
                pw.Divider(),
                pw.Text("Location Details", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text("Project: ${incident.project} | Worksite: ${incident.worksite}"),
                pw.Text("Exact Spot: ${incident.exactLocation}"),
                pw.SizedBox(height: 15),
                pw.Text("Root Cause Engineering (5 Whys Analysis)", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text("Why 1 (Immediate): ${incident.why1}"),
                pw.Text("Why 2: ${incident.why2}"),
                pw.Text("Why 3: ${incident.why3}"),
                pw.Text("Why 4: ${incident.why4}"),
                pw.Text("Why 5 (Root System): ${incident.why5}"),
                pw.SizedBox(height: 15),
                pw.Text("Classification Vectors", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text("Direct Cause: ${incident.directCause}"),
                pw.Text("Systemic Root: ${incident.rootCause}"),
                pw.Divider(),
                pw.Text("Corrective Action Plan (CAPA)", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
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
      appBar: AppBar(title: const Text('Incident Register & PDF Engine')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _incidents.isEmpty
              ? const Center(child: Text("No records caught in local database file."))
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    itemCount: _incidents.length,
                    itemBuilder: (context, index) {
                      final item = _incidents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: ListTile(
                          title: Text("${item.refNumber} [${item.severity}]", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Project: ${item.project}\nRoot Cause: ${item.rootCause}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            onPressed: () => _generateAndSharePDF(item),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
