import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});

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
        title: Text("LogBook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext conteks){
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const OnboardingView()),
                            (route) => false,
                          );
                        },
                        child: const Text("Ya"),
                      ),
                    ],
                  );
                },
              );
            }
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Selamat datang, ${widget.username}!"),
            const SizedBox(height: 10),
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
            heroTag: "btnKurang",
            child: const Icon(Icons.remove),
          ),

          const SizedBox(width: 10),
          
          FloatingActionButton(
            onPressed: () => setState(() => _controller.increment()),
            heroTag: "btnTambah",
            child: const Icon(Icons.add),
          ),
        ]
      )
    );
  }
}
