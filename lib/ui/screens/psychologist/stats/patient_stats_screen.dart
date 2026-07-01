import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../common/psychologist_main_screen.dart';
import '../../styles/colors.dart';

class PatientStatsScreen extends StatefulWidget {
  const PatientStatsScreen({super.key});

  @override
  State<PatientStatsScreen> createState() => _PatientStatsScreenState();
}

class _PatientStatsScreenState extends State<PatientStatsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String patientUid = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    patientUid = args["patientUid"];
  }

  /// MOOD STREAM
  Stream<QuerySnapshot> getMoodLogs() {
    return _firestore
        .collection("patients")
        .doc(patientUid)
        .collection("mood_checkins")
        .orderBy("dateId")
        .snapshots();
  }

  /// SESSION PROGRESS
  Stream<QuerySnapshot> getPrescriptionProgress() {
    return _firestore
        .collection("prescriptions")
        .where("patientUid", isEqualTo: patientUid)
        .snapshots();
  }

  /// ================= UI =================
  int _moodToNumber(String mood) {
    switch (mood) {
      case "lazy and sick": return 1;
      case "sad": return 2;
      case "angry": return 3;
      case "neutral": return 4;
      case "good": return 5;
      case "happy": return 6;
      case "very_happy": return 7;
      default: return 4;
    }
  }  @override
  Widget build(BuildContext context) {
    return PsychologistMainScreen(
        selectedIndex: 1, // stats

        child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Patient Stats"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// MOOD DATA
          StreamBuilder<QuerySnapshot>(
            stream: getMoodLogs(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final moods = snapshot.data!.docs;

              return Column(
                children: [
                  _moodTrend(moods),
                  const SizedBox(height: 20),
                  _intensityTrend(moods),
                  const SizedBox(height: 20),
                  _moodDistribution(moods),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          /// SESSION PROGRESS
          StreamBuilder<QuerySnapshot>(
            stream: getPrescriptionProgress(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.docs;

              return _sessionProgress(data);
            },
          ),
        ],
      ),
    ));
  }

  /// =============================
  /// 1️⃣ MOOD TREND (FIXED)
  /// =============================
  Widget _moodTrend(List moods) {

    List<FlSpot> spots = [];

    for (int i = 0; i < moods.length; i++) {
      final moodKey = moods[i]["moodKey"] ?? "neutral";
      final moodValue = _moodToNumber(moodKey);
      spots.add(FlSpot(i.toDouble(), moodValue.toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffE8F1EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

           Text(
            "Mood Type Over Time",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),          ),

          const SizedBox(height: 4),

           Text(
            "Tracks emotional state day by day",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 1,
                maxY: 8,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),

                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),

                titlesData: FlTitlesData(

                  /// 🔹 LEFT (MOOD NAMES)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      interval: 1,
                      getTitlesWidget: (value, _) {

                        switch (value.toInt()) {
                          case 1: return const Text("Lazy and sick");
                          case 2: return const Text("Sad");
                          case 3: return const Text("Angry");
                          case 4: return const Text("Neutral");
                          case 5: return const Text("Good");
                          case 6: return const Text("Happy");
                          case 7: return const Text("Very Happy");
                        }
                        return const Text("");
                      },
                    ),
                  ),

                  /// 🔹 BOTTOM (DATES SIMPLIFIED)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {

                        int index = value.toInt();

                        if (index >= moods.length) return const Text("");

                        String date = moods[index]["dateId"] ?? "";

                        if (date.length < 10) return const Text("");

                        String day = date.substring(8, 10);
                        String month = date.substring(5, 7);

                        return Text("$day/$month");
                      },
                    ),
                  ),

                  /// REMOVE TOP + RIGHT
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _intensityTrend(List moods) {

    List<FlSpot> spots = [];

    for (int i = 0; i < moods.length; i++) {
      final intensity = (moods[i]["intensity"] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), intensity));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffE8F1EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

            Text(
            "Mood Intensity",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),          ),

          const SizedBox(height: 4),

          Text(
            "How strong the emotions were (1–5)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 1,
                maxY: 5,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),

                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Text("D${value.toInt()+1}");
                      },
                    ),
                  ),

                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 4,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }  /// =============================
  /// 2️⃣ MOOD DISTRIBUTION
  /// =============================
  Widget _moodDistribution(List moods) {

    Map<String, int> count = {};

    for (var m in moods) {
      String mood = m["moodKey"] ?? "unknown";
      count[mood] = (count[mood] ?? 0) + 1;
    }

    final colors = {
      "sad": Colors.blue,
      "good":Colors.amber,
      "angry": Colors.red,
      "neutral": Colors.grey,
      "happy": Colors.green,
      "very_happy": Colors.greenAccent,
      "sick_lazy": Colors.deepPurple,
    };

    List<PieChartSectionData> sections = [];

    count.forEach((mood, value) {
      sections.add(
        PieChartSectionData(
          value: value.toDouble(),
          title: mood,
          color: colors[mood] ?? AppColors.text(context),
          radius: 70,
        ),
      );
    });

    return _card(
      "Mood Distribution",
      "Which moods appear most",
      PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  /// =============================
  /// 3️⃣ SESSION PROGRESS
  /// =============================
  Widget _sessionProgress(List data) {

    List<double> progress = data.map<double>((d) {
      final v = d.data() as Map<String, dynamic>;
      final val = v["sessionImprovement"] ?? 0;
      return (val is int) ? val.toDouble() : val;
    }).toList();

    if (progress.isEmpty) {
      return const Text("No session data");
    }

    return _card(
      "Therapy Progress",
      "Improvement per session",
      BarChart(
        BarChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          titlesData: FlTitlesData(

            /// X AXIS (SESSION NUMBER)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Text("S${value.toInt()+1}");
                },
              ),
            ),

            /// Y AXIS (IMPROVEMENT %)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, _) {
                  return Text("${value.toInt()}%");
                },
              ),
            ),

            /// REMOVE EXTRA NOISE
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          barGroups: progress.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: e.value > 60
                      ? Colors.green
                      : e.value > 30
                      ? Colors.orange
                      : Colors.red,
                  width: 16,
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// =============================
  /// UI CARD WRAPPER
  /// =============================
  Widget _card(String title, String subtitle, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffE8F1EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}