import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../themes/modern_theme.dart';
import '../components/app_drawer.dart';
import 'home_page.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final List<String> moodLabels = ["", "Harika", "İyi", "Orta", "Kötü", "Berbat"];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -50,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF03DAC6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A4A58)),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HomePage())
                            );
                          },
                        ),
                      ),

                      Text(
                          "İstatistikler",
                          style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestoreService.getPixelsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 20),
                              Text("Henüz veri yok.", style: GoogleFonts.poppins(color: Colors.grey[400])),
                            ],
                          ),
                        );
                      }
                      Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
                      int totalDays = docs.length;

                      for (var doc in docs) {
                        var data = doc.data() as Map<String, dynamic>;
                        int colorValue = data['color'];

                        for (int i = 1; i < ModernTheme.moodColors.length; i++) {
                          if (ModernTheme.moodColors[i].toARGB32() == colorValue || ModernTheme.moodColors[i].toARGB32() == colorValue) {
                            counts[i] = (counts[i] ?? 0) + 1;
                            break;
                          }
                        }
                      }

                      int mostFrequentMoodIndex = 1;
                      int maxCount = 0;
                      counts.forEach((key, value) {
                        if (value > maxCount) {
                          maxCount = value;
                          mostFrequentMoodIndex = key;
                        }
                      });

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text("$totalDays", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF6C63FF))),
                                        Text("Toplam Gün", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Genel Mod Kartı
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.emoji_emotions_rounded, color: ModernTheme.moodColors[mostFrequentMoodIndex], size: 32),
                                        const SizedBox(height: 5),
                                        Text(moodLabels[mostFrequentMoodIndex], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D3A))),
                                        Text("Genel Modun", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Mod Dağılımı", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D3A))),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))
                                  ]
                              ),
                              child: Column(
                                children: List.generate(5, (index) {
                                  int moodIndex = index + 1;
                                  int count = counts[moodIndex] ?? 0;
                                  double percentage = totalDays > 0 ? count / totalDays : 0;
                                  Color color = ModernTheme.moodColors[moodIndex];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 12, height: 12,
                                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(moodLabels[moodIndex], style: GoogleFonts.poppins(color: const Color(0xFF4A4A58), fontWeight: FontWeight.w500)),
                                              ],
                                            ),
                                            Text("${(percentage * 100).toStringAsFixed(0)}% ($count)", style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: percentage,
                                            minHeight: 8,
                                            backgroundColor: const Color(0xFFF4F5FA),
                                            valueColor: AlwaysStoppedAnimation<Color>(color),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}