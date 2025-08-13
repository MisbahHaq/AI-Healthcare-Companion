import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  void addMoney() {
    final amount = int.tryParse(amountCtrl.text) ?? 0;
    if (amount <= 0) return;
    widget.onAddMoney(selectedCoin, amount);
    amountCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added $amount $selectedCoin to wallet")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wallet Info")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Keys Section
            const Text(
              "Public Key:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.publicKey,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed:
                      () => copyToClipboard(widget.publicKey, "Public Key"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Private Key:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.privateKey,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed:
                      () => copyToClipboard(widget.privateKey, "Private Key"),
                ),
              ],
            ),
            const Divider(height: 30),

            // Balances
            const Text(
              "Balances:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...widget.balances.entries.map(
              (e) => ListTile(title: Text(e.key), trailing: Text("${e.value}")),
            ),

            const Divider(height: 30),

            // Add Money
            const Text(
              "Add Money",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: selectedCoin,
              items:
                  widget.balances.keys
                      .map(
                        (coin) =>
                            DropdownMenuItem(value: coin, child: Text(coin)),
                      )
                      .toList(),
              onChanged: (v) => setState(() => selectedCoin = v!),
            ),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addMoney,
              child: const Text("Add to Wallet"),
            ),
          ],
        ),
      ),
    );
  }
}
