import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class CardDesignsScreen extends StatefulWidget {
  const CardDesignsScreen({super.key});

  @override
  State<CardDesignsScreen> createState() => _CardDesignsScreenState();
}

class _CardDesignsScreenState extends State<CardDesignsScreen> {
  // عدد التصاميم المتوفرة حالياً (من 0 إلى 5)
  final int _totalDesigns = 6;
  bool _isSaving = false;

  final List<String> _designNames = [
    'ملكي (كحلي وفضي)',
    'رخام أبيض (ذهبي)',
    'وردي (كلاسيك)',
    'زخارف إسلامية (أخضر)',
    'أسود (مودرن)',
    'كريمي (عتيق)',
  ];

  Future<void> _selectDesign(int index) async {
    final provider = context.read<AppProvider>();
    final currentEvent = provider.currentEvent;
    
    if (currentEvent == null) return;
    if (currentEvent.selectedDesignIndex == index) return; // تم اختياره مسبقاً

    setState(() => _isSaving = true);

    try {
      // ننشئ نسخة محدثة من المناسبة
      // بما أننا لا نستطيع استخدام copyWith (لم نبرمجها)، سنقوم بعمل نسخة يدوياً:
      // ملاحظة: قمنا بإضافة selectedDesignIndex للمودل، لذلك سنمرره
      final newEventData = currentEvent.toMap();
      newEventData['selectedDesignIndex'] = index;
      
      final newEvent = EventModel.fromMap(currentEvent.id, newEventData);
      await provider.updateEvent(newEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ التصميم بنجاح!', style: GoogleFonts.cairo()),
            backgroundColor: AppTheme.gold,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحفظ', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currentEvent = provider.currentEvent;
    final selectedIndex = currentEvent?.selectedDesignIndex ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('تصاميم البطاقات'),
        backgroundColor: AppTheme.white,
        elevation: 0.5,
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: _totalDesigns,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // عمودين
                childAspectRatio: 0.65, // لتكون عمودية مثل كروت الزفاف
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                
                return GestureDetector(
                  onTap: () => _selectDesign(index),
                  child: Stack(
                    children: [
                      // صورة التصميم
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.gold : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage('assets/designs/design_$index.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)),
                      
                      // طبقة تظليل خفيفة من الأسفل واسم التصميم
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                            ),
                          ),
                          child: Text(
                            index < _designNames.length ? _designNames[index] : 'تصميم $index',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                      // علامة الاختيار
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.gold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 18),
                          ),
                        ).animate().scale(duration: 200.ms),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }
}
