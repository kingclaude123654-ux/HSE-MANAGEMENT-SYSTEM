import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'incident_model.dart';
import 'package:intl/intl.dart';

class IncidentFormScreen extends StatefulWidget {
  const IncidentFormScreen({super.key});

  @override
  State<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends State<IncidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic Info Fields
  final _projectController = TextEditingController();
  final _worksiteController = TextEditingController();
  final _deptController = TextEditingController();
  final _locationController = TextEditingController();
  final _personNameController = TextEditingController();
  final _personCompanyController = TextEditingController();

  // 5 Whys Fields
  final _why1Controller = TextEditingController();
  final _why2Controller = TextEditingController();
  final _why3Controller = TextEditingController();
  final _why4Controller = TextEditingController();
  final _why5Controller = TextEditingController();

  // Actions Fields
  final _actionItemController = TextEditingController();
  final _actionAssigneeController = TextEditingController();

  String _selectedSeverity = 'Minor';
  String _selectedDirectCause = 'Unsafe Act - Failure to secure';
  String _selectedRootCause = 'Inadequate Training Management';

  final List<String> _appendixFDirectCauses = [
    'Unsafe Act - Failure to secure',
    'Unsafe Act - Operating at improper speed',
    'Unsafe Condition - Inadequate guards',
    'Unsafe Condition - Defective tools/machinery'
  ];

  final List<String> _appendixFRootCauses = [
    'Inadequate Training Management',
    'Deficient Maintenance Standards',
    'Inadequate Risk Assessment System',
    'Failure to Monitor Compliance'
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uniqueRef = 'TMK-INC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final todayDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      final newIncident = Incident(
        refNumber: uniqueRef,
        dateReported: todayDate,
        severity: _selectedSeverity,
        classifications: 'LTI, Property Damage',
        project: _projectController.text,
        worksite: _worksiteController.text,
        department: _deptController.text,
        exactLocation: _locationController.text,
        personName: _personNameController.text,
        personCompany: _personCompanyController.text,
        why1: _why1Controller.text,
        why2: _why2Controller.text,
        why3: _why3Controller.text,
        why4: _why4Controller.text,
        why5: _why5Controller.text,
        directCause: _selectedDirectCause,
        rootCause: _selectedRootCause,
        actionItem: _actionItemController.text,
        actionAssignee: _actionAssigneeController.text,
        actionStatus: 'Open',
      );

      await DatabaseHelper.instance.insertIncident(newIncident);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved locally: $uniqueRef')),
      );

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Technomak Incident')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader('General Info & Location'),
            TextFormField(controller: _projectController, decoration: const InputDecoration(labelText: 'Project Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _worksiteController, decoration: const InputDecoration(labelText: 'Worksite location'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _deptController, decoration: const InputDecoration(labelText: 'Department'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Exact GPS/Worksite Spot'), validator: (v) => v!.isEmpty ? 'Required' : null),
            
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSeverity,
              decoration: const InputDecoration(labelText: 'Severity Level'),
              items: ['Minor', 'Significant', 'Major'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSeverity = val!),
            ),

            _buildSectionHeader('People Involved (HSE Register)'),
            TextFormField(controller: _personNameController, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _personCompanyController, decoration: const InputDecoration(labelText: 'Company / Contractor Name'), validator: (v) => v!.isEmpty ? 'Required' : null),

            _buildSectionHeader('Appendix F - Root Cause Analysis (5 Whys)'),
            TextFormField(controller: _why1Controller, decoration: const InputDecoration(labelText: 'Why 1: Immediate Cause')),
            TextFormField(controller: _why2Controller, decoration: const InputDecoration(labelText: 'Why 2: Underlying Cause')),
            TextFormField(controller: _why3Controller, decoration: const InputDecoration(labelText: 'Why 3: Management Cause')),
            TextFormField(controller: _why4Controller, decoration: const InputDecoration(labelText: 'Why 4: System Cause')),
            TextFormField(controller: _why5Controller, decoration: const InputDecoration(labelText: 'Why 5: Root Cause Root System')),

            _buildSectionHeader('Direct vs Root Classification'),
            DropdownButtonFormField<String>(
              value: _selectedDirectCause,
              decoration: const InputDecoration(labelText: 'Direct Cause Matrix'),
              items: _appendixFDirectCauses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedDirectCause = val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRootCause,
              decoration: const InputDecoration(labelText: 'Systemic Root Cause (Appendix F)'),
              items: _appendixFRootCauses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedRootCause = val!),
            ),

            _buildSectionHeader('Corrective & Preventative Actions (CAPA)'),
            TextFormField(controller: _actionItemController, decoration: const InputDecoration(labelText: 'Action Plan Detail Description'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _actionAssigneeController, decoration: const InputDecoration(labelText: 'Action Assignee / Owner'), validator: (v) => v!.isEmpty ? 'Required' : null),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Save Form to Local SQLite Engine', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
          const Divider(),
        ],
      ),
    );
  }
}
