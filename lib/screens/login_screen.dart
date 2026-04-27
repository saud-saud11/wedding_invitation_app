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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Login
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // Register
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regPass2Ctrl = TextEditingController();

  bool _obscure = true;
  bool _obscureReg = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regPass2Ctrl.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;

    final ok = await context.read<AppProvider>().login(email, pass);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HostDashboard()));
    }
  }

  void _register() async {
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final pass = _regPassCtrl.text.trim();
    final pass2 = _regPass2Ctrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) return;
    if (pass != pass2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('كلمتا المرور غير متطابقتين', style: GoogleFonts.cairo()),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final ok = await context.read<AppProvider>().register(
          email: email,
          password: pass,
          displayName: name,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HostDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

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
                const SizedBox(height: 50),
                _buildOrnament()
                    .animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
                const SizedBox(height: 16),
                Text('زفافي',
                  style: GoogleFonts.cairo(
                    fontSize: 32, fontWeight: FontWeight.w900,
                    color: AppTheme.goldLight,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                Text('دعوات الزفاف الرقمية',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppTheme.cream.withValues(alpha: 0.7),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 40),

                // ── Card ──────────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 30, offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tabs
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppTheme.divider),
                          ),
                        ),
                        child: TabBar(
                          controller: _tab,
                          labelStyle: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700, fontSize: 15),
                          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14),
                          labelColor: AppTheme.gold,
                          unselectedLabelColor: AppTheme.textMedium,
                          indicatorColor: AppTheme.gold,
                          indicatorWeight: 3,
                          tabs: const [
                            Tab(text: 'تسجيل الدخول'),
                            Tab(text: 'حساب جديد'),
                          ],
                        ),
                      ),

                      // Tab Views
                      SizedBox(
                        height: 340,
                        child: TabBarView(
                          controller: _tab,
                          children: [
                            _buildLoginTab(provider),
                            _buildRegisterTab(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                // Error
                if (provider.errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(provider.errorMsg!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passCtrl,
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
            onFieldSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: provider.loading ? null : _login,
              child: provider.loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : Text('دخول',
                      style: GoogleFonts.cairo(
                        fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab(AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextFormField(
            controller: _regNameCtrl,
            decoration: const InputDecoration(
              labelText: 'الاسم',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _regEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _regPassCtrl,
            obscureText: _obscureReg,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureReg
                    ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureReg = !_obscureReg),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _regPass2Ctrl,
            obscureText: _obscureReg,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            onFieldSubmitted: (_) => _register(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: provider.loading ? null : _register,
              child: provider.loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : Text('إنشاء حساب',
                      style: GoogleFonts.cairo(
                        fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnament() {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.goldLight.withValues(alpha: 0.3),
                Colors.transparent,
              ]),
            ),
          ),
          const Text('💍', style: TextStyle(fontSize: 50)),
        ],
      ),
    );
  }
}
