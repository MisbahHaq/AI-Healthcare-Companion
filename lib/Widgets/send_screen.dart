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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Send Coins",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCoin,
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.white,
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
              decoration: const InputDecoration(
                labelText: "Select Coin",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(
                labelText: "Amount",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.2),
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: receiverCtrl,
              decoration: const InputDecoration(
                labelText: "Receiver Public Key",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: sendCoin,
                child: const Text(
                  "Send",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
