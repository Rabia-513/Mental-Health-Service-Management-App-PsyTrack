import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fyp/ui/common/provider.dart';
import 'package:fyp/ui/screens/styles/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'app/language_provider.dart';
import 'app/theme_notifier.dart';
import 'data/services/fcm_service.dart';
import 'data/services/notification_service.dart';
import 'firebase_options.dart';
import 'app/routes.dart';

Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("8aaeca44-3d52-4e84-96de-fc8bb54f1e32");
  await FCMService.init();

  // Supabase
  await Supabase.initialize(
    url: 'https://lfyhlktyhxtztyrjozos.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxmeWhsa3R5aHh0enR5cmpvem9zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzODAxMzgsImV4cCI6MjA4MDk1NjEzOH0.RQW5p9zzrn68y0lL4Zgbimo149wV5dDBYlr75dWUrh0',
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Notification received: ${message.notification?.title}");
  });


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,


      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F9F9),
        cardColor: Theme.of(context).cardColor,

      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),

      themeMode:
      settings.darkMode ? ThemeMode.dark : ThemeMode.light,

      builder: (context, child) {

        final isUrdu = context.watch<LanguageProvider>().isUrdu;

        return Directionality(
          textDirection:
          isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}