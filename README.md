# PsyTrack - Mental Health Service Management App

PsyTrack is a digital mental health service management application developed as a Final Year Project. The project aims to support psychologists, patients, and family members through a secure and organized mobile platform for mental health care management.

The system helps reduce manual paperwork by providing digital patient records, psychological assessments, appointment scheduling, reminders, prescription/report generation, mood tracking, and family involvement in the care process.

## Project Title

**A Digital Framework for Mental Health Service Management and Patient Support**

## About the Project

Mental health clinics in Pakistan often rely on manual records, handwritten notes, paper-based assessments, and manual appointment scheduling. This can cause problems such as missing records, poor follow-up, delayed decisions, and weak communication between psychologists and patients.

PsyTrack provides a centralized digital platform where psychologists can manage patients, conduct assessments, maintain clinical records, schedule sessions, generate reports, and track patient progress. Patients can book appointments, view their progress, perform mood check-ins, access wellness exercises, and receive reminders. Family members can also monitor patient progress with consent.

## Key Features

### Authentication and Role Management
- Secure user registration and login
- Role-based access for:
  - Patient
  - Psychologist
  - Family member
- Email verification support

### Patient Module
- Patient dashboard
- Patient profile management
- Book appointments with psychologists
- View appointment status
- Mood check-in and mood history
- Manage family members
- Wellness and relaxation exercises
- Emergency/crisis support information

### Psychologist Module
- Psychologist dashboard
- Manage connected patients
- View patient details and history
- Conduct psychological assessments
- Generate assessment results
- Create prescription reports
- Manage follow-up sessions
- View patient statistics and insights
- Schedule and appointment management

### Family Module
- Family dashboard
- View linked patient information
- View prescriptions
- View appointment schedules
- Upload patient reports
- Monitor patient mood history
- Receive important updates and alerts

### Assessment and Record Management
- Digital psychological assessment forms
- Automated scoring logic
- Patient history management
- Consent form support
- Session notes and follow-up records
- PDF report generation

### Notifications and Reminders
- Appointment reminders
- Follow-up reminders
- In-app notifications
- Push notifications using OneSignal / Firebase Cloud Messaging

### Language and Accessibility Support
- Urdu and English support
- Voice input support
- Text-to-speech / speech-related features
- User-friendly interface for patients, psychologists, and family members

## Technologies Used

- **Flutter** - Cross-platform mobile app development
- **Dart** - Programming language
- **Firebase Authentication** - Secure login and user management
- **Cloud Firestore** - Database for user records, appointments, assessments, and history
- **Firebase Cloud Messaging** - In-app and push notifications
- **Supabase Storage** - Storage for reports, images, and documents
- **OneSignal** - Push notification service
- **PDF Packages** - Prescription and report generation
- **Speech-to-Text / Text-to-Speech APIs** - Voice-based interaction
- **Machine Learning Model** - Mood/activity related model support

## System Users

### 1. Patient
Patients can register, manage their profile, book appointments, complete mood check-ins, view progress, receive reminders, and access wellness exercises.

### 2. Psychologist
Psychologists can manage patients, conduct assessments, write notes, generate reports, schedule sessions, and monitor patient progress.

### 3. Family Member
Family members can monitor patient progress, view prescriptions, check appointment schedules, upload reports, and support the patient during treatment.

## Project Objectives

- To provide secure digital storage for patient mental health records.
- To reduce manual paperwork for psychologists.
- To support Urdu and voice-based input for better clinical documentation.
- To provide separate dashboards for patients, psychologists, and family members.
- To automate reminders for appointments and follow-up sessions.
- To improve communication between patients, families, and psychologists.
- To support progress tracking and better decision-making.


## Installation and Setup

### Prerequisites

Make sure you have installed:

- Flutter SDK
- Dart SDK
- Android Studio
- Firebase project
- Supabase project
- OneSignal account
