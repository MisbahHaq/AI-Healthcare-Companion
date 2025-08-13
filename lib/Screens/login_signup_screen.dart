import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mintocoin/main.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final storage = const FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true; // toggle between login and signup

  // Secure random hex key generation
  String _generateKey(int length) {
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => rand.nextInt(16).toRadixString(16),
    ).join();
  }

  // Sign Up: generate new keys and store them along with credentials
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final pub = _generateKey(32);
    final priv = _generateKey(64);

    // store keys and credentials
    await storage.write(key: 'publicKey', value: pub);
    await storage.write(key: 'privateKey', value: priv);
    await storage.write(key: 'username', value: _usernameController.text);
    await storage.write(key: 'password', value: _passwordController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MintoCoinApp(publicKey: pub, privateKey: priv),
      ),
    );
  }

  // Log In: read keys and validate credentials
  Future<void> _logIn() async {
    if (!_formKey.currentState!.validate()) return;

    final storedUsername = await storage.read(key: 'username');
    final storedPassword = await storage.read(key: 'password');
    final pub = await storage.read(key: 'publicKey');
    final priv = await storage.read(key: 'privateKey');

    if (storedUsername == _usernameController.text &&
        storedPassword == _passwordController.text &&
        pub != null &&
        priv != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MintoCoinApp(publicKey: pub, privateKey: priv),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid credentials or no account found."),
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin ? "Log In" : "Sign Up",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter username";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLogin ? _logIn : _signUp,
                  child: Text(_isLogin ? "Log In" : "Sign Up"),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() => _isLogin = !_isLogin);
                  },
                  child: Text(
                    _isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Log In",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
