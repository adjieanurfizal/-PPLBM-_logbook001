import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0; 
  int _step = 1; 
  List <String> _log = [];

  int get value => _counter;
  int get step => _step;
  List<String> get log => _log;
  final String _keyCounter = 'last_counter';
  final String _keyLog = 'log_history';

  void _addLog(String message) {
    _log.insert(0, message);

    if (_log.length > 5) {  
      _log.removeLast(); 
    }
  }

  void increment(){
    _counter += _step;
    _addLog("Ditambah $_step pada ${DateTime.now().hour}:${DateTime.now().minute}, Total: $_counter");
    saveData();
  }

  void decrement() { 
    if (_counter > _step) _counter -= _step; 
    _addLog("Dikurangi $_step pada ${DateTime.now().hour}:${DateTime.now().minute}, Total: $_counter");
    saveData();
  }

  void reset(){
    _counter = 0;
    _log.clear(); 
  }

  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCounter, _counter);
    await prefs.setStringList(_keyLog, _log);
    await prefs.setInt('last_step', _step);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt(_keyCounter) ?? 0;
    _log = prefs.getStringList(_keyLog) ?? [];
    _step = prefs.getInt('last_step') ?? 1;
  }
}
