// Flutter AI Second Opinion – Starter App
// --------------------------------------
// Quick-start, single-file prototype focusing on UX flow for rural use.
// Includes: Symptom input, report upload (image), AI analysis stub, results screen.
//
// ✅ What you get
// - Offline-first friendly architecture (no network calls yet)
// - Clear separation of models + a fake AI analysis service
// - Simple triage colors (Green/Yellow/Red) with explanations
// - Local language hook (easy to add translations)
//
// 📦 pubspec.yaml additions (add these under dependencies and run `flutter pub get`):
// dependencies:
//   flutter:
//     sdk: flutter
//   image_picker: ^1.1.2
//   intl: ^0.19.0
//
// Android: Ensure camera/gallery permissions in AndroidManifest if you target real devices.
// iOS: Add NSCameraUsageDescription / NSPhotoLibraryUsageDescription in Info.plist.
//
// NOTE: The analysis logic is a placeholder. Replace AiSecondOpinionService.analyze(...) with
// your ML/LLM pipeline (local or remote). Keep the same data contracts to avoid breaking UI.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const SecondOpinionApp());
}

class SecondOpinionApp extends StatelessWidget {
  const SecondOpinionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Second Opinion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C7A7B)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------------- MODELS ----------------------
class SymptomReport {
  final String symptoms; // free text
  final String duration; // eg: "3 days"
  final int age;
  final String sex; // "M" | "F" | "Other"
  final String existingConditions; // comma-separated
  final String currentMeds; // comma-separated
  final File? attachedImage; // prescription/report photo

  SymptomReport({
    required this.symptoms,
    required this.duration,
    required this.age,
    required this.sex,
    required this.existingConditions,
    required this.currentMeds,
    this.attachedImage,
  });
}

enum Urgency { green, yellow, red }

class SecondOpinionResult {
  final String headline; // summary line
  final Urgency urgency;
  final List<String> likelyDiagnoses; // sorted by confidence (desc)
  final List<String> alternativeDiagnoses;
  final List<String> treatmentOptions; // evidence-aligned placeholders
  final List<String> warnings; // drug interactions, red flags
  final List<String> recommendedActions; // next steps

  SecondOpinionResult({
    required this.headline,
    required this.urgency,
    required this.likelyDiagnoses,
    required this.alternativeDiagnoses,
    required this.treatmentOptions,
    required this.warnings,
    required this.recommendedActions,
  });
}

// ---------------------- FAKE AI SERVICE (Replace with real model/LLM) ----------------------
class AiSecondOpinionService {
  static Future<SecondOpinionResult> analyze(SymptomReport r) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    ); // UX breathing room

    // Simple heuristic just to demonstrate branching; replace with guideline-backed logic.
    final text = r.symptoms.toLowerCase();
    final List<String> likely = [];
    final List<String> alt = [];
    final List<String> warnings = [];
    final List<String> treatments = [];
    Urgency urgency = Urgency.green;

    bool fever = text.contains('fever') || text.contains('temperature');
    bool headache = text.contains('headache');
    bool vomiting = text.contains('vomit');
    bool cough = text.contains('cough');
    bool bleeding = text.contains('bleed');
    bool pregnancy = r.existingConditions.toLowerCase().contains('pregnan');

    if (fever && headache) {
      likely.add('Malaria');
      alt.add('Dengue');
      treatments.add(
        'Paracetamol for fever (avoid NSAIDs if dengue suspected)',
      );
      treatments.add('Oral rehydration; rest; monitor temperature');
      if (pregnancy)
        warnings.add(
          'Pregnancy: avoid certain antimalarials; seek clinician guidance.',
        );
      if (r.currentMeds.toLowerCase().contains('ibuprofen')) {
        warnings.add(
          'Possible dengue risk: avoid ibuprofen due to bleeding risk.',
        );
      }
    }

    if (cough && fever) {
      likely.add('Lower Respiratory Tract Infection');
      alt.add('COVID-19 / Influenza');
      treatments.add(
        'Hydration + antipyretic; consider chest exam if persistent',
      );
    }

    if (bleeding || (vomiting && fever)) {
      urgency = Urgency.red;
      warnings.add(
        'Red flag: bleeding or persistent vomiting with fever. Immediate evaluation needed.',
      );
    } else if (fever && r.duration.contains('7')) {
      urgency = Urgency.yellow;
      warnings.add('Fever lasting ≥7 days: consider lab tests and GP review.');
    }

    if (likely.isEmpty) likely.add('General Viral Syndrome');

    // De-duplicate
    List<String> dedup(List<String> xs) => xs.toSet().toList();

    return SecondOpinionResult(
      headline: _headlineFor(urgency, likely.first),
      urgency: urgency,
      likelyDiagnoses: dedup(likely),
      alternativeDiagnoses: dedup(alt),
      treatmentOptions: dedup(treatments),
      warnings: dedup(warnings),
      recommendedActions: _actionsFor(urgency),
    );
  }

  static String _headlineFor(Urgency u, String topDx) {
    switch (u) {
      case Urgency.green:
        return 'Likely $topDx — low immediate risk';
      case Urgency.yellow:
        return 'Possible $topDx — seek GP review soon';
      case Urgency.red:
        return 'Emergency risk — urgent evaluation advised';
    }
  }

  static List<String> _actionsFor(Urgency u) {
    switch (u) {
      case Urgency.green:
        return [
          'Continue supportive care; monitor symptoms',
          'Return if symptoms worsen or new red flags appear',
        ];
      case Urgency.yellow:
        return [
          'Book a GP/telemedicine consult within 24–48 hours',
          'Consider basic labs if fever persists (CBC, RDT as locally advised)',
        ];
      case Urgency.red:
        return [
          'Go to the nearest hospital or emergency department now',
          'Avoid NSAIDs until bleeding risk is ruled out',
        ];
    }
  }
}

// ---------------------- UI SCREENS ----------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE, MMM d, y').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('AI Second Opinion'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(.6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Today: $date'),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool offers AI-assisted second opinions and safety checks. It does not replace a clinician.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SymptomInputScreen(),
                    ),
                  ),
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Enter Symptoms'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UploadReportScreen(),
                    ),
                  ),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Prescription / Lab Report'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showAbout(context),
              icon: const Icon(Icons.info_outline),
              label: const Text('About & Safety Notes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('About'),
            content: const Text(
              'This prototype demonstrates an AI second-opinion flow for rural use.\n\n'
              '— Keep data on device unless user opts-in to share.\n'
              '— Provide local language support.\n'
              '— Clearly state: not a replacement for a doctor.\n'
              '— Escalate red flags immediately.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '3 days');
  final _ageCtrl = TextEditingController(text: '30');
  String _sex = 'M';
  final _conditionsCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();

  File? _attachedImage;

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    _durationCtrl.dispose();
    _ageCtrl.dispose();
    _conditionsCtrl.dispose();
    _medsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null) setState(() => _attachedImage = File(file.path));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final report = SymptomReport(
      symptoms: _symptomsCtrl.text.trim(),
      duration: _durationCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      sex: _sex,
      existingConditions: _conditionsCtrl.text.trim(),
      currentMeds: _medsCtrl.text.trim(),
      attachedImage: _attachedImage,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await AiSecondOpinionService.analyze(report);

    if (mounted) {
      Navigator.pop(context); // loading
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(result: result, report: report),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Symptoms')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _symptomsCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Describe your symptoms',
                  hintText: 'e.g., High fever, severe headache, weakness',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Please describe symptoms'
                            : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _durationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        hintText: 'e.g., 3 days',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Add duration'
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Age?';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sex,
                      decoration: const InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'M', child: Text('M')),
                        DropdownMenuItem(value: 'F', child: Text('F')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _sex = v ?? 'M'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Existing conditions (comma-separated)',
                  hintText: 'e.g., Hypertension, Pregnancy',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _medsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Current medications (comma-separated)',
                  hintText: 'e.g., Paracetamol, Ibuprofen',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text(
                        'Attach prescription/report (optional)',
                      ),
                    ),
                  ),
                ],
              ),
              if (_attachedImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _attachedImage!,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.medical_information_outlined),
                label: const Text('Get Second Opinion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  File? _image;

  Future<void> _pick(ImageSource src) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: src, imageQuality: 70);
    if (file != null) setState(() => _image = File(file.path));
  }

  Future<void> _analyze() async {
    final report = SymptomReport(
      symptoms: 'Uploaded report only',
      duration: 'Unknown',
      age: 0,
      sex: 'Other',
      existingConditions: '',
      currentMeds: '',
      attachedImage: _image,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final result = await AiSecondOpinionService.analyze(report);
    if (mounted) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(result: result, report: report),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Use Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose from Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_image != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              )
            else
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('No file selected')),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _image == null ? null : _analyze,
              icon: const Icon(Icons.medical_services_outlined),
              label: const Text('Analyze'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final SecondOpinionResult result;
  final SymptomReport report;

  const ResultsScreen({super.key, required this.result, required this.report});

  Color _badgeColor(Urgency u, BuildContext context) {
    switch (u) {
      case Urgency.green:
        return Colors.green.shade600;
      case Urgency.yellow:
        return Colors.orange.shade600;
      case Urgency.red:
        return Colors.red.shade700;
    }
  }

  String _urgencyText(Urgency u) {
    switch (u) {
      case Urgency.green:
        return 'LOW';
      case Urgency.yellow:
        return 'CAUTION';
      case Urgency.red:
        return 'URGENT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Opinion Results')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _badgeColor(result.urgency, context),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _urgencyText(result.urgency),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            result.headline,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Summary based on the provided details. This is not a diagnosis.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            _section(context, 'Most likely', result.likelyDiagnoses),
            _section(context, 'Alternatives', result.alternativeDiagnoses),
            _section(context, 'Treatment options', result.treatmentOptions),
            _section(
              context,
              'Warnings',
              result.warnings,
              emptyHint: 'No critical warnings detected.',
            ),
            _section(
              context,
              'Recommended next steps',
              result.recommendedActions,
            ),

            const SizedBox(height: 16),
            if (report.attachedImage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attached file',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      report.attachedImage!,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _showDisclaimer(context),
              icon: const Icon(Icons.shield_outlined),
              label: const Text('Disclaimer & Guidance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<String> items, {
    String? emptyHint,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (items.isEmpty && emptyHint != null)
              Text(
                emptyHint,
                style: TextStyle(color: Theme.of(context).hintColor),
              )
            else
              ...items.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const Text('• '), Expanded(child: Text(e))],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Safety & Disclaimer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This app provides AI-assisted second opinions based on patterns and guidelines.\n\n'
                  '— It does not replace a clinician.\n'
                  '— If you experience red-flag symptoms (severe pain, breathing difficulty, bleeding, confusion), seek emergency care immediately.\n'
                  '— Medication decisions should be made with a qualified health professional.',
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
    );
  }
}
