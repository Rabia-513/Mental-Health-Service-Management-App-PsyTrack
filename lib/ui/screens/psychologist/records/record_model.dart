class PatientRecord {
  final String id;
  final String patientName;
  final String diagnosis;
  final String prescription;
  final String sessionType;
  final String date;
  final String pdfUrl;

  PatientRecord({
    required this.id,
    required this.patientName,
    required this.diagnosis,
    required this.prescription,
    required this.sessionType,
    required this.date,
    required this.pdfUrl,
  });

  factory PatientRecord.fromFirestore(String id, Map<String, dynamic> data) {
    return PatientRecord(
      id: id,
      patientName: data['patientName'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      prescription: data['prescription'] ?? '',
      sessionType: data['sessionType'] ?? '',
      date: data['recordDate'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
    );
  }
}