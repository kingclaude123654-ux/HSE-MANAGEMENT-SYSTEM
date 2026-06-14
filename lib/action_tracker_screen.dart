import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'incident_model.dart';

class ActionTrackerScreen extends StatefulWidget {
  const ActionTrackerScreen({super.key});

  @override
  State<ActionTrackerScreen> createState() => _ActionTrackerScreenState();
}

class _ActionTrackerScreenState extends State<ActionTrackerScreen> {
  late Future<List<Incident>> _actionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshActions();
  }

  void _refreshActions() {
    setState(() {
      _actionsFuture = DatabaseHelper.instance.fetchAllIncidents();
    });
  }

  void _toggleStatus(int id, String currentStatus) async {
    String netStatus = (currentStatus == 'Open') ? 'Closed' : 'Open';
    await DatabaseHelper.instance.updateIncidentAction(id, netStatus);
    _refreshActions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CAPA Remedial Actions Tracker')),
      body: FutureBuilder<List<Incident>>(
        future: _actionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No critical action items listed in database framework.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isOpen = item.actionStatus == 'Open';

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(item.actionItem, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Owner: ${item.actionAssignee} | Ref: ${item.refNumber}\nRoot Cause: ${item.rootCause}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOpen ? Colors.amber.shade800 : Colors.green.shade800,
                    ),
                    onPressed: () => _toggleStatus(item.id!, item.actionStatus),
                    child: Text(item.actionStatus, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
