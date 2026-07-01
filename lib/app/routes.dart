import 'package:flutter/material.dart';
import 'package:fyp/ui/screens/patient/mood_checkin/patient_graphs.dart';
import 'package:fyp/ui/screens/psychologist/history/history_main_screen.dart';
import 'package:fyp/ui/screens/psychologist/history/history_step_6.dart';
import 'package:provider/provider.dart';

import '../ui/common/view_pdf_screen.dart';
import '../ui/screens/auth/family_signup.dart';
import '../ui/screens/auth/psychologist_signup_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/signup_screen.dart';
import '../ui/screens/auth/role_selection_screen.dart';
import '../ui/screens/family/dashboard.dart';
import '../ui/screens/family/main_screens/family_prescription_screen.dart';
import '../ui/screens/family/main_screens/family_schedule_screen.dart';
import '../ui/screens/family/profile/family_profile_edit_screen.dart';
import '../ui/screens/family/profile/family_profile_screen.dart';
import '../ui/screens/family/setting_nav/family_emial_setting _screen.dart';
import '../ui/screens/family/setting_nav/family_history_screen.dart';
import '../ui/screens/family/setting_nav/family_setting_screen.dart';
import '../ui/screens/patient/ appointments/appointment_confirmation_screen.dart';
import '../ui/screens/patient/ appointments/appointments_screen.dart';
import '../ui/screens/patient/ appointments/book_appointment_screen.dart';
import '../ui/screens/patient/ appointments/psychologist_list_screen.dart';
import '../ui/screens/patient/ appointments/psychologist_profile_screen.dart';
import '../ui/screens/patient/ appointments/psychologist_profile_screen.dart';

import '../ui/screens/patient/dashboard.dart';
import '../ui/screens/patient/exercise/Smoothing_Scound_Exrcise.dart';
import '../ui/screens/patient/exercise/bird_sound_screen.dart';
import '../ui/screens/patient/exercise/forest_sound.dart';
import '../ui/screens/patient/exercise/guided_imagery.dart';
import '../ui/screens/patient/exercise/leaves_exercise_screen.dart';
import '../ui/screens/patient/exercise/meditation_exercise_screen.dart';
import '../ui/screens/patient/exercise/ocean_sound.dart';
import '../ui/screens/patient/exercise/patient_breathing_exercise_screen.dart';
import '../ui/screens/patient/exercise/pmr_exercise_screen.dart';
import '../ui/screens/patient/exercise/rain_sound_screen.dart';
import '../ui/screens/patient/exercise/yoga_exercise_screen.dart';
import '../ui/screens/patient/mood_checkin/mood_checkin_screen.dart';
import '../ui/screens/patient/profile/my_patient_code_screen.dart';
import '../ui/screens/patient/profile/patient_edit_profile.dart';
import '../ui/screens/patient/profile/patient_profile_screen.dart';
import '../ui/screens/patient/setting_nav/crisis_helpline_screen.dart';
import '../ui/screens/patient/setting_nav/patient_emerency_screen.dart';
import '../ui/screens/patient/setting_nav/patient_settings_screen.dart';
import '../ui/screens/patient/setting_nav/rate_doctor_screen.dart';
import '../ui/screens/psychologist/ patients/add_patient_screen.dart';
import '../ui/screens/psychologist/ patients/detail_patient_manage_screen.dart';
import '../ui/screens/psychologist/ patients/manage_patients_screen.dart';
import '../ui/screens/psychologist/ patients/patient_detail_screen.dart';
import '../ui/screens/psychologist/assessments/assessment_questionnaire_screen.dart';
import '../ui/screens/psychologist/assessments/assessment_result_screen.dart';
import '../ui/screens/psychologist/assessments/create_prescription_report_screen.dart';
import '../ui/screens/psychologist/assessments/followup_session.dart';
import '../ui/screens/psychologist/assessments/startassessment.dart';
import '../ui/screens/psychologist/consent/consent_screen.dart';
import '../ui/screens/psychologist/dashboard.dart';
import '../ui/screens/psychologist/history/history_pdf_view.dart';
import '../ui/screens/psychologist/history/history_step_1.dart';
import '../ui/screens/psychologist/history/history_step_2.dart';
import '../ui/screens/psychologist/history/history_step_3.dart';
import '../ui/screens/psychologist/history/history_step_4.dart';
import '../ui/screens/psychologist/history/history_step_5.dart';
import '../ui/screens/psychologist/profile/about_me_screen.dart';
import '../ui/screens/psychologist/profile/availability_screen.dart';
import '../ui/screens/psychologist/profile/contact_details_screen.dart';
import '../ui/screens/psychologist/profile/edit_profile_screen.dart';
import '../ui/screens/psychologist/profile/professional_info_screen.dart';
import '../ui/screens/psychologist/profile/psychologist_settings_screen.dart';
import '../ui/screens/psychologist/records/patient_list_screen.dart';
import '../ui/screens/psychologist/records/records_screen.dart';
import '../ui/screens/psychologist/schedule/patient_sessions_screen.dart';
import '../ui/screens/psychologist/schedule/psychologist_schedule_screen.dart';
import '../ui/screens/psychologist/setting_terms/privacy_screen.dart';
import '../ui/screens/psychologist/setting_terms/setting_screen.dart';
import '../ui/screens/psychologist/setting_terms/support_screen.dart';
import '../ui/screens/psychologist/setting_terms/terms_screen.dart';
import '../ui/screens/psychologist/stats/patient_stats_screen.dart';
import '../ui/screens/psychologist/stats/stats_patients_screen.dart';
import '../ui/screens/splash/app_splash_screen.dart';
import '../ui/screens/splash/welcome_screen.dart';
import '../view_model/history_viewmodel.dart';
import '../ui/screens/psychologist/profile/psychologist_profile_screen.dart';
import '../ui/screens/psychologist/profile/clinic_details_screen.dart';


class AppRoutes {
  // Route names
  static const String splash = "/"; // FIRST screen
  static const String welcome = "/welcome";
  static const String roleSelection = "/role-selection";
  static const String patientSignup = "/patient-signup";
  static const String psychologistSignup = "/psychologist-signup";
  static const String login = "/login";
  static const psychologistDashboard = "/psychologist-dashboard";
  static const patientDashboard = "/patient-dashboard";
  static const familyDashboard = "/family-dashboard";
  static const String signup = '/signup';
  static const String consent = "/consent";
  static const String mainHistory = "/history-main";
  static const historyMain = "/history-main";
  static const String historyStep1 = "/history-step-1";
  static const historyStep2 = "/history-step-2";
  static const historyStep3 = "/history-step-3";
  static const historyStep4 = "/history-step-4";
  static const historyStep5 = "/history-step-5";
  static const historyStep6 = "/history-step-6";
  static const startAssessment = "/start-assessment";
  static const historyPdfView = "/history-pdf";
  static const appointments = "/appointments";
  static const phome = "/phome";
  static const emergency = "/emergency";
  static const crisis = "/crisis";
  static const psychologistProfile = "/psychologist-profile";
  static const editProfile = "/edit-profile";
  static const professionalInfo = "/professional-info";
  static const availability = "/availability";
  static const clinicDetails = "/clinic-details";
  static const aboutMe = "/about-me";
  static const contactDetails = "/contact-details";
  static const String psychologistSettings = "/psychologistSettings";
  static const patienthis = "/patient-his";
  static const psychologistList = "/psychologist-list";
  static const psychologistProfileshow = "/psychologist-profile-show";
  static const bookAppointment = "/book-appointment";
  static const psychologistSchedule = "/psychologistSchedule";
  static const appointmentConfirm = "/appointmentConfirm";
  static const  patientMoodCheckIn = '/patient-mood-check-in';
  static const patientQrCode = '/patientQrCode';
  static const addPatient = '/addPatient';
  static const assessmentQuestionnaire = "/assessment-questionnaire";
  static const assessmentResult = "/assessment-result";
  static const managePatients = "/managePatients";
  static const patientDetail = "/patientDetail";
  static const prescriptionFollowup = "/prescription-followup";
  static const createPrescription = "/create-prescription";
  static const createPrescriptionReport = "/create-prescription-report";
  static const startSession = "/startSession";
  static const patientSessions = "/patientSessions";
  static const createSession = "/createSession";
  static const prescription = "/createPrescription";
  static const statsPatients = "/statsPatients";
  static const patientStats = "/patientStats";
  static const viewPdf = "/viewPdf";
  static const psySetting = "/psySetting";
  static const patientProfile = "/patientProfile";
  static const patienteditProfile = "/editProfile";
  static const String familyPrescriptions = '/family-prescriptions';
  static const patSetting = "/patSetting";
  static const familyschedule = "/familyschedules";
  static const patientgraph = "/patientgraph";
  static const familySettings = "/familySettings";
  static const familyProfile = "/familyProfile";
  static const emailSettings = "/emailSettings";
  static const breathingExercises = "/breathing-exercises";
  static const pmrExercise = "/pmr-exercise";
  static const leavesExercise = "/leaves-exercise";
  static const meditationExercise = "/meditation-exercise";
  static const yogaExercise = "/yoga-exercise";
  static const rateDoctor = "/rate-doctor";

  static Map<String, WidgetBuilder> routes = {
    signup: (context) => const PatientSignupScreen(),
    splash: (context) => const AppSplashScreen(), // 👈 Splash
    welcome: (context) => const WelcomeScreen(),
    roleSelection: (context) => const RoleSelectionScreen(),
    patientSignup: (context) => const PatientSignupScreen(),
    psychologistSignup: (context) => const PsychologistSignupScreen(),
    login: (context) => const LoginScreen(),
    psychologistDashboard: (_) => const PsychologistDashboard(),
    patientDashboard: (_) => const PatientDashboard(),
    familyDashboard: (_) => const FamilyDashboard(),
    consent: (context) => const ConsentScreen(),
    mainHistory: (context) => const HistoryMainScreen(),
    historyMain: (_) => const HistoryMainScreen(),
    AppRoutes.patientQrCode: (context) => const MyPatientCodeScreen(),
    AppRoutes.historyStep1: (context) {
      return ChangeNotifierProvider(
        create: (_) => HistoryViewModel(),
        child: const HistoryStep1(),
      );
    },

    historyStep2: (context) {
      return ChangeNotifierProvider(
        create: (_) => HistoryViewModel(),
        child: const HistoryStep2(),
      );
    },

    AppRoutes.historyStep3: (context) {
      return ChangeNotifierProvider(
        create: (_) => HistoryViewModel(),
        child: const HistoryStep3(),
      );
    },

  AppRoutes.historyStep4: (context) {
  return ChangeNotifierProvider(
  create: (_) => HistoryViewModel(),
  child: const HistoryStep4(),
  );
  },

    historyStep5: (context) {
      return ChangeNotifierProvider(
        create: (_) => HistoryViewModel(),
        child: const HistoryStep5(),
      );
    },
    historyStep6: (context) {
      return ChangeNotifierProvider(
        create: (_) => HistoryViewModel(),
        child: const HistoryStep6(),
      );
    },

    AppRoutes.historyStep6: (context) {
      return ChangeNotifierProvider(
        create: (_) => HistoryViewModel(),
        child: const HistoryStep6(),
      );
    },
    AppRoutes.startAssessment: (context) {
      return ChangeNotifierProvider(
        create: (_) => HistoryViewModel(),
        child: const StartAssessmentScreen(),
      );
    },
    AppRoutes.historyPdfView: (context) {
      return ChangeNotifierProvider(
        create: (_) => HistoryViewModel(),
        child: const HistoryPdfView(),
      );
    },

    psychologistProfile: (_) => const PsychologistProfileScreen(),
    editProfile : (_) => const EditProfileScreen(),
    professionalInfo: (_) => const ProfessionalInfoScreen(),
    availability: (context) => const AvailabilityScreen(),



    patienthis: (_) => const HistoryMainScreen(),
    AppRoutes.patientMoodCheckIn: (context) => const MoodCheckInScreen(),

    AppRoutes.clinicDetails: (context) => const ClinicDetailsScreen(),
    AppRoutes.aboutMe: (context) => const AboutMeScreen(),
    AppRoutes.psychologistSettings: (context) => const PsychologistSettingsScreen(),
    AppRoutes.contactDetails: (context) => const ContactDetailsScreen(),
    psychologistList: (context) => const PsychologistListScreen(),
    psychologistProfileshow: (context) => const PsychologistDetailScreen(),
    psychologistSchedule: (context) => const PsychologistScheduleScreen(),
    AppRoutes.appointments: (context) => const AppointmentsScreen(),
    AppRoutes.addPatient: (context) => const AddPatientScreen(),
    AppRoutes.assessmentQuestionnaire: (context) =>
    const AssessmentQuestionnaireScreen(),

    AppRoutes.assessmentResult: (context) =>
    const AssessmentResultScreen(),
    AppRoutes.patientDetail: (context) => const PatientDetailManageScreen(),
    managePatients: (context) => const ManagePatientsScreen(),

    AppRoutes.prescriptionFollowup: (context) => const PrescriptionFollowupScreen(),
    AppRoutes.createPrescriptionReport: (context) => const CreatePrescriptionReportScreen(),
    AppRoutes.startSession: (context) => const PatientSessionsScreen(),
    AppRoutes.prescription: (context) => const CreatePrescriptionReportScreen(),
    AppRoutes.statsPatients: (context) => const StatsPatientsScreen(),
    AppRoutes.patientStats: (context) => const PatientStatsScreen(),
    AppRoutes.startSession: (context) => const PatientSessionsScreen(),
    AppRoutes.createSession: (context) => const PrescriptionFollowupScreen(),
    AppRoutes.prescription: (context) => const CreatePrescriptionReportScreen(),
    AppRoutes.psySetting: (context) =>  SettingsScreen(),
    "/terms": (context) => const TermsScreen(),
    "/privacy": (context) => const PrivacyScreen(),
    "/support": (context) => const SupportScreen(),
    "/patients": (context) => const PatientListScreen(),
    "/addFamily": (context) => const AddFamilyScreen(),
    AppRoutes.patientProfile: (context) => const PatientProfileScreen(),
    AppRoutes.patienteditProfile: (context) => const PatientEditProfileScreen(),
    AppRoutes.familyPrescriptions: (context) => const FamilyPrescriptionsScreen(),
    "/family-prescriptions": (context) => const FamilyPrescriptionsScreen(),
    "/family-schedule": (context) {
      final args = ModalRoute.of(context)?.settings.arguments;

      String patientUid = "";

      if (args != null && args is Map) {
        patientUid = args["patientUid"] ?? "";
      }


      return FamilyScheduleScreen(
        patientUid: patientUid,
      );
    },
    AppRoutes.patSetting: (context) => const PatientSettingsScreen(),
    AppRoutes.patientgraph: (context) => const PatientGraphs(),
    AppRoutes.emailSettings: (context) => const FamilyEmailSettingsScreen(),
    "/breathing-exercises": (context) => const BreathingExercisesScreen(),
    "/pmr-exercise": (context) => const PMRExerciseScreen(),
    "/family-dashboard": (context) => const FamilyDashboard(),
    "/family-profile": (context) => const FamilyProfileScreen(),
    "/edit-family-profile": (context) => const FamilyEditProfileScreen(),
    AppRoutes.familySettings: (context) => const FamilySettingsScreen(),
    "/family-history": (context) {
      final args = ModalRoute.of(context)?.settings.arguments;

      String? patientUid;

      if (args != null && args is Map<String, dynamic>) {
        patientUid = args["patientUid"];
      }

      return FamilyHistoryScreen(
        patientUid: patientUid ?? "", // safe fallback
      );
    },
    "/emergency": (context) => const EmergencyContactScreen(),
    "/crisis": (context) => const CrisisHelplineScreen(),
    "/leaves-exercise": (context) => const LeavesExerciseScreen(),
    "/meditation-exercise": (context) => const MeditationExerciseScreen(),


    "/family-settings": (context) => const FamilySettingsScreen(),

    //"/family-history": (context) => const FamilyHistoryScreen(),
    //"/family-appointments": (context) => const FamilyAppointmentsScreen(),
    //"/family-profile": (context) => const FamilyProfileScreen(),
    bookAppointment: (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      return BookAppointmentScreen(
        psychologistId: args["psychologistId"],
        psychologistName: args["psychologistName"],
      );
    },
    appointmentConfirm: (context) {

      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      return AppointmentConfirmationScreen(

      );
    },
    "/yoga-exercise": (context) => const YogaExerciseScreen(),
    "/guided-imagery": (context) => const GuidedImageryScreen(),
    "/relaxing-sounds": (context) => const RelaxingSoundsScreen(),
    "/rain-sound": (context) => const RainSoundScreen(),
    "/forest-sound": (context) => const ForestSoundScreen(),
    "/ocean-sound": (context) => const OceanSoundScreen(),
    "/bird-sound": (context) => const BirdSoundScreen(),
    rateDoctor: (context) => const RateDoctorScreen(),










  };




}
