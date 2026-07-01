const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendAppointmentNotification = functions.firestore
.document("appointments/{appointmentId}")
.onCreate(async (snap, context) => {

  const appointment = snap.data();

  const psychologistId = appointment.psychologistId;

  const psychologistDoc = await admin.firestore()
  .collection("psychologists")
  .doc(psychologistId)
  .get();

  if (!psychologistDoc.exists) {
    console.log("Psychologist not found");
    return;
  }

  const fcmToken = psychologistDoc.data().fcmToken;

  if (!fcmToken) {
    console.log("No FCM token found");
    return;
  }

  const message = {
    notification: {
      title: "New Appointment",
      body: "You have a new appointment request",
    },
    token: fcmToken,
  };

  await admin.messaging().send(message);

  console.log("Notification sent");
});