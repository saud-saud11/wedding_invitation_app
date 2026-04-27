import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../guest/event_page_screen.dart';

class GuestEntryScreen extends StatefulWidget {
  const GuestEntryScreen({super.key});

  @override
  State<GuestEntryScreen> createState() => _GuestEntryScreenState();
}

class _GuestEntryScreenState extends State<GuestEntryScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  void _open() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'الرجاء إدخال رمز الدعوة');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EventPageScreen(inviteCode: code),
    ));
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
            stops: [0, 0.4, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text('💌', style: TextStyle(fontSize: 64))
                    .animate().scale(duration: 700.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text('فتح دعوة الزفاف',
                  style: GoogleFonts.cairo(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppTheme.goldLight,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                Text('أدخل رمز الدعوة الذي أرسله لك الداعي',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: AppTheme.cream.withOpacity(0.7), fontSize: 14),
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 50),
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
                      Text('رمز الدعوة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700, color: AppTheme.darkBrown,
                          fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _codeCtrl,
                        textDirection: TextDirection.ltr,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.cairo(
                          letterSpacing: 2, fontSize: 18,
                          fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: 'WEDDING_XXX',
                          hintStyle: GoogleFonts.cairo(
                            color: AppTheme.textLight, letterSpacing: 1),
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                        ),
                        onFieldSubmitted: (_) => _open(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _open,
                          icon: _loading
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.celebration),
                          label: Text('فتح الدعوة',
                            style: GoogleFonts.cairo(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                // Quick demo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.goldLight.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Text('رموز تجريبية',
                        style: GoogleFonts.cairo(
                          color: AppTheme.goldLight, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _codeHint('WEDDING_001', 'حفل أحمد وفاطمة'),
                      _codeHint('WEDDING_002', 'حفل سعد ونورة'),
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

  Widget _codeHint(String code, String label) {
    return GestureDetector(
      onTap: () => setState(() => _codeCtrl.text = code),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: GoogleFonts.cairo(
              color: AppTheme.cream, fontSize: 13)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.goldDark.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(code, style: GoogleFonts.cairo(
                color: AppTheme.goldLight, fontSize: 12,
                fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }
}
