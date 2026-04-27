import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'guest/guest_entry_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A00), Color(0xFF3D2010), Color(0xFF8C6030)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.goldLight.withOpacity(0.1),
                        border: Border.all(
                          color: AppTheme.goldLight.withOpacity(0.3), width: 2),
                      ),
                    ),
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.goldLight.withOpacity(0.15),
                      ),
                    ),
                    Text('💍', style: TextStyle(fontSize: 56)),
                  ],
                )
                    .animate()
                    .scale(duration: 900.ms, curve: Curves.elasticOut)
                    .fadeIn(),

                const SizedBox(height: 32),

                Text('زفافي',
                  style: GoogleFonts.cairo(
                    fontSize: 40, fontWeight: FontWeight.w900,
                    color: AppTheme.goldLight,
                    letterSpacing: 2,
                    shadows: [Shadow(color: Colors.black38, blurRadius: 12)],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                Text('دعوات الزفاف الرقمية',
                  style: GoogleFonts.cairo(
                    fontSize: 16, color: AppTheme.cream.withOpacity(0.75),
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const Spacer(),

                // Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                      icon: const Icon(Icons.person_outline),
                      label: Text('دخول كداعي',
                        style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

                    const SizedBox(height: 14),

                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => const GuestEntryScreen())),
                      icon: const Icon(Icons.mail_outline),
                      label: Text('فتح دعوة (مدعو)',
                        style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.goldLight,
                        side: const BorderSide(
                          color: AppTheme.goldLight, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      ),
                    ).animate().fadeIn(delay: 850.ms).slideY(begin: 0.2),
                  ],
                ),

                const SizedBox(height: 40),

                Text('نجعل فرحتكم لا تُنسى ✨',
                  style: GoogleFonts.cairo(
                    color: AppTheme.cream.withOpacity(0.4), fontSize: 12),
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
