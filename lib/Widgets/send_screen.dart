import 'package:flutter/material.dart';

class SendScreen extends StatefulWidget {
  final Map<String, int> balances;
  final Function(String coin, int amount, String receiverKey) onSend;

  const SendScreen({super.key, required this.balances, required this.onSend});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  String selectedCoin = "";
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController receiverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCoin = widget.balances.keys.first;
  }

  void sendCoin() {
    final amount = int.tryParse(amountCtrl.text) ?? 0;
    final receiverKey = receiverCtrl.text.trim();

    if (amount <= 0 || receiverKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount and receiver key")),
      );
      return;
    }

    widget.onSend(selectedCoin, amount, receiverKey);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sent $amount $selectedCoin to $receiverKey")),
    );

    amountCtrl.clear();
    receiverCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Coins")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              decoration: const InputDecoration(labelText: "Select Coin"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: receiverCtrl,
              decoration: const InputDecoration(
                labelText: "Receiver Public Key",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: sendCoin, child: const Text("Send")),
          ],
        ),
      ),
    );
  }
}
