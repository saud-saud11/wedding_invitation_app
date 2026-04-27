import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../services/mock_data_service.dart';
import '../login_screen.dart';
import 'create_event_screen.dart';
import 'wallet_screen.dart';
import 'guest_list_screen.dart';
import 'gifts_screen.dart';
import '../guest/event_page_screen.dart';

class HostDashboard extends StatefulWidget {
  const HostDashboard({super.key});

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final event = provider.currentEvent;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.darkBrown,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2C1A0E), Color(0xFF8C6030)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.goldLight.withOpacity(0.2),
                          border: Border.all(color: AppTheme.goldLight, width: 2),
                        ),
                        child: Center(
                          child: Text(user.displayName[0],
                            style: GoogleFonts.cairo(
                              fontSize: 24, color: AppTheme.goldLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('أهلاً، ${user.displayName}',
                        style: GoogleFonts.cairo(
                          color: AppTheme.cream, fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text('لوحة تحكم الداعي',
                        style: GoogleFonts.cairo(
                          color: AppTheme.goldLight, fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: AppTheme.goldLight),
                onPressed: () {
                  provider.logout();
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
            ],
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                if (event == null) ...[
                  _buildNoEvent(context),
                ] else ...[
                  // Event Card
                  _buildEventCard(context, event, user),
                  const SizedBox(height: 20),

                  // Stats Row
                  _buildStatsRow(event.id),
                  const SizedBox(height: 20),

                  // Invite link
                  _buildInviteCard(context, event),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildQuickActions(context, event),
                ],
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEvent(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text('💍', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('لا توجد مناسبة بعد',
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700,
              color: AppTheme.darkBrown),
          ),
          const SizedBox(height: 8),
          Text('أنشئ مناسبتك الآن وابدأ بإرسال الدعوات',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: AppTheme.textMedium),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('إنشاء مناسبة'),
            onPressed: () async {
              await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()));
              _refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, event, user) {
    final dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(event.eventDate);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1A0E), Color(0xFF5C3D1E)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.darkBrown.withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('حفل زفاف\n${event.fullTitle}',
                  style: GoogleFonts.cairo(
                    color: AppTheme.goldLight, fontSize: 20,
                    fontWeight: FontWeight.w800, height: 1.4,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.goldLight, size: 20),
                onPressed: () async {
                  await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CreateEventScreen(existingEvent: event)));
                  _refresh();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.calendar_today, dateStr),
          const SizedBox(height: 6),
          _infoRow(Icons.location_on, event.location),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.goldLight.withOpacity(0.8), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
            style: GoogleFonts.cairo(color: AppTheme.cream, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(String eventId) {
    final totalGifts = MockDataService.getTotalGifts(eventId);
    final giftsCount = MockDataService.getGiftsForEvent(eventId).length;
    final confirmedCount = MockDataService.getConfirmedCount(eventId);

    return Row(
      children: [
        _statCard('💰', '${totalGifts.toStringAsFixed(0)} ر.س',
          'إجمالي العانيات', AppTheme.gold),
        const SizedBox(width: 12),
        _statCard('🎁', '$giftsCount',
          'عانية مُرسَلة', AppTheme.rosePink),
        const SizedBox(width: 12),
        _statCard('✅', '$confirmedCount',
          'مؤكد الحضور', const Color(0xFF4CAF50)),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15),
            blurRadius: 12, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(value,
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800,
                color: AppTheme.darkBrown),
            ),
            Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, event) {
    final inviteLink = 'زفاف/${event.inviteCode}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.roseLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.rosePink.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🔗 رابط الدعوة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
              color: AppTheme.darkBrown, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(inviteLink,
                    style: GoogleFonts.cairo(color: AppTheme.textMedium,
                      fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: event.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم نسخ الرمز: ${event.inviteCode}',
                          style: GoogleFonts.cairo()),
                        backgroundColor: AppTheme.gold,
                      ),
                    );
                  },
                  child: const Icon(Icons.copy, color: AppTheme.gold, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('معاينة صفحة المدعو'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.brown,
                side: const BorderSide(color: AppTheme.gold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EventPageScreen(
                    inviteCode: event.inviteCode,
                    previewMode: true,
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildQuickActions(BuildContext context, event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الإجراءات السريعة',
          style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700,
            color: AppTheme.darkBrown),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _actionCard(context, '💼', 'المحفظة',
              'استقبال العانيات',
              () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => WalletScreen(eventId: event.id),
              )).then((_) => _refresh()),
            ),
            const SizedBox(width: 12),
            _actionCard(context, '🎁', 'العانيات',
              'كشف المرسلين',
              () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => GiftsScreen(eventId: event.id),
              )).then((_) => _refresh()),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _actionCard(context, '👥', 'المدعوون',
              'قائمة المؤكدين',
              () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => GuestListScreen(eventId: event.id),
              )).then((_) => _refresh()),
            ),
            const SizedBox(width: 12),
            _actionCard(context, '✏️', 'تعديل',
              'بيانات المناسبة',
              () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CreateEventScreen(existingEvent: event),
                ));
                _refresh();
              },
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _actionCard(BuildContext context, String emoji, String title,
      String subtitle, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
                        color: AppTheme.darkBrown, fontSize: 14),
                    ),
                    Text(subtitle,
                      style: GoogleFonts.cairo(color: AppTheme.textLight,
                        fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.gold, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
