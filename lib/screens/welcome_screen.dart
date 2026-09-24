import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/app_button.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('FormaIA',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'Rutinas de ejercicio personalizadas,\ncreadas por IA y pensadas para ti.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.4),
              ),
              const Spacer(),
              AppButton(
                texto: 'Crear cuenta',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
