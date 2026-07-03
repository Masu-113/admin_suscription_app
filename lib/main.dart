import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/session_manager.dart';

import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/payment_history_provider.dart';
import 'providers/payment_method_provider.dart';
import 'providers/subscription_history_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/user_provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => PaymentMethodProvider()),
        ChangeNotifierProvider(create: (_) => PaymentHistoryProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionHistoryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Control Suscripciones",
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    SessionManager.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SessionManager.instance,
      builder: (context, _) {
        final session = SessionManager.instance;

        if (session.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (session.isLoggedIn) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
