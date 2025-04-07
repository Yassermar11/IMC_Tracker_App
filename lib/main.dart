import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';
import 'bmi_history.dart';
import 'home.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
    runApp(MyApp());
  } catch (err) {
    print("Firebase initialization failed: $err");
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Home(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => SignInScreen(
          actions: [
            ForgotPasswordAction((context, email) {
              context.push('/forgot-password', extra: email);
            }),
            AuthStateChangeAction((context, state) {
              if (state is SignedIn || state is UserCreated) {
                context.pushReplacement('/');
              }
            }),
          ],
        ),
      ),
      // New route for forgot password
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) {
          final email = state.extra as String?;
          return ForgotPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => BMIHistoryScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
    );
  }
}