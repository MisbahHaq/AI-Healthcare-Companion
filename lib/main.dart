import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mintocoin/Screens/home_screen.dart';
import 'package:mintocoin/Screens/wallet_info_screen.dart';
import 'package:mintocoin/Services/coin_service.dart';
import 'package:mintocoin/Widgets/send_screen.dart';

void main() {
  runApp(const MintoCoinApp());
}

class MintoCoinApp extends StatefulWidget {
  const MintoCoinApp({super.key});

  @override
  State<MintoCoinApp> createState() => _MintoCoinAppState();
}

class _MintoCoinAppState extends State<MintoCoinApp> {
  int currentIndex = 0;

  Map<String, int> balances = {
    "MintoCoin": 0,
    "GoldCoin": 0,
    "PlatinumCoin": 0,
  };

  late String publicKey;
  late String privateKey;

  @override
  void initState() {
    super.initState();
    _generateKeys();
  }

  void _generateKeys() {
    final rand = Random();
    publicKey =
        List.generate(32, (_) => rand.nextInt(16).toRadixString(16)).join();
    privateKey =
        List.generate(64, (_) => rand.nextInt(16).toRadixString(16)).join();
  }

  void mineCoin() async {
    final coin = CoinService.getRandomCoin();
    await Future.delayed(Duration(seconds: (coin["mineTime"] as num).toInt()));
    setState(() {
      balances[coin["name"]] =
          balances[coin["name"]]! + (coin["reward"] as num).toInt();
    });
  }

  void sendCoin(String coin, int amount, String receiverKey) {
    if (balances[coin]! >= amount) {
      setState(() {
        balances[coin] = balances[coin]! - amount;
      });
      print("Sent $amount $coin to receiver: $receiverKey");
    } else {
      print("Not enough $coin to send.");
    }
  }

  void addMoney(String coin, int amount) {
    setState(() {
      balances[coin] = balances[coin]! + amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(balances: balances, onMine: mineCoin),
      SendScreen(balances: balances, onSend: sendCoin),
      WalletInfoScreen(
        balances: balances,
        publicKey: publicKey,
        privateKey: privateKey,
        onAddMoney: addMoney,
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green, // Material 3 color theme
        useMaterial3: true,
      ),
      home: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.send), label: "Send"),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: "Wallet",
            ),
          ],
        ),
      ),
    );
  }
}
