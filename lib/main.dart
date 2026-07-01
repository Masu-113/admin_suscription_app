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

void main() {
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
