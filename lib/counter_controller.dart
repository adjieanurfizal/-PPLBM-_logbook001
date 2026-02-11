class CounterController {
  int _counter = 0; 
  int _step = 1; 
  final List <String> _log = [];

  int get value => _counter;
  int get step => _step;
  List<String> get log => _log;

  void _addLog(String message) {
    _log.insert(0, message);

    if (_log.length > 5) {  
      _log.removeLast(); 
    }
  }

  void increment(){
    _counter += _step;
    _addLog("Ditambah $_step pada ${DateTime.now().hour}:${DateTime.now().minute}, Total: $_counter");
  }

  void decrement() { 
    if (_counter > _step) _counter -= _step; 
    _addLog("Dikurangi $_step pada ${DateTime.now().hour}:${DateTime.now().minute}, Total: $_counter");
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
}
