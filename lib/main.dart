import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';

import 'providers/subscription_provider.dart';
import 'providers/category_provider.dart';
import 'providers/payment_method_provider.dart';
import 'providers/payment_history_provider.dart';
import 'providers/subscription_history_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider()..loadSubscriptions(),
        ),

        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),

        ChangeNotifierProvider(
          create: (_) => PaymentMethodProvider()..loadMethods(),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentHistoryProvider()..loadPayments(),
        ),
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
      home: const HomeScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Suscripciones")),

      body: const Center(child: Text("Sin suscripciones")),
    );
  }
}
