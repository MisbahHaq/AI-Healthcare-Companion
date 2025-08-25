import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'ai_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String _selectedSeverity = "Moderate";
  bool _darkMode = false;
  List<String> _recentSymptoms = [];

  // Local notifications
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Auto-suggest
  List<String> commonSymptoms = [
    "Fever",
    "Cough",
    "Headache",
    "Chest pain",
    "Sore throat",
    "Fatigue",
  ];
  List<String> filteredSuggestions = [];

  List<_ResponseItem> _responses = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tzdata.initializeTimeZones();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await notificationsPlugin.initialize(settings);
  }

  void _updateSuggestions(String input) {
    setState(() {
      filteredSuggestions =
          commonSymptoms
              .where(
                (symptom) =>
                    symptom.toLowerCase().contains(input.toLowerCase()),
              )
              .toList();
    });
  }

  String _cleanResponse(String text) {
    text = text.replaceAll(
      RegExp(
        r'[\u{1F300}-\u{1F6FF}'
        r'\u{1F900}-\u{1F9FF}'
        r'\u{1F1E0}-\u{1F1FF}'
        r'\u{2600}-\u{26FF}'
        r'\u{2700}-\u{27BF}]',
        unicode: true,
      ),
      '',
    );
    text = text.replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '');
    text = text.replaceAll(RegExp(r'\*+'), '');
    return text.trim();
  }

  void _analyzeSymptoms() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please describe your symptoms first."),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await AiSecondOpinionService.analyze(
        "${_controller.text} (Severity: $_selectedSeverity)",
      );
      final cleanResult = _cleanResponse(result);

      // Example: parse nextStep/confidence from AI response (replace with your parsing logic)
      String nextStep = "Home care may be sufficient";
      double confidence = 0.75;

      setState(() {
        _responses.insert(
          0,
          _ResponseItem(
            question: _controller.text,
            text: cleanResult,
            timestamp: DateTime.now(),
            severity: _selectedSeverity,
            nextStep: nextStep,
            confidence: confidence,
          ),
        );
        _addToHistory(_controller.text);
      });
    } catch (e) {
      setState(() {
        _responses.insert(
          0,
          _ResponseItem(
            question: "Error",
            text: "⚠️ Error: $e",
            timestamp: DateTime.now(),
            severity: "Moderate",
          ),
        );
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _addToHistory(String text) {
    setState(() {
      _recentSymptoms.insert(0, text);
      if (_recentSymptoms.length > 5) _recentSymptoms.removeLast();
    });
  }

  void _clearInput() {
    _controller.clear();
    filteredSuggestions.clear();
    setState(() {});
  }

  void _copyResponse(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Response copied")));
  }

  void _shareResponse(String text) {
    Share.share(text);
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case "Mild":
        return Colors.green.shade100;
      case "Moderate":
        return Colors.orange.shade100;
      case "Severe":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  TextSpan _highlightKeywords(String text) {
    List<String> keywords = ["fever", "urgent", "pain"];
    return TextSpan(
      children:
          text.split(' ').map((word) {
            if (keywords.contains(word.toLowerCase())) {
              return TextSpan(
                text: "$word ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              );
            }
            return TextSpan(
              text: "$word ",
              style: const TextStyle(color: Colors.black87),
            );
          }).toList(),
    );
  }

  void _scheduleReminder(String symptom, int days) async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(days: days));

    await notificationsPlugin.zonedSchedule(
      0,
      'Symptom Reminder',
      'Check your symptom: $symptom',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: symptom,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⏰ Reminder set for $symptom in $days days')),
    );
  }

  void _exportPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children:
                  _responses.map((r) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          r.question,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(r.text),
                        if (r.nextStep.isNotEmpty)
                          pw.Text(
                            "Next Step: ${r.nextStep} (Confidence: ${(r.confidence * 100).toStringAsFixed(0)}%)",
                          ),
                        pw.SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
            ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _darkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        backgroundColor:
            _darkMode ? Colors.grey.shade900 : const Color(0xFFF2F7FA),
        appBar: AppBar(
          backgroundColor: Colors.teal.shade600,
          title: const Text("AI Second Opinion"),
          centerTitle: true,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() => _darkMode = !_darkMode);
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween<double>(
                        begin: 0.75,
                        end: 1,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child:
                      _darkMode
                          ? const Icon(
                            Icons.nights_stay, // moon icon
                            key: ValueKey('moon'),
                            color: Colors.yellowAccent,
                            size: 28,
                          )
                          : const Icon(
                            Icons.wb_sunny, // sun icon
                            key: ValueKey('sun'),
                            color: Colors.orange,
                            size: 28,
                          ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildInputSection(),
                const SizedBox(height: 12),
                _buildSeveritySelector(),
                const SizedBox(height: 20),
                if (_recentSymptoms.isNotEmpty) _buildRecentSymptoms(),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAnalyzeButton(),
                const SizedBox(height: 24),
                _buildResponseList(),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _exportPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export All Responses"),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/upload'),
                    icon: const Icon(Icons.upload_file, color: Colors.teal),
                    label: const Text(
                      "Upload Reports Instead",
                      style: TextStyle(color: Colors.teal, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "⚠️ This is not a medical diagnosis. Always consult a doctor.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.teal.shade100,
          child: const Icon(Icons.smart_toy, color: Colors.teal, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Hi there 👋\nTell me what symptoms you’re experiencing.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _darkMode ? Colors.white70 : Colors.teal.shade900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        const Text(
          "Describe your symptoms",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _darkMode ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              TextField(
                controller: _controller,
                maxLines: 4,
                onChanged: (val) {
                  _updateSuggestions(val);
                  setState(() {});
                },
                readOnly: _loading,
                decoration: InputDecoration(
                  hintText: "e.g., fever, cough, chest pain",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor:
                      _loading
                          ? Colors.grey.shade200
                          : (_darkMode ? Colors.grey.shade800 : Colors.white),
                ),
                style: TextStyle(
                  color: _darkMode ? Colors.white : Colors.black,
                ),
              ),
              if (_controller.text.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _clearInput,
                  ),
                ),
            ],
          ),
        ),
        ...filteredSuggestions.map(
          (s) => ListTile(
            title: Text(s),
            onTap: () {
              _controller.text = s;
              filteredSuggestions.clear();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeveritySelector() {
    return Wrap(
      spacing: 8,
      children:
          ["Mild", "Moderate", "Severe"].map((level) {
            return ChoiceChip(
              label: Text(level),
              selected: _selectedSeverity == level,
              onSelected: (_) => setState(() => _selectedSeverity = level),
            );
          }).toList(),
    );
  }

  Widget _buildRecentSymptoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent symptoms:",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children:
              _recentSymptoms.map((symptom) {
                return Dismissible(
                  key: Key(symptom),
                  onDismissed: (_) {
                    _recentSymptoms.remove(symptom);
                    setState(() {});
                  },
                  child: ActionChip(
                    label: Text(symptom),
                    onPressed: () {
                      _controller.text = symptom;
                      setState(() {});
                    },
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _analyzeSymptoms,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        icon: const Icon(Icons.local_hospital, size: 22),
        label: const Text(
          "Get AI Second Opinion",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildResponseList() {
    return Column(
      children:
          _responses.map((resp) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _getSeverityColor(resp.severity),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        for (var r in _responses) {
                          if (r != resp) r.show = false;
                        }
                        resp.show = !resp.show;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            resp.question.length > 30
                                ? '${resp.question.substring(0, 30)}...'
                                : resp.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          "${resp.timestamp.hour}:${resp.timestamp.minute}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          resp.show
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                            ),
                            child: SingleChildScrollView(
                              child: RichText(
                                text: _highlightKeywords(resp.text),
                              ),
                            ),
                          ),
                        ),
                        if (resp.nextStep.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.teal.shade900,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "${resp.nextStep} (Confidence: ${(resp.confidence * 100).toStringAsFixed(0)}%)",
                                    style: TextStyle(
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.alarm,
                                    color: Colors.orange.shade700,
                                  ),
                                  onPressed:
                                      () => _scheduleReminder(resp.question, 3),
                                ),
                              ],
                            ),
                          ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.teal),
                              onPressed: () => _copyResponse(resp.text),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.teal),
                              onPressed: () => _shareResponse(resp.text),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.thumb_up,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("👍 Thanks for feedback!"),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.thumb_down,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("👎 Feedback noted"),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    crossFadeState:
                        resp.show
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

// Model class
class _ResponseItem {
  String question;
  String text;
  DateTime timestamp;
  String severity;
  bool show;
  String nextStep;
  double confidence;
  _ResponseItem({
    required this.question,
    required this.text,
    required this.timestamp,
    required this.severity,
    this.show = true,
    this.nextStep = "",
    this.confidence = 0.0,
  });
}
