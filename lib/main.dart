import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

import 'providers/subscription_provider.dart';
import 'providers/category_provider.dart';
import 'providers/payment_method_provider.dart';
import 'providers/payment_history_provider.dart';
import 'providers/subscription_history_provider.dart';
import 'providers/user_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUsers()),

        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),

        ChangeNotifierProvider(create: (_) => CategoryProvider()),

        ChangeNotifierProvider(create: (_) => PaymentMethodProvider()),

        ChangeNotifierProvider(create: (_) => PaymentHistoryProvider()),

        ChangeNotifierProvider(create: (_) => SubscriptionHistoryProvider()),
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProvider.users.isEmpty) {
      return const RegisterScreen();
    }

    if (userProvider.currentUser == null) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}
