import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiSecondOpinionService {
  static const String _baseUrl =
      "https://openrouter.ai/api/v1/chat/completions";

  // ✅ Load API key from .env file
  static String get _apiKey {
    final key = dotenv.env['OPENROUTER_API_KEY'];
    if (key == null || key.isEmpty) {
      debugPrint("❌ API Key not found in .env file");
      throw Exception("API Key not found in .env file");
    }
    debugPrint("✅ API Key loaded successfully");
    return key;
  }

  static Future<String> analyze(String symptoms) async {
    final url = Uri.parse(_baseUrl);

    final headers = {
      "Authorization": "Bearer $_apiKey",
      "Content-Type": "application/json",
      "HTTP-Referer": "<YOUR_SITE_URL>", // optional
      "X-Title": "<YOUR_SITE_NAME>", // optional
    };

    final body = jsonEncode({
      "model": "deepseek/deepseek-chat-v3-0324:free",
      "messages": [
        {
          "role": "system",
          "content":
              "You are a medical assistant that provides second opinions. You never diagnose, but suggest urgency, possible conditions, and general treatments.",
        },
        {"role": "user", "content": "Patient symptoms: $symptoms"},
      ],
    });

    debugPrint("📤 Sending request to: $url");
    debugPrint("📦 Headers: $headers");
    debugPrint("📝 Body: $body");

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint("📥 Response status: ${response.statusCode}");
      debugPrint("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Extract assistant reply safely
        final reply = data["choices"]?[0]?["message"]?["content"];
        debugPrint("🤖 AI Reply: $reply");

        return reply ?? "No response received.";
      } else {
        throw Exception("Failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error during API call: $e");
      rethrow;
    }
  }
}
