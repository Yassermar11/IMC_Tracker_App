import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'bmi_history.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'locale_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final localeNotifier = LocaleNotifier();
  await localeNotifier.loadLocale();

  runApp(
    ChangeNotifierProvider(
      create: (context) => localeNotifier,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Home(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => BMIHistoryScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleNotifier>(
      builder: (context, localeNotifier, child) {
        return MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.green),

          // Configuration de la localisation
          locale: localeNotifier.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
            Locale('ar'),
          ],

          // Important pour les langues RTL (arabe)
          builder: (context, child) {
            return Directionality(
              textDirection: localeNotifier.locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}