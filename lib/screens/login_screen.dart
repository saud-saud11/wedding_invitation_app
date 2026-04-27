import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'host/host_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    final ok = context.read<AppProvider>().login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() { _loading = false; });
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HostDashboard()),
      );
    } else {
      setState(() { _error = 'اسم المستخدم أو كلمة المرور غير صحيحة'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C1A0E), Color(0xFF5C3D1E), Color(0xFFFFF8EC)],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // ── Ornament ──────────────────────────────────────────────
                _buildOrnament()
                    .animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
                const SizedBox(height: 20),
                Text('دعوات الزفاف الرقمي',
                  style: GoogleFonts.cairo(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppTheme.goldLight,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                  ),
                ).animate().fadeIn(delay: 200.ms),
                Text('نجعل فرحتكم لا تُنسى',
                  style: GoogleFonts.cairo(
                    fontSize: 14, color: AppTheme.cream.withOpacity(0.7),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 50),
                // ── Card ──────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 30, offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('تسجيل الدخول',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: AppTheme.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameCtrl,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'اسم المستخدم',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('دخول'),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                // ── Demo hint ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.goldLight.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Text('حسابات تجريبية',
                        style: GoogleFonts.cairo(
                          color: AppTheme.goldLight, fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _demoRow('🤵 الداعي الأول', 'host1', '1234'),
                      _demoRow('🤵 الداعي الثاني', 'host2', '1234'),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoRow(String label, String user, String pass) {
    return GestureDetector(
      onTap: () {
        _usernameCtrl.text = user;
        _passwordCtrl.text = pass;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: GoogleFonts.cairo(color: AppTheme.cream, fontSize: 13)),
            const SizedBox(width: 8),
            Text('($user / $pass)',
              style: GoogleFonts.cairo(color: AppTheme.goldLight, fontSize: 12,
                fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnament() {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.goldLight.withOpacity(0.3),
                Colors.transparent,
              ]),
            ),
          ),
          Text('💍', style: TextStyle(fontSize: 52)),
        ],
      ),
    );
  }
}
