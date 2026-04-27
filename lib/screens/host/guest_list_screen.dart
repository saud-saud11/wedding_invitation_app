import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';

class GuestListScreen extends StatelessWidget {
  final String eventId;
  const GuestListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GuestModel>>(
      stream: FirebaseService.guestsStream(eventId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.gold)));
        }
        final guests = snap.data ?? [];
        final confirmed =
            guests.where((g) => g.confirmed && !g.declined).toList();
        final declined = guests.where((g) => g.declined).toList();
        final pending =
            guests.where((g) => !g.confirmed && !g.declined).toList();

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: AppTheme.cream,
            appBar: AppBar(
              title: const Text('قائمة المدعوين'),
              backgroundColor: AppTheme.white,
              elevation: 0.5,
              bottom: TabBar(
                labelStyle: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700, fontSize: 12),
                unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
                labelColor: AppTheme.gold,
                unselectedLabelColor: AppTheme.textMedium,
                indicatorColor: AppTheme.gold,
                isScrollable: true,
                tabs: [
                  Tab(text: 'الكل (${guests.length})'),
                  Tab(text: '✅ مؤكد (${confirmed.length})'),
                  Tab(text: '❌ اعتذر (${declined.length})'),
                  Tab(text: '⏳ انتظار (${pending.length})'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildList(guests),
                _buildList(confirmed),
                _buildList(declined),
                _buildList(pending),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<GuestModel> guests) {
    if (guests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👥', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            Text('لا يوجد ضيوف في هذه القائمة',
              style: GoogleFonts.cairo(color: AppTheme.textMedium)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guests.length,
      itemBuilder: (context, i) {
        final g = guests[i];
        Color avatarBg, badgeBg, badgeColor;
        IconData badgeIcon;
        String badgeText;

        if (g.confirmed) {
          avatarBg = const Color(0xFFE8F5E9);
          badgeBg = const Color(0xFFE8F5E9);
          badgeColor = AppTheme.success;
          badgeIcon = Icons.check_circle;
          badgeText = 'مؤكد الحضور';
        } else if (g.declined) {
          avatarBg = const Color(0xFFFFEBEE);
          badgeBg = const Color(0xFFFFEBEE);
          badgeColor = Colors.red.shade400;
          badgeIcon = Icons.cancel_outlined;
          badgeText = 'اعتذر';
        } else {
          avatarBg = AppTheme.roseLight;
          badgeBg = AppTheme.roseLight;
          badgeColor = AppTheme.rosePink;
          badgeIcon = Icons.schedule;
          badgeText = 'في الانتظار';
        }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: avatarBg,
                    radius: 22,
                    child: Text(g.guestName[0],
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        color: g.confirmed
                            ? AppTheme.success
                            : g.declined
                                ? Colors.red.shade400
                                : AppTheme.brown,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(g.guestName,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkBrown, fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 13, color: badgeColor),
                        const SizedBox(width: 4),
                        Text(badgeText,
                          style: GoogleFonts.cairo(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (g.declined && g.apologyMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote, size: 14,
                        color: Colors.red.shade300),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(g.apologyMessage,
                          style: GoogleFonts.cairo(
                            color: Colors.red.shade400, fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: 60 * i))
          .slideX(begin: 0.05);
      },
    );
  }
}
