import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'incident_model.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IncidentFormScreen extends StatefulWidget {
  const IncidentFormScreen({super.key});

  @override
  State<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends State<IncidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _projectController = TextEditingController();
  final _worksiteController = TextEditingController();
  final _deptController = TextEditingController();
  final _locationController = TextEditingController();
  final _personNameController = TextEditingController();
  final _personCompanyController = TextEditingController();
  final _why1Controller = TextEditingController();
  final _why2Controller = TextEditingController();
  final _why3Controller = TextEditingController();
  final _why4Controller = TextEditingController();
  final _why5Controller = TextEditingController();
  final _actionItemController = TextEditingController();
  final _actionAssigneeController = TextEditingController();

  String _selectedSeverity = 'Minor';
  String _selectedDirectCause = 'Unsafe Act - Failure to secure';
  String _selectedRootCause = 'Inadequate Training Management';
  String _capturedImagePath = '';

  final List<String> _directCauses = [
    'Unsafe Act - Failure to secure',
    'Unsafe Act - Operating at improper speed',
    'Unsafe Condition - Inadequate guards',
    'Unsafe Condition - Defective tools/machinery'
  ];

  final List<String> _rootCauses = [
    'Inadequate Training Management',
    'Deficient Maintenance Standards',
    'Inadequate Risk Assessment System',
    'Failure to Monitor Compliance'
  ];

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      setState(() {
        _capturedImagePath = image.path;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uniqueRef = 'TMK-INC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final todayDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      final newIncident = Incident(
        refNumber: uniqueRef,
        dateReported: todayDate,
        severity: _selectedSeverity,
        classifications: 'Site Incident Monitoring Asset',
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
        imagePath: _capturedImagePath,
      );

      await DatabaseHelper.instance.insertIncident(newIncident);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved locally: $uniqueRef')));
      _formKey.currentState!.reset();
      setState(() { _capturedImagePath = ''; });
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
            TextFormField(controller: _worksiteController, decoration: const InputDecoration(labelText: 'Worksite Location'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _deptController, decoration: const InputDecoration(labelText: 'Department'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Exact Spot / GPS Description'), validator: (v) => v!.isEmpty ? 'Required' : null),
            
            DropdownButtonFormField<String>(
              value: _selectedSeverity,
              decoration: const InputDecoration(labelText: 'Severity Level'),
              items: ['Minor', 'Significant', 'Major'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSeverity = val!),
            ),

            _buildSectionHeader('Evidence Upload & Media Capture'),
            _capturedImagePath.isEmpty
                ? ElevatedButton.icon(onPressed: _pickImageFromCamera, icon: const Icon(Icons.camera_alt), label: const Text("Launch Site Camera"))
                : Column(
                    children: [
                      Image.file(File(_capturedImagePath), height: 150),
                      TextButton(onPressed: () => setState(() => _capturedImagePath = ''), child: const Text("Clear Photo"))
                    ],
                  ),

            _buildSectionHeader('Personnel Record'),
            TextFormField(controller: _personNameController, decoration: const InputDecoration(labelText: 'Injured/Involved Person'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _personCompanyController, decoration: const InputDecoration(labelText: 'Employer / Subcontractor'), validator: (v) => v!.isEmpty ? 'Required' : null),

            _buildSectionHeader('Appendix F - Root Cause Analysis (5 Whys)'),
            TextFormField(controller: _why1Controller, decoration: const InputDecoration(labelText: 'Why 1')),
            TextFormField(controller: _why2Controller, decoration: const InputDecoration(labelText: 'Why 2')),
            TextFormField(controller: _why3Controller, decoration: const InputDecoration(labelText: 'Why 3')),
            TextFormField(controller: _why4Controller, decoration: const InputDecoration(labelText: 'Why 4')),
            TextFormField(controller: _why5Controller, decoration: const InputDecoration(labelText: 'Why 5')),

            _buildSectionHeader('Cause Classification Matrix'),
            DropdownButtonFormField<String>(
              value: _selectedDirectCause,
              decoration: const InputDecoration(labelText: 'Direct Cause'),
              items: _directCauses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedDirectCause = val!),
            ),
            DropdownButtonFormField<String>(
              value: _selectedRootCause,
              decoration: const InputDecoration(labelText: 'Root Cause System'),
              items: _rootCauses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedRootCause = val!),
            ),

            _buildSectionHeader('Corrective Action (CAPA)'),
            TextFormField(controller: _actionItemController, decoration: const InputDecoration(labelText: 'Remedial Action Task'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _actionAssigneeController, decoration: const InputDecoration(labelText: 'Action Owner'), validator: (v) => v!.isEmpty ? 'Required' : null),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F3A60), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Commit Report to Secure Local Database', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 40),
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
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
          const Divider(),
        ],
      ),
    );
  }
}
