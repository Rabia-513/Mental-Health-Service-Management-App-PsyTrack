import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/routes.dart';
import '../../../../app/translations.dart';
import '../../styles/colors.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String psychologistId;
  final String psychologistName;

  const BookAppointmentScreen({super.key,required this.psychologistId,
    required this.psychologistName,});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  String selectedTime = "";

  final Color mainColor = const Color(0xff4E7D7A);

  final List<String> morningSlots = [
    "9:10 AM",
    "10:00 AM",
    "10:30 AM",
    "11:30 AM",
    "12:00 PM"
  ];

  final List<String> afternoonSlots = [
    "12:10 PM",
    "12:50 PM",
    "1:30 PM",
    "2:10 PM",
    "3:00 PM",
    "3:30 PM",
    "4:00 PM",
    "4:50 PM",
    "5:15 PM"
  ];

  final List<String> eveningSlots = [
    "6:10 PM",
    "7:00 PM",
    "7:30 PM",
    "8:10 PM",
    "8:30 PM"
  ];
  Future<void> pickCustomTime() async {

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {

      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? "AM" : "PM";

      String formatted = "$hour:$minute $period";

      setState(() {
        selectedTime = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF3F3F3),

    body: Directionality(
    textDirection:
    Translations.isUrdu ? TextDirection.rtl : TextDirection.ltr,
    child: Column(
        children: [

          /// TOP HEADER
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 16,
              right: 16,
              bottom: 25,
            ),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [

                /// TITLE + BACK
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child:  Icon(Icons.arrow_back_ios,
                          color: AppColors.card(context)),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          Translations.t("Book Appointment"),
                          style:  TextStyle(
                            fontSize: 22,
                            color: AppColors.card(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20)
                  ],
                ),

                const SizedBox(height: 20),

                /// DATE + MONTH BOX
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    _pill(
                        "${selectedDay.day}/${selectedDay.month}/${selectedDay.year}"
                    ),

                    _pill(Translations.t("month")),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// CALENDAR CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime(2030),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDay, day);
                  },
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDay = selected;
                      focusedDay = focused;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: mainColor.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// TIME SLOTS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _sectionTitle(Translations.t("morningSlots")),
                  _slotGrid(morningSlots),

                  const SizedBox(height: 20),

                  _sectionTitle(Translations.t("afternoonSlots")),
                  _slotGrid(afternoonSlots),

                  const SizedBox(height: 20),

                  _sectionTitle(Translations.t("eveningSlots")),
                  _slotGrid(eveningSlots),

                  const SizedBox(height: 10),

                  /// CUSTOM TIME BUTTON
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.card(context),
                      foregroundColor: mainColor,
                      elevation: 0,
                      side: BorderSide(color: mainColor),
                    ),
                    onPressed: pickCustomTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(Translations.t("customTime")),
                  ),

                  const SizedBox(height: 30),

                  /// BOOK BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedTime.isEmpty) {
                          return;
                        }

                        Navigator.pushNamed(
                          context,
                          AppRoutes.appointmentConfirm,
                          arguments: {
                            "psychologistId": widget.psychologistId,
                            "psychologistName": widget.psychologistName,
                            "date":
                            "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}",
                            "time": selectedTime,
                          },
                        );
                      },                      child: Text(
                        Translations.t("book"),
                        style: TextStyle(fontSize: 18,color:AppColors.primary),
                      ),

                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }

  /// SLOT GRID
  Widget _slotGrid(List<String> slots) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((time) {

        bool selected = selectedTime == time;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTime = time;
            });
          },
          child: Container(
            width: 100,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? mainColor : AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: selected ? AppColors.card(context) : AppColors.text(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );

      }).toList(),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// DATE PILL
  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}