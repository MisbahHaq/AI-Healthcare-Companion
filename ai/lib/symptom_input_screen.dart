import 'package:flutter/material.dart';
import 'ai_service.dart';

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String _response = "";

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
      final result = await AiSecondOpinionService.analyze(_controller.text);
      setState(() {
        _response = result;
      });
    } catch (e) {
      setState(() {
        _response = "⚠️ Error: $e";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("AI Second Opinion"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Describe your symptoms",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "e.g., fever, cough, chest pain",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _analyzeSymptoms,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text(
                      "Get AI Second Opinion",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            if (_response.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _response,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/upload'),
                icon: const Icon(Icons.upload_file, color: Colors.teal),
                label: const Text("Upload Reports Instead"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
