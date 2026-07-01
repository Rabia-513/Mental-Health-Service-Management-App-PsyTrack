import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PsychologistDashboardData {
  final String name;
  final int totalPatients;
  final int todaysSessions;
  final int pendingRequests;
  final int completedSessions;
  final List<Map<String, String>> todaysSchedule;

  PsychologistDashboardData({
    required this.name,
    required this.totalPatients,
    required this.todaysSessions,
    required this.pendingRequests,
    required this.completedSessions,
    required this.todaysSchedule,
  });
}

class PsychologistDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<int> getTotalPatients(String psychologistId) async {
    final snapshot = await _firestore
        .collection("patients")
        .where("psychologistId", isEqualTo: psychologistId)
        .get();

    return snapshot.docs.length;
  }
  Future<PsychologistDashboardData> loadDashboard() async {
    // TODO: Replace with Firestore

    return PsychologistDashboardData(
      name: "Haseeb Jamil",
      totalPatients: 0,
      todaysSessions: 0,
      pendingRequests: 0,
      completedSessions: 0,
      todaysSchedule: [],
    );
  }
}
