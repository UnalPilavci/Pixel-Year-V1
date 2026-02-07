import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../pages/home_page.dart';
import '../pages/stats_page.dart';
import '../pages/gratitude_page.dart';
import '../pages/future_page.dart';
import '../pages/settings_page.dart';
import '../pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30)
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Lottie.asset(
                    "assets/animations/pixel_year_v1_pixel_animations_drawer.json",
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person_rounded, color: Color(0xFF6C63FF), size: 100);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Pixel Year",
                  style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? "Misafir Kullanıcı",
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildMenuItem(context, "Piksel Takvimi", Icons.grid_view_rounded, const HomePage()),
                _buildMenuItem(context, "İstatistikler", Icons.bar_chart_rounded, const StatsPage()),
                _buildMenuItem(context, "Şükür Kavanozu", Icons.favorite_rounded, const GratitudePage()),
                _buildMenuItem(context, "Zaman Kapsülü", Icons.rocket_launch_rounded, const FuturePage()),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Divider(color: Color(0xFFF4F5FA), thickness: 2),
                ),

                _buildMenuItem(context, "Ayarlar", Icons.settings_rounded, const SettingsPage()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage())
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Text("Çıkış Yap", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  "Geliştirici: Unal",
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF2D2D3A),
                      fontWeight: FontWeight.bold,
                      fontSize: 13
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.code_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      "Flutter ile geliştirildi",
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.favorite, size: 12, color: Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "v1.0.0",
                  style: GoogleFonts.poppins(color: Colors.grey.withValues(alpha: 0.5), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        ),
        title: Text(
            title,
            style: GoogleFonts.poppins(
                color: const Color(0xFF2D2D3A),
                fontWeight: FontWeight.w500,
                fontSize: 14
            )
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey[300]),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => page)
          );
        },
      ),
    );
  }
}