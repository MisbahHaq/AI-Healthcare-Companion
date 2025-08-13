import 'package:flutter/material.dart';

class SendCoinModal extends StatefulWidget {
  final List<String> coinTypes;
  final Function(String coin, int amount, String receiverKey) onSend;

  const SendCoinModal({
    super.key,
    required this.coinTypes,
    required this.onSend,
  });

  @override
  State<SendCoinModal> createState() => _SendCoinModalState();
}

class _SendCoinModalState extends State<SendCoinModal> {
  String selectedCoin = "";
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController receiverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCoin = widget.coinTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Send Coins"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCoin,
              items:
                  widget.coinTypes
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
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Send"),
          onPressed: () {
            final amount = int.tryParse(amountCtrl.text) ?? 0;
            if (amount <= 0 || receiverCtrl.text.isEmpty) return;
            widget.onSend(selectedCoin, amount, receiverCtrl.text);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
