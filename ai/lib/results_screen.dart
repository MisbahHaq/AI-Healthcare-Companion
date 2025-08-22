import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  // 🔹 Helper function to clean unwanted symbols
  String cleanText(String input) {
    return input
        .replaceAll(
          RegExp(r'[^\w\s,.\-]'),
          '',
        ) // keep only letters, numbers, spaces, ., , and -
        .replaceAll(RegExp(r'\s+'), ' ') // collapse extra spaces
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> results =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Second Opinion"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔴 Urgency card
              Card(
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                  title: Text(
                    "Urgency: ${cleanText(results['urgency'])}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 📝 AI Message
              Text(
                cleanText(results['message']),
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 20),

              // 🧾 Possible Conditions
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            color: Colors.teal,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Possible Conditions",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...results['possibleConditions']
                          .map<Widget>(
                            (c) => Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(cleanText(c))),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 💊 Suggested Treatments
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            color: Colors.blue,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Suggested Treatments",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...results['suggestedTreatments']
                          .map<Widget>(
                            (t) => Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(cleanText(t))),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ⚠️ Disclaimer
              Center(
                child: Text(
                  "⚠️ This is not a medical diagnosis.\nAlways consult a licensed doctor.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
