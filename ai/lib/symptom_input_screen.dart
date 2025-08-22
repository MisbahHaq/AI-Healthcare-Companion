import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'ai_service.dart';

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String _selectedSeverity = "Moderate";
  List<String> _recentSymptoms = [];

  // Store all responses with show/hide state
  List<_ResponseItem> _responses = [];

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

      setState(() {
        _responses.insert(0, _ResponseItem(result, true)); // show by default
        _addToHistory(_controller.text);
      });
    } catch (e) {
      setState(() {
        _responses.insert(0, _ResponseItem("⚠️ Error: $e", true));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: const Text("AI Second Opinion"),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.teal,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Hi there 👋\nTell me what symptoms you’re experiencing.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Input title
              const Text(
                "Describe your symptoms",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 12),

              // Input box with clear button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: "e.g., fever, cough, chest pain",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
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
              const SizedBox(height: 12),

              // Severity selector
              Wrap(
                spacing: 8,
                children:
                    ["Mild", "Moderate", "Severe"].map((level) {
                      return ChoiceChip(
                        label: Text(level),
                        selected: _selectedSeverity == level,
                        onSelected:
                            (_) => setState(() => _selectedSeverity = level),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),

              // Recent history
              if (_recentSymptoms.isNotEmpty) ...[
                const Text(
                  "Recent symptoms:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children:
                      _recentSymptoms.map((symptom) {
                        return ActionChip(
                          label: Text(symptom),
                          onPressed: () {
                            _controller.text = symptom;
                            setState(() {});
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Analyze button
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
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
                  ),
              const SizedBox(height: 24),

              // Response cards with show/hide toggle
              // ...[keep imports and class definitions above the build method the same]
              Column(
                children:
                    _responses.map((resp) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            // Show/Hide toggle
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Collapse all other responses
                                  for (var r in _responses) {
                                    if (r != resp) r.show = false;
                                  }
                                  // Toggle the tapped response
                                  resp.show = !resp.show;
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "AI Response",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Icon(
                                    resp.show
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.teal,
                                  ),
                                ],
                              ),
                            ),

                            if (resp.show) ...[
                              const SizedBox(height: 12),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    resp.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      color: Colors.teal,
                                    ),
                                    onPressed: () => _copyResponse(resp.text),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.teal,
                                    ),
                                    onPressed: () => _shareResponse(resp.text),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.thumb_up,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "👍 Thanks for feedback!",
                                          ),
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("👎 Feedback noted"),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
              ),

              // Upload option
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

              // Disclaimer
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
    );
  }
}

// Model class for each response
class _ResponseItem {
  String text;
  bool show;
  _ResponseItem(this.text, this.show);
}
