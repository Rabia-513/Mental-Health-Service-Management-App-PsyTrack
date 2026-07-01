import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class PatientGraphs extends StatefulWidget {
  const PatientGraphs({super.key});

  @override
  State<PatientGraphs> createState() => _PatientGraphsState();
}

class _PatientGraphsState extends State<PatientGraphs> {

  final uid = FirebaseAuth.instance.currentUser!.uid;

  // ================= INTENSITY LABEL =================
  String getMoodLabel(double value) {
    switch (value.toInt()) {
      case 7: return "Very Happy";
      case 6: return "Happy";
      case 5: return "Good";
      case 4: return "Neutral";
      case 3: return "Sad";
      case 2: return "Angry";
      case 1: return "Sick & Lazy";
      default: return "";
    }
  }
  double moodToY(String mood) {
    switch (mood) {
      case "very_happy": return 7;
      case "happy": return 6;
      case "good": return 5;
      case "neutral": return 4;
      case "sad": return 3;
      case "angry": return 2;
      case "sick_lazy": return 1;
      default: return 4;
    }
  }
  // ================= COLORS =================
  Color getMoodColor(String mood) {
    switch (mood) {
      case "happy": return Colors.green;
      case "sad": return Colors.blue;
      case "neutral": return Colors.grey;
      case "very_happy": return Colors.teal;
      case "angry": return Colors.red;
      case "sick_lazy": return Colors.orange;
      default: return Colors.teal;
    }
  }

  // ================= LINE DATA =================
  List<FlSpot> getSpots(List<QueryDocumentSnapshot> docs) {
    return docs.asMap().entries.map((entry) {
      int index = entry.key;

      final data = entry.value.data() as Map<String, dynamic>?;

      if (data == null) return FlSpot(index.toDouble(), 0);

      String mood = data['moodKey'] ?? "neutral";

      double y = moodToY(mood);

      return FlSpot(index.toDouble(), y);
    }).toList();
  }
  // ================= DATES =================
  List<String> getDates(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      DateTime date = DateTime.parse(doc['dateId']);
      return "${date.day}/${date.month}";
    }).toList();
  }
  // ================= PIE =================
  Map<String, int> getMoodCount(List<QueryDocumentSnapshot> docs) {
    Map<String, int> count = {};
    for (var doc in docs) {
      String mood = doc['moodKey'];
      count[mood] = (count[mood] ?? 0) + 1;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),

      appBar: AppBar(
        title: const Text("Mood Insights"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF3D6766),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(uid)
            .collection('mood_checkins')
            .orderBy('dateId')
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No data"));
          }



          final dates = getDates(docs);

          titlesData: FlTitlesData(

            // ===== LEFT (MOOD NAMES ONLY) =====
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    getMoodLabel(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),

            // ===== BOTTOM (DATES FROM FIREBASE) =====
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();

                  if (index >= dates.length) return const Text("");

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dates[index],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // ================= LINE GRAPH =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Mood Type Over Time",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      const Text("Tracks emotional state day by day"),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            minY: 1,
                            maxY: 7,
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),

                            titlesData: FlTitlesData(

                              // LEFT SIDE TEXT
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      getMoodLabel(value),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),

                              // BOTTOM DATES
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (docs.length > 1)
                                      ? (getSpots(docs)[1].x - getSpots(docs)[0].x)
                                      : 1,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();

                                    if (index >= dates.length) return const Text("");

                                    return Text(
                                      dates[index],
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),                            ),

                            lineBarsData: [
                              LineChartBarData(
                                spots: getSpots(docs),
                                isCurved: true,
                                color: Colors.teal,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= PIE =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Mood Distribution",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      const Text("Which moods appear most"),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 40,
                            sections: getMoodCount(docs).entries.map((entry) {
                              return PieChartSectionData(
                                value: entry.value.toDouble(),
                                title: entry.key.replaceAll("_", " "),
                                color: getMoodColor(entry.key),
                                radius: 70,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}