import 'dart:math';

class CoinService {
  static final List<Map<String, dynamic>> _coins = [
    {
      "name": "MintoCoin",
      "reward": 5,
      "mineTime": 2, // seconds to mine
    },
    {"name": "GoldCoin", "reward": 3, "mineTime": 3},
    {"name": "PlatinumCoin", "reward": 7, "mineTime": 5},
  ];

  static Map<String, dynamic> getRandomCoin() {
    final random = Random();
    return _coins[random.nextInt(_coins.length)];
  }
}
