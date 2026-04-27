import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class CreateEventScreen extends StatefulWidget {
  final EventModel? existingEvent;
  const CreateEventScreen({super.key, this.existingEvent});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _groomCtrl;
  late TextEditingController _brideCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _messageCtrl;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;
    _groomCtrl = TextEditingController(text: e?.groomName ?? '');
    _brideCtrl = TextEditingController(text: e?.brideName ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _messageCtrl = TextEditingController(text: e?.welcomeMessage ?? '');
    if (e != null) {
      _selectedDate = e.eventDate;
      _selectedTime = TimeOfDay.fromDateTime(e.eventDate);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      locale: const Locale('ar'),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final provider = context.read<AppProvider>();
    final user = provider.currentUser!;
    final existing = widget.existingEvent;

    final eventDate = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    final event = EventModel(
      id: existing?.id ?? const Uuid().v4(),
      hostId: user.id,
      groomName: _groomCtrl.text.trim(),
      brideName: _brideCtrl.text.trim(),
      eventDate: eventDate,
      location: _locationCtrl.text.trim(),
      welcomeMessage: _messageCtrl.text.trim(),
      inviteCode: existing?.inviteCode ?? 'WEDDING_${const Uuid().v4().substring(0, 6).toUpperCase()}',
    );

    provider.updateEvent(event);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(existing == null ? 'تم إنشاء المناسبة بنجاح 🎉' : 'تم تحديث المناسبة',
          style: GoogleFonts.cairo()),
        backgroundColor: AppTheme.gold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingEvent != null;
    final dateStr = DateFormat('d MMMM yyyy', 'ar').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل المناسبة' : 'إنشاء مناسبة جديدة'),
        backgroundColor: AppTheme.white,
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader('👰 بيانات العروسين'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _groomCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم العريس',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brideCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم العروسة',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 24),
              _sectionHeader('📅 التاريخ والمكان'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: _infoField(Icons.calendar_today, 'التاريخ', dateStr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: _infoField(Icons.access_time, 'الوقت',
                        _selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'مكان الحفل',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'مثال: قاعة الفردوس - الرياض',
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 24),
              _sectionHeader('💌 رسالة الترحيب'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'رسالة للمدعوين',
                  hintText: 'نسعد بدعوتكم لحضور حفل زفافنا...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEdit ? 'حفظ التعديلات' : 'إنشاء المناسبة 🎉',
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(text,
      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700,
        color: AppTheme.darkBrown),
    );
  }

  Widget _infoField(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.cairo(fontSize: 11,
                color: AppTheme.textLight)),
              Text(value, style: GoogleFonts.cairo(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppTheme.darkBrown)),
            ],
          ),
        ],
      ),
    );
  }
}
