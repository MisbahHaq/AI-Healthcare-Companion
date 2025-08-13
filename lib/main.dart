import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mintocoin/Screens/home_screen.dart';
import 'package:mintocoin/Screens/login_signup_screen.dart';
import 'package:mintocoin/Screens/wallet_info_screen.dart';
import 'package:mintocoin/Services/coin_service.dart';
import 'package:mintocoin/Widgets/send_screen.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginSignupScreen(),
    ),
  );
}

class MintoCoinApp extends StatefulWidget {
  final String publicKey;
  final String privateKey;
  const MintoCoinApp({
    super.key,
    required this.publicKey,
    required this.privateKey,
  });

  @override
  State<MintoCoinApp> createState() => _MintoCoinAppState();
}

class _MintoCoinAppState extends State<MintoCoinApp> {
  int selectedIndex = 0;
  late PageController controller;

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
    controller = PageController();
    publicKey = widget.publicKey;
    privateKey = widget.privateKey;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _generateKeys() {
    final rand = Random();
    publicKey =
        List.generate(32, (_) => rand.nextInt(16).toRadixString(16)).join();
    privateKey =
        List.generate(64, (_) => rand.nextInt(16).toRadixString(16)).join();
  }

  bool isMining = false;
  int timeLeft = 0;

  void mineCoin() async {
    if (isMining) return; // prevent double mining

    final coin = CoinService.getRandomCoin();
    final mineTime = (coin["mineTime"] as num).toInt();

    setState(() {
      isMining = true;
      timeLeft = mineTime;
    });

    // Countdown loop
    for (int i = mineTime; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        timeLeft = i - 1;
      });
    }

    // Add coins after countdown
    setState(() {
      balances[coin["name"]] =
          balances[coin["name"]]! + (coin["reward"] as num).toInt();
      isMining = false;
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: PageView(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(
              balances: balances,
              onMine: mineCoin,
              isMining: isMining,
              timeLeft: timeLeft,
            ),
            SendScreen(balances: balances, onSend: sendCoin),
            WalletInfoScreen(
              balances: balances,
              publicKey: publicKey,
              privateKey: privateKey,
              onAddMoney: addMoney,
            ),
          ],
        ),
        bottomNavigationBar: SlidingClippedNavBar.colorful(
          backgroundColor: Colors.white,
          onButtonPressed: (index) {
            setState(() {
              selectedIndex = index;
            });
            controller.animateToPage(
              selectedIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
            );
          },
          iconSize: 28,
          selectedIndex: selectedIndex,
          barItems: [
            BarItem(
              icon: Icons.home_rounded,
              title: 'Home',
              activeColor: Colors.black,
              inactiveColor: Colors.grey,
            ),
            BarItem(
              icon: Icons.send_to_mobile_rounded,
              title: 'Send',
              activeColor: Colors.black,
              inactiveColor: Colors.grey,
            ),
            BarItem(
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              activeColor: Colors.black,
              inactiveColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
