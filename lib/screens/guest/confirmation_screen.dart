import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ConfirmationScreen extends StatelessWidget {
  final String type; // 'attendance' | 'decline' | 'gift'
  final String guestName;
  final String eventTitle;
  final double? amount;
  final bool? accepted; // used when type == 'gift'

  const ConfirmationScreen({
    super.key,
    required this.type,
    required this.guestName,
    required this.eventTitle,
    this.amount,
    this.accepted,
  });

  @override
  Widget build(BuildContext context) {
    final isGift = type == 'gift';
    final isDecline = type == 'decline';

    final List<Color> gradientColors;
    final String emoji;
    final String title;
    final String message;

    if (isGift) {
      gradientColors = [const Color(0xFF2C1A0E), const Color(0xFF8C6030), AppTheme.cream];
      emoji = '💝';
      title = 'تم إرسال العانية!';
      message = 'تم استلام العانية بنجاح وسيصل الإشعار لأصحاب العرس. بارك الله لهم 💕';
    } else if (isDecline) {
      gradientColors = [const Color(0xFF4A0000), Colors.red.shade800, AppTheme.cream];
      emoji = '😔';
      title = 'تم تسجيل اعتذارك';
      message = 'شكراً لإعلامنا. نتمنى لك التوفيق ونأمل في التواصل في مناسبات قادمة 🌸';
    } else {
      gradientColors = [const Color(0xFF1B5E20), const Color(0xFF388E3C), AppTheme.cream];
      emoji = '🎉';
      title = 'تم تأكيد الحضور!';
      message = 'شكراً لتأكيد حضورك! يسعدنا وجودك في هذه المناسبة السعيدة 🌸';
    }

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
            stops: const [0, 0.4, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Animated Icon
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(emoji,
                        style: const TextStyle(fontSize: 60)),
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(),

                  const SizedBox(height: 28),

                  Text(title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 32),

                  // Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 24, offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _row('👤', 'الاسم', guestName),
                        const SizedBox(height: 12),
                        _row('💍', 'المناسبة', eventTitle),
                        if (isGift && amount != null) ...[
                          const SizedBox(height: 12),
                          _row('💰', 'المبلغ', '${amount!.toStringAsFixed(0)} ر.س'),
                          if (accepted != null) ...[
                            const SizedBox(height: 12),
                            _row(accepted! ? '✅' : '😔', 'الحضور',
                              accepted! ? 'مؤكد الحضور' : 'اعتذر عن الحضور'),
                          ],
                        ],
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isGift
                                ? AppTheme.roseLight
                                : isDecline
                                    ? const Color(0xFFFFF3F3)
                                    : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: AppTheme.textMedium,
                              fontSize: 13, height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.15),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.darkBrown,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text('العودة للرئيسية',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text('$label: ',
          style: GoogleFonts.cairo(color: AppTheme.textLight, fontSize: 13)),
        Expanded(
          child: Text(value,
            style: GoogleFonts.cairo(
              color: AppTheme.darkBrown,
              fontWeight: FontWeight.w700, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
