import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/log_view.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isObscure = true;
  bool _isLocked = false;
  int _remainingSeconds = 0;

  void _handleLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    String? errorMessage = _controller.login(user, pass);

    if (errorMessage == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogView(username: user),
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selamat datang, $user!"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (errorMessage.contains("Login diblokir")) {
      setState(() {
        _isLocked = true;
        _remainingSeconds = _controller.lockDuration.inSeconds;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login diblokir selama $_remainingSeconds detik karena terlalu banyak percobaan gagal."),
          backgroundColor: Colors.red,
        ),
      );

      _controller.startLockdown(
        onTick: (seconds) {
          setState(() {
            _remainingSeconds = seconds;
          });
        },
        onComplete: () {
          setState(() {
            _isLocked = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Anda dapat mencoba login lagi."),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Portal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),

            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passController,
              obscureText: _isObscure, 
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure; 
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLocked ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: Text(_isLocked ? "Tunggu $_remainingSeconds detik" : "MASUK"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}