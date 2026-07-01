import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'home_screen.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    final user = await context.read<UserProvider>().login(
      emailController.text.trim(),

      passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email o contraseña incorrectos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar sesión")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            TextField(
              controller: emailController,

              decoration: const InputDecoration(
                labelText: "Email",

                prefixIcon: Icon(Icons.email),
              ),

              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,

              decoration: const InputDecoration(
                labelText: "Contraseña",

                prefixIcon: Icon(Icons.lock),
              ),

              obscureText: true,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : _login,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Ingresar"),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },

              child: const Text("Crear nuevo usuario"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();

    passwordController.dispose();

    super.dispose();
  }
}
