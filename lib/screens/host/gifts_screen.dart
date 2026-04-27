import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';

class GiftsScreen extends StatelessWidget {
  final String eventId;
  const GiftsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('كشف العانيات'),
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

          return Column(
            children: [
              // Summary Bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C1A0E), Color(0xFF5C3D1E)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('إجمالي العانيات',
                      '${total.toStringAsFixed(0)} ر.س'),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _summaryItem('عدد المُرسِلين', '${gifts.length} شخص'),
                  ],
                ),
              ),

              // List
              Expanded(
                child: gifts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎁',
                              style: TextStyle(fontSize: 50)),
                            const SizedBox(height: 12),
                            Text('لا توجد عانيات بعد',
                              style: GoogleFonts.cairo(
                                color: AppTheme.textMedium)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: gifts.length,
                        itemBuilder: (context, i) {
                          final g = gifts[i];
                          final date = DateFormat('d MMM yyyy', 'ar')
                              .format(g.sentAt);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                                CircleAvatar(
                                  backgroundColor: AppTheme.roseLight,
                                  radius: 22,
                                  child: Text(g.guestName[0],
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.brown,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(g.guestName,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.darkBrown,
                                        ),
                                      ),
                                      if (g.message.isNotEmpty)
                                        Text(g.message,
                                          style: GoogleFonts.cairo(
                                            color: AppTheme.textLight,
                                            fontSize: 12,
                                          ),
                                        ),
                                      Text(date,
                                        style: GoogleFonts.cairo(
                                          color: AppTheme.textLight,
                                          fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Text('${g.amount.toStringAsFixed(0)} ر.س',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.gold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ).animate()
                            .fadeIn(delay: Duration(milliseconds: 60 * i))
                            .slideX(begin: 0.05);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(value,
          style: GoogleFonts.cairo(color: AppTheme.goldLight,
            fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Text(label,
          style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}
