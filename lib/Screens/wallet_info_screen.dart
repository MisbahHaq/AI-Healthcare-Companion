import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mintocoin/Screens/login_signup_screen.dart';

class WalletInfoScreen extends StatefulWidget {
  final Map<String, int> balances;
  final String publicKey;
  final String privateKey;
  final Function(String coin, int amount) onAddMoney;

  const WalletInfoScreen({
    super.key,
    required this.balances,
    required this.publicKey,
    required this.privateKey,
    required this.onAddMoney,
  });

  @override
  State<WalletInfoScreen> createState() => _WalletInfoScreenState();
}

class _WalletInfoScreenState extends State<WalletInfoScreen> {
  final TextEditingController amountCtrl = TextEditingController();
  final storage = const FlutterSecureStorage();
  String selectedCoin = "";

  @override
  void initState() {
    super.initState();
    selectedCoin = widget.balances.keys.first;
  }

  void copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$label copied to clipboard")));
  }

  /// ✅ Stripe Add Money Flow
  Future<void> addMoney() async {
    final amount = int.tryParse(amountCtrl.text) ?? 0;
    if (amount <= 0) return;

    try {
      // 1. Call your backend to create PaymentIntent
      final url = Uri.parse(
        "http://localhost:3000/create-payment-intent",
      ); // 👈 change to your deployed backend
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": amount * 100}), // amount in cents
      );

      final data = jsonDecode(response.body);
      final clientSecret = data["clientSecret"];

      // 2. Init Stripe PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "MintoCoin",
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. On success → update wallet
      widget.onAddMoney(selectedCoin, amount);
      amountCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Added $amount $selectedCoin to wallet")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Payment failed: $e")));
    }
  }

  Future<void> _logout() async {
    await storage.deleteAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginSignupScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Wallet Info", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Keys Section
            const Text(
              "Public Key",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.publicKey,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed:
                      () => copyToClipboard(widget.publicKey, "Public Key"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Private Key",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.privateKey,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed:
                      () => copyToClipboard(widget.privateKey, "Private Key"),
                ),
              ],
            ),
            const Divider(height: 30, color: Colors.white24),

            // Balances
            const Text(
              "Balances",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...widget.balances.entries.map(
              (e) => ListTile(
                title: Text(e.key, style: const TextStyle(color: Colors.white)),
                trailing: Text(
                  "${e.value}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const Divider(height: 30, color: Colors.white24),

            // Add Money
            const Text(
              "Add Money",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.black,
              value: selectedCoin,
              items:
                  widget.balances.keys
                      .map(
                        (coin) => DropdownMenuItem(
                          value: coin,
                          child: Text(
                            coin,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => selectedCoin = v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountCtrl,
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: addMoney,
              child: const Text("Add to Wallet"),
            ),
          ],
        ),
      ),
    );
  }
}
