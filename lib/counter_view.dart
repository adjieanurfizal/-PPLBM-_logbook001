import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  Color _getTextColor(String log) {
    if (log.startsWith("Ditambah")) {
      return Colors.green;
    } else if (log.startsWith("Dikurangi")) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook: Versi SRP"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi Reset"),
                  content: const Text("Apakah Anda yakin ingin mereset hitungan dan log?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _controller.reset();
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Hitungan dan log telah direset."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text("Ya"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Hitungan:"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),

            const SizedBox(height: 20),
            const Text("Atur Langkah Hitungan:"),
            Slider(
              value: _controller.step.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: "${_controller.step}",
              onChanged: (double value) {
                setState(() {
                  _controller.setStep(value.toInt());
                });
              },
            ),

            const SizedBox(height: 20),
            const Text("Log Aktivitas Terakhir:"),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.log.length,
                itemBuilder: (context, index) {
                  final data = _controller.log[index];
                  return ListTile(
                    title: Text(
                      data,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: _getTextColor(data),
                        ),
                    ),
                    leading: Icon(
                      Icons.history,
                      color: _getTextColor(data),
                      ),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => setState(() => _controller.decrement()),
            child: const Icon(Icons.remove),
          ),

          const SizedBox(width: 10),
          
          FloatingActionButton(
            onPressed: () => setState(() => _controller.increment()),
            child: const Icon(Icons.add),
          ),
        ]
      )
    );
  }
}
