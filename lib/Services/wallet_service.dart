import 'dart:math';
import 'dart:convert';

class WalletService {
  static Map<String, String> generateWallet() {
    final rand = Random.secure();
    final privateKey = List<int>.generate(32, (_) => rand.nextInt(256));
    final privKeyHex = base64Encode(privateKey);
    final publicKey = _mockPublicKeyFromPrivate(privKeyHex);
    return {'privateKey': privKeyHex, 'publicKey': publicKey};
  }

  static String _mockPublicKeyFromPrivate(String privKey) {
    return 'PUB_' + privKey.substring(0, 16);
  }
}
