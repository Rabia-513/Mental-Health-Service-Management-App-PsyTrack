import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../../data/services/psychologist_service.dart';
import '../../styles/colors.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool isSaving = false;

  String timeZone = "GMT+5 Pakistan";

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  final List<String> timeSlots = [
    "10:00 AM – 4:00 PM",
    "11:00 AM – 6:00 PM",
    "9:00 AM – 5:00 PM",
    "Custom",
  ];
  late Map<String, Map<String, dynamic>> weeklySchedule;

  @override
  void initState() {
    super.initState();
    weeklySchedule = {
      for (var d in days)
        d: {
          "enabled": false,
          "time": null,
        }
    };
    loadAvailability();
  }
  TimeOfDay _getInitialTime(String? time) {
    if (time == null) return TimeOfDay.now();

    try {
      final start = time.split("–")[0].trim();
      final parsed = TimeOfDay(
        hour: DateFormat.jm().parse(start).hour,
        minute: DateFormat.jm().parse(start).minute,
      );
      return parsed;
    } catch (_) {
      return TimeOfDay.now();
    }
  }
  // ================= LOAD =================
  Future<void> loadAvailability() async {
    final data = await PsychologistService.fetchAvailability(uid);

    if (data != null && data['weeklySchedule'] != null) {
      final schedule = Map<String, dynamic>.from(data['weeklySchedule']);

      for (var day in days) {
        if (schedule[day] != null) {
          weeklySchedule[day] = {
            "enabled": schedule[day]['enabled'] ?? false,
            "time": schedule[day]['enabled'] == true
                ? "${schedule[day]['start']} – ${schedule[day]['end']}"
                : null,
          };
        }
      }

      timeZone = data['timezone'] ?? timeZone;
    }

    setState(() {});
  }

  // ================= SAVE =================
  Future<void> saveAvailability() async {
    setState(() => isSaving = true);

    final Map<String, dynamic> formattedSchedule = {};

    weeklySchedule.forEach((day, value) {
      if (value['enabled'] == true && value['time'] != null) {
        final parts = value['time'].split("–");
        formattedSchedule[day] = {
          "enabled": true,
          "start": parts[0].trim(),
          "end": parts[1].trim(),
        };
      } else {
        formattedSchedule[day] = {
          "enabled": false,
        };
      }
    });

    await PsychologistService.updateAvailability(uid, {
      "timezone": timeZone,
      "weeklySchedule": formattedSchedule,
    });

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Availability updated")),
    );
  }

  // ================= DAY TILE =================
  Widget dayTile(String day) {
    final enabled = weeklySchedule[day]!['enabled'];
    final time = weeklySchedule[day]!['time'];


    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.accent.withOpacity(0.6)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(
            child: SwitchListTile(
              title: Text(day,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? AppColors.primary
                          : Colors.grey)),
              value: enabled,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() {
                  weeklySchedule[day]!['enabled'] = v;
                  if (!v) weeklySchedule[day]!['time'] = null;
                });
              },
            ),
          ),
          if (enabled)
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: timeSlots.contains(time) ? time : null,
                hint: const Text("Select Time"),
                items: timeSlots
                    .map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t),
                ))
                    .toList(),
                onChanged: (v) async {
                  if (v == "Custom") {
                    final start = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.primary, // header + selected
                              onPrimary: Colors.white,
                              onSurface: AppColors.text(context),
                            ),
                            timePickerTheme: const TimePickerThemeData(
                              dialHandColor: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (start == null) return;

                    final end = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay. now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.primary, // header + selected
                              onPrimary: Colors.white,
                              onSurface: AppColors.text(context),
                            ),
                            timePickerTheme: const TimePickerThemeData(
                              dialHandColor: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (end == null) return;

                    final formatted =
                        "${start.format(context)} – ${end.format(context)}";

                    setState(() {
                      weeklySchedule[day]!['time'] = formatted;
                    });
                  } else {
                    setState(() {
                      weeklySchedule[day]!['time'] = v;
                    });
                  }
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text("OFF"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text("Availability"),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Schedule",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
            const SizedBox(height: 12),

            ...days.map(dayTile),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Time Zone",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: timeZone,
                  items: const [
                    DropdownMenuItem(
                        value: "GMT+5 Pakistan",
                        child: Text("GMT+5 Pakistan")),
                  ],
                  onChanged: (v) =>
                      setState(() => timeZone = v!),
                )
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ?  CircularProgressIndicator(
                  color: Theme.of(context).cardColor,
                  strokeWidth: 2,
                )
                    :  Text("Save Changes",
                    style: TextStyle(color: Theme.of(context).cardColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
