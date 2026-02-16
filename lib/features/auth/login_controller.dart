import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginController {
  // Database User Dummy
  final Map<String, String> _users = {
    'admin': 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 
    'dosen': 'b3a8e0e1f9ab1bfe3a36f231f676f78bb30a519d2b21e6c530c0eee8ebb4a5d0', 
    'mahasiswa': '25f9e794323b453885f5181f1b624d0b48dddd75e87382348a753a485719996d', 
  };

  int _failedAttempts = 0;
  final int _maxAttempts = 3;
  final Duration _lockDuration = const Duration(seconds: 10);
  Duration get lockDuration => _lockDuration;
  
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Ubah string ke bytes
    var digest = sha256.convert(bytes); // Lakukan hashing
    return digest.toString(); // Kembalikan sebagai string hex
  }

  // Login
  String? login(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return "Username dan Password tidak boleh kosong!";
    }

    if (_users.containsKey(username)) {
      String hashedPassword = _hashPassword(password);

      if (_users[username] == hashedPassword) {
        _failedAttempts = 0; 
        return null;
      } else {
        _failedAttempts++;
        if (_failedAttempts >= _maxAttempts) {
          return "Login diblokir selama ${_lockDuration.inSeconds} detik karena terlalu banyak percobaan gagal.";
        }
        return "Password salah!";
      }
    } else {
      return "Username tidak ditemukan!";
    }
  }

  // Timer Locked
  void startLockdown({
    required Function(int) onTick,
    required Function() onComplete,
  }){
    int remainingSeconds = _lockDuration.inSeconds;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        onTick(remainingSeconds);
        remainingSeconds--;
      } else {
        timer.cancel();
        _failedAttempts = 0; 
        onComplete();
      }
    });
  }

  
}
