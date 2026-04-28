import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class InvitationCardScreen extends StatefulWidget {
  final EventModel event;

  const InvitationCardScreen({super.key, required this.event});

  @override
  State<InvitationCardScreen> createState() => _InvitationCardScreenState();
}

class _InvitationCardScreenState extends State<InvitationCardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  void _shareCard() async {
    setState(() => _isSharing = true);
    
    try {
      // 1. التقاط صورة للبطاقة
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0, // جودة عالية
      );

      if (imageBytes != null && mounted) {
        // 2. تجهيز النص المرفق
        final dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(widget.event.eventDate);
        final inviteLink = 'https://saud-saud11.github.io/wedding_invitation_app/';
        
        final String shareText = '''
💍 *دعوة زفاف* 💍

تتشرف عائلة ${widget.event.groomName} وعائلة ${widget.event.brideName} بدعوتكم لحضور حفل زفافهما.

🗓️ الموعد: $dateStr
📍 المكان: ${widget.event.location}

لتأكيد الحضور، يرجى زيارة الرابط التالي:
$inviteLink

🔑 *رمز الدعوة الخاص بك:* ${widget.event.inviteCode}

حضوركم يسعدنا 🤍
''';

        // 3. تحويل الصورة إلى XFile
        final XFile imageFile = XFile.fromData(
          imageBytes,
          mimeType: 'image/png',
          name: 'invitation_${widget.event.inviteCode}.png',
        );

        // 4. المشاركة
        await Share.shareXFiles(
          [imageFile],
          text: shareText,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء المشاركة: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('تصميم بطاقة الدعوة'),
        backgroundColor: AppTheme.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'هذه هي البطاقة التي ستظهر في الواتساب',
              style: GoogleFonts.cairo(
                color: AppTheme.textMedium,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // ── بطاقة الدعوة (التي سيتم تصويرها) ──
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkBrown.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/designs/design_${widget.event.selectedDesignIndex}.png'),
                    fit: BoxFit.cover,
                    // تظليل خفيف جداً لضمان قراءة النص
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.darken),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الزخرفة العلوية
                    _buildOrnament(),
                    const SizedBox(height: 30),
                    
                    Text(
                      'دعوة زفاف',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.goldLight,
                        letterSpacing: 2,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      widget.event.welcomeMessage.isNotEmpty 
                        ? widget.event.welcomeMessage 
                        : 'نتشرف بدعوتكم لحضور حفل زفافنا',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    
                    // أسماء العرسان
                    Text(
                      widget.event.groomName,
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    Text(
                      '&',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        color: AppTheme.goldLight,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    Text(
                      widget.event.brideName,
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // التفاصيل
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.goldLight.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, color: AppTheme.goldLight, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE، d MMMM yyyy', 'ar').format(widget.event.eventDate),
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 14,
                                  shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, color: AppTheme.goldLight, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.event.location,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 14,
                                    shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'رمز الدعوة: ${widget.event.inviteCode}',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.goldLight,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
            
            const SizedBox(height: 40),
            
            // ── زر المشاركة ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: _isSharing 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.share, size: 22),
                label: Text(
                  _isSharing ? 'جاري التجهيز...' : 'مشاركة البطاقة',
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: _isSharing ? null : _shareCard,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnament() {
    return SizedBox(
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.goldLight.withValues(alpha: 0.3),
                Colors.transparent,
              ]),
            ),
          ),
          const Text('✨', style: TextStyle(fontSize: 32)),
        ],
      ),
    );
  }
}
