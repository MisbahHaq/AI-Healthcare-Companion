import 'package:flutter/material.dart';

class CoinBalanceCard extends StatelessWidget {
  final String coinName;
  final int balance;

  const CoinBalanceCard({
    super.key,
    required this.coinName,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.amber),
        title: Text(coinName),
        trailing: Text(
          balance.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
