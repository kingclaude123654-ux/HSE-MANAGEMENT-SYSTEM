class Incident {
  int? id;
  String refNumber;
  String dateReported;
  String severity;
  String classifications; // JSON or Comma-separated
  String project;
  String worksite;
  String department;
  String exactLocation;
  
  // Person Involved
  String personName;
  String personCompany;
  
  // 5 Why Analysis
  String why1;
  String why2;
  String why3;
  String why4;
  String why5;
  
  // Investigation Root Causes (Appendix F)
  String directCause;
  String rootCause;
  
  // Corrective Action
  String actionItem;
  String actionAssignee;
  String actionStatus; // Open, Closed, Overdue

  Incident({
    this.id,
    required this.refNumber,
    required this.dateReported,
    required this.severity,
    required this.classifications,
    required this.project,
    required this.worksite,
    required this.department,
    required this.exactLocation,
    required this.personName,
    required this.personCompany,
    required this.why1,
    required this.why2,
    required this.why3,
    required this.why4,
    required this.why5,
    required this.directCause,
    required this.rootCause,
    required this.actionItem,
    required this.actionAssignee,
    required this.actionStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'refNumber': refNumber,
      'dateReported': dateReported,
      'severity': severity,
      'classifications': classifications,
      'project': project,
      'worksite': worksite,
      'department': department,
      'exactLocation': exactLocation,
      'personName': personName,
      'personCompany': personCompany,
      'why1': why1,
      'why2': why2,
      'why3': why3,
      'why4': why4,
      'why5': why5,
      'directCause': directCause,
      'rootCause': rootCause,
      'actionItem': actionItem,
      'actionAssignee': actionAssignee,
      'actionStatus': actionStatus,
    };
  }

  factory Incident.fromMap(Map<String, dynamic> map) {
    return Incident(
      id: map['id'],
      refNumber: map['refNumber'],
      dateReported: map['dateReported'],
      severity. : map['severity'],
      classifications: map['classifications'],
      project: map['project'],
      worksite: map['worksite'],
      department: map['department'],
      exactLocation: map['exactLocation'],
      personName: map['personName'],
      personCompany: map['personCompany'],
      why1: map['why1'],
      why2: map['why2'],
      why3: map['why3'],
      why4: map['why4'],
      why5: map['why5'],
      directCause: map['directCause'],
      rootCause: map['rootCause'],
      actionItem: map['actionItem'],
      actionAssignee: map['actionAssignee'],
      actionStatus: map['actionStatus'],
    );
  }
}
