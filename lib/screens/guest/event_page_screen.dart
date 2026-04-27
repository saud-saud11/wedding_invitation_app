import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';
import '../../services/mock_data_service.dart';
import '../../models/models.dart';
import 'confirmation_screen.dart';

class EventPageScreen extends StatefulWidget {
  final String inviteCode;
  final bool previewMode;

  const EventPageScreen({
    super.key,
    required this.inviteCode,
    this.previewMode = false,
  });

  @override
  State<EventPageScreen> createState() => _EventPageScreenState();
}

/// Two phases for the guest flow
enum _GuestPhase { decision, gift }

class _EventPageScreenState extends State<EventPageScreen> {
  EventModel? _event;
  bool _loading = true;
  String? _error;

  // Phase control
  _GuestPhase _phase = _GuestPhase.decision;
  bool? _accepted; // true = قبل, false = اعتذر

  // Guest info
  final _nameCtrl = TextEditingController();
  final _apologyCtrl = TextEditingController();

  // Gift
  double _selectedAmount = 200;
  final List<double> _amounts = [100, 200, 300, 500, 1000, 2000];
  bool _customAmount = false;
  final _customCtrl = TextEditingController();
  final _giftMsgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _apologyCtrl.dispose();
    _customCtrl.dispose();
    _giftMsgCtrl.dispose();
    super.dispose();
  }

  void _loadEvent() {
    Future.delayed(const Duration(milliseconds: 600), () {
      final event = MockDataService.getEventByInviteCode(widget.inviteCode);
      if (mounted) {
        setState(() {
          _event = event;
          _error = event == null ? 'لم يتم العثور على الدعوة' : null;
          _loading = false;
        });
      }
    });
  }

  // ── Accept ──────────────────────────────────────────────────────────────────
  void _onAccept() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _showNameError(); return; }

    final guest = GuestModel(
      id: const Uuid().v4(),
      eventId: _event!.id,
      guestName: name,
      confirmed: true,
      declined: false,
      apologyMessage: '',
      confirmedAt: DateTime.now(),
    );
    MockDataService.addGuest(guest);
    setState(() { _accepted = true; _phase = _GuestPhase.gift; });
  }

  // ── Decline ─────────────────────────────────────────────────────────────────
  void _onDecline() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _showNameError(); return; }

    final guest = GuestModel(
      id: const Uuid().v4(),
      eventId: _event!.id,
      guestName: name,
      confirmed: false,
      declined: true,
      apologyMessage: _apologyCtrl.text.trim(),
      confirmedAt: DateTime.now(),
    );
    MockDataService.addGuest(guest);
    setState(() { _accepted = false; _phase = _GuestPhase.gift; });
  }

  // ── Send Gift ────────────────────────────────────────────────────────────────
  void _sendGift() {
    final amount = _customAmount
        ? double.tryParse(_customCtrl.text) ?? _selectedAmount
        : _selectedAmount;

    if (amount <= 0) return;

    final gift = GiftModel(
      id: const Uuid().v4(),
      eventId: _event!.id,
      guestName: _nameCtrl.text.trim(),
      amount: amount,
      sentAt: DateTime.now(),
      message: _giftMsgCtrl.text.trim(),
    );
    MockDataService.addGift(gift);

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ConfirmationScreen(
        type: 'gift',
        guestName: _nameCtrl.text.trim(),
        eventTitle: _event!.fullTitle,
        amount: amount,
        accepted: _accepted,
      ),
    ));
  }

  // ── Skip Gift ────────────────────────────────────────────────────────────────
  void _skipGift() {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ConfirmationScreen(
        type: _accepted == true ? 'attendance' : 'decline',
        guestName: _nameCtrl.text.trim(),
        eventTitle: _event!.fullTitle,
        accepted: _accepted,
      ),
    ));
  }

  void _showNameError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('الرجاء إدخال اسمك أولاً',
        style: GoogleFonts.cairo()),
      backgroundColor: Colors.red.shade400,
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.cream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.gold),
              const SizedBox(height: 16),
              Text('جارٍ تحميل الدعوة...',
                style: GoogleFonts.cairo(color: AppTheme.textMedium)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppTheme.cream,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😔', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(_error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 20,
                    color: AppTheme.darkBrown, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final event = _event!;
    final dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(event.eventDate);
    final timeStr = DateFormat('h:mm a', 'ar').format(event.eventDate);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              height: 310,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2C1A0E), Color(0xFF8C6030)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: -40, right: -40,
                    child: Container(width: 180, height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.goldLight.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(bottom: 20, left: -30,
                    child: Container(width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.rosePink.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        const Text('💍', style: TextStyle(fontSize: 52))
                            .animate().scale(duration: 800.ms),
                        const SizedBox(height: 10),
                        Text('حفل زفاف',
                          style: GoogleFonts.cairo(
                            color: AppTheme.cream.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        Text(event.fullTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: AppTheme.goldLight,
                            fontSize: 26, fontWeight: FontWeight.w800,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 14),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.goldLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.goldLight.withValues(alpha: 0.3)),
                          ),
                          child: Text(event.welcomeMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: AppTheme.cream, fontSize: 13),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        if (widget.previewMode) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('👁️ وضع المعاينة',
                              style: GoogleFonts.cairo(
                                color: Colors.amber, fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Event details card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12, offset: const Offset(0, 4),
                    )],
                  ),
                  child: Column(
                    children: [
                      _detailRow('📅', 'التاريخ', dateStr),
                      const Divider(height: 20),
                      _detailRow('🕗', 'الوقت', timeStr),
                      const Divider(height: 20),
                      _detailRow('📍', 'المكان', event.location),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),

                const SizedBox(height: 24),

                if (!widget.previewMode) ...[
                  // ── Phase 1: Decision ──────────────────────────────────
                  if (_phase == _GuestPhase.decision)
                    _buildDecisionPhase(),

                  // ── Phase 2: Gift ──────────────────────────────────────
                  if (_phase == _GuestPhase.gift)
                    _buildGiftPhase(),
                ] else ...[
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text('هكذا سيظهر التطبيق للمدعو',
                          style: GoogleFonts.cairo(color: AppTheme.textMedium)),
                        const SizedBox(height: 6),
                        Text('سيتمكن من قبول الدعوة أو الاعتذار وإرسال العانية',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: AppTheme.textLight, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phase 1: Decision widget ──────────────────────────────────────────────
  Widget _buildDecisionPhase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name field
        Text('اسمك الكريم',
          style: GoogleFonts.cairo(fontSize: 15,
            fontWeight: FontWeight.w700, color: AppTheme.darkBrown),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            hintText: 'أدخل اسمك',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 24),

        // ── Accept Card ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA5D6A7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Text('✅', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text('قبول الدعوة',
                  style: GoogleFonts.cairo(fontSize: 16,
                    fontWeight: FontWeight.w700, color: AppTheme.darkBrown),
                ),
              ]),
              const SizedBox(height: 8),
              Text('يسعدنا حضورك في هذه المناسبة السعيدة',
                style: GoogleFonts.cairo(color: AppTheme.textMedium, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('سأحضر بإذن الله 🎉',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        // Divider OR
        Row(children: [
          Expanded(child: Divider(color: AppTheme.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('أو',
              style: GoogleFonts.cairo(color: AppTheme.textLight)),
          ),
          Expanded(child: Divider(color: AppTheme.divider)),
        ]),

        const SizedBox(height: 16),

        // ── Decline Card ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3F3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Text('😔', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text('الاعتذار عن الحضور',
                  style: GoogleFonts.cairo(fontSize: 16,
                    fontWeight: FontWeight.w700, color: AppTheme.darkBrown),
                ),
              ]),
              const SizedBox(height: 8),
              Text('رسالة اعتذار (اختياري)',
                style: GoogleFonts.cairo(color: AppTheme.textMedium, fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _apologyCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'مثال: آسف لم أتمكن من الحضور...',
                  hintStyle: GoogleFonts.cairo(
                    color: AppTheme.textLight, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade300, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _onDecline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('أعتذر عن الحضور',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms),
      ],
    );
  }

  // ── Phase 2: Gift widget ──────────────────────────────────────────────────
  Widget _buildGiftPhase() {
    final isAccepted = _accepted == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAccepted
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFF3F3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAccepted
                  ? const Color(0xFFA5D6A7)
                  : Colors.red.shade100),
          ),
          child: Row(children: [
            Text(isAccepted ? '🎉' : '😔',
              style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isAccepted ? 'تم تأكيد حضورك!' : 'تم تسجيل اعتذارك',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      color: isAccepted ? AppTheme.success : Colors.red.shade400,
                      fontSize: 15),
                  ),
                  Text(isAccepted
                      ? 'بإمكانك أيضاً إرسال عانية للعروسين'
                      : 'بإمكانك إرسال عانية للتعبير عن فرحتك',
                    style: GoogleFonts.cairo(
                      color: AppTheme.textMedium, fontSize: 12),
                  ),
                ],
              ),
            ),
          ]),
        ).animate().fadeIn().scale(
          begin: const Offset(0.95, 0.95), duration: 400.ms),

        const SizedBox(height: 20),

        // Gift Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.roseLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.rosePink.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Text('🎁', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text('إرسال عانية',
                  style: GoogleFonts.cairo(fontSize: 16,
                    fontWeight: FontWeight.w700, color: AppTheme.darkBrown),
                ),
              ]),
              const SizedBox(height: 12),
              Text('اختر المبلغ',
                style: GoogleFonts.cairo(color: AppTheme.textMedium,
                  fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  ..._amounts.map((a) => GestureDetector(
                    onTap: () => setState(() {
                      _selectedAmount = a;
                      _customAmount = false;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: !_customAmount && _selectedAmount == a
                            ? AppTheme.gold : AppTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: !_customAmount && _selectedAmount == a
                              ? AppTheme.gold : AppTheme.divider,
                        ),
                      ),
                      child: Text('${a.toStringAsFixed(0)} ر.س',
                        style: GoogleFonts.cairo(
                          color: !_customAmount && _selectedAmount == a
                              ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.w600, fontSize: 13,
                        ),
                      ),
                    ),
                  )),
                  GestureDetector(
                    onTap: () => setState(() => _customAmount = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _customAmount ? AppTheme.gold : AppTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _customAmount ? AppTheme.gold : AppTheme.divider),
                      ),
                      child: Text('مبلغ آخر',
                        style: GoogleFonts.cairo(
                          color: _customAmount ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.w600, fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_customAmount) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'أدخل المبلغ بالريال',
                    suffixText: 'ر.س',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _giftMsgCtrl,
                decoration: const InputDecoration(
                  hintText: 'رسالة (اختياري) — مثال: بالرفاه والبنين',
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _sendGift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('إرسال العانية 💝',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _skipGift,
                child: Text('تخطي — بدون عانية',
                  style: GoogleFonts.cairo(
                    color: AppTheme.textLight, fontSize: 13)),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _detailRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: GoogleFonts.cairo(color: AppTheme.textLight, fontSize: 12),
              ),
              Text(value,
                style: GoogleFonts.cairo(color: AppTheme.darkBrown,
                  fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
