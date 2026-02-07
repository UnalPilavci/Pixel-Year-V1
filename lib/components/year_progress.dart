import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class YearProgress extends StatelessWidget {
  const YearProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year + 1, 1, 1);
    final totalDays = endOfYear.difference(startOfYear).inDays;
    final currentDay = now.difference(startOfYear).inDays + 1;
    final double percentage = currentDay / totalDays;
    final int percentInt = (percentage * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF5A52CC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${now.year} İlerlemesi",
                      style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                          "$currentDay. Gün / $totalDays",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3))
                ),
                child: Text(
                    "%$percentInt",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth * percentage;
                  if (percentage > 0 && width < 10) width = 10;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutExpo,
                    height: 10,
                    width: width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 1
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Yılın bitmesine ${totalDays - currentDay} gün kaldı",
              style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
            ),
          )
        ],
      ),
    );
  }
}