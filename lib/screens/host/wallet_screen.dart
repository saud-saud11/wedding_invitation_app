import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';

class WalletScreen extends StatelessWidget {
  final String eventId;
  const WalletScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('المحفظة الرقمية'),
        backgroundColor: AppTheme.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<GiftModel>>(
        stream: FirebaseService.giftsStream(eventId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold));
          }
          final gifts = snap.data ?? [];
          final total = gifts.fold(0.0, (s, g) => s + g.amount);

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Balance Card ────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8C6030), Color(0xFFBFA060)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(
                      color: AppTheme.goldDark.withValues(alpha: 0.4),
                      blurRadius: 24, offset: const Offset(0, 10),
                    )],
                  ),
                  child: Column(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 48))
                          .animate().scale(duration: 600.ms),
                      const SizedBox(height: 12),
                      Text('إجمالي العانيات المستلمة',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text('${total.toStringAsFixed(0)} ر.س',
                        style: GoogleFonts.cairo(
                          color: Colors.white, fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${gifts.length} عانية مُرسَلة',
                          style: GoogleFonts.cairo(
                            color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.1),

                // ── Transactions ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('سجل العانيات',
                        style: GoogleFonts.cairo(fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkBrown),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.goldLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${gifts.length} عملية',
                          style: GoogleFonts.cairo(color: AppTheme.gold,
                            fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (gifts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text('🎁', style: TextStyle(fontSize: 50)),
                        const SizedBox(height: 16),
                        Text('لم تصلك عانيات بعد',
                          style: GoogleFonts.cairo(
                            color: AppTheme.textMedium, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else
                  ...gifts.asMap().entries.map((entry) =>
                    _transactionTile(entry.value, entry.key)),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _transactionTile(GiftModel gift, int index) {
    final dateStr = DateFormat('d MMM • h:mm a', 'ar').format(gift.sentAt);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8, offset: const Offset(0, 3),
        )],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppTheme.goldLight.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(gift.guestName[0],
                style: GoogleFonts.cairo(fontSize: 20,
                  fontWeight: FontWeight.w800, color: AppTheme.gold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gift.guestName,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
                    color: AppTheme.darkBrown, fontSize: 14),
                ),
                if (gift.message.isNotEmpty)
                  Text(gift.message,
                    style: GoogleFonts.cairo(
                      color: AppTheme.textLight, fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                Text(dateStr,
                  style: GoogleFonts.cairo(
                    color: AppTheme.textLight, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('+${gift.amount.toStringAsFixed(0)} ر.س',
              style: GoogleFonts.cairo(color: AppTheme.success,
                fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 80 * index))
      .slideX(begin: 0.05);
  }
}
