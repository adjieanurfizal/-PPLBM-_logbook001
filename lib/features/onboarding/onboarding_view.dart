import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; 

  // Data Onboarding 
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/hello.png", 
      "title": "Selamat Datang",
      "desc": "Aplikasi Logbook digital untuk mencatat aktivitas harianmu."
    },
    {
      "image": "assets/images/Polban.png",
      "title": "Catat Progres",
      "desc": "Pantau kenaikan angka dan riwayat aktivitas secara real-time."
    },
    {
      "image": "assets/images/meluncur.png",
      "title": "Aman & Nyaman",
      "desc": "Data tersimpan otomatis dan dilindungi sistem login yang aman."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. AREA GESER (PAGEVIEW)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(_onboardingData[index]["image"]!, height: 250), 
                        // const Icon(Icons.image, size: 100, color: Colors.indigo), // Placeholder jika gambar belum ada
                        
                        const SizedBox(height: 30),
                        Text(
                          _onboardingData[index]["title"]!,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _onboardingData[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 2. INDIKATOR & TOMBOL
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 5),
                        height: 10,
                        width: _currentIndex == index ? 20 : 10, 
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? Colors.indigo : Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex == _onboardingData.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(_currentIndex == _onboardingData.length - 1 ? "Mulai" : "Lanjut"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}