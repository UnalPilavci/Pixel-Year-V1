import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/app_drawer.dart';
import 'login_page.dart';
import 'home_page.dart';
import '../services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -60,
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
                          "Ayarlar",
                          style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10)
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                                    ]
                                ),
                                child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Hesap Bilgisi", style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(
                                      user?.email ?? "Misafir",
                                      style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                          child: Text("Genel", style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        _buildSettingsTile(
                          icon: Icons.notifications_rounded,
                          title: "Günlük Hatırlatıcı (21:00)",
                          trailing: Switch(
                            value: _notificationsEnabled,
                            activeColor: const Color(0xFF6C63FF),
                            trackColor: WidgetStateProperty.all(const Color(0xFF6C63FF).withValues(alpha: 0.2)),
                            thumbColor: WidgetStateProperty.all(Colors.white),
                            onChanged: (value) async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);

                              setState(() => _notificationsEnabled = value);

                              if (value) {
                                await NotificationService().requestPermissions();
                                await NotificationService().scheduleDailyNotification();

                                scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text("Hatırlatıcı kuruldu! Her akşam 21:00 🕘", style: GoogleFonts.poppins()),
                                      backgroundColor: const Color(0xFF6C63FF),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    )
                                );
                              } else {
                                await NotificationService().cancelNotifications();

                                scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text("Hatırlatıcı kapatıldı.", style: GoogleFonts.poppins()),
                                      backgroundColor: Colors.grey,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    )
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 15),
                        _buildSettingsTile(
                            icon: Icons.lock_rounded,
                            title: "Gizlilik Politikası",
                            trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 18),
                            onTap: () {
                            }
                        ),
                        const SizedBox(height: 30),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Text("Hesap", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        _buildSettingsTile(
                            icon: Icons.logout_rounded,
                            title: "Çıkış Yap",
                            textColor: Colors.redAccent,
                            iconColor: Colors.redAccent,
                            isLogout: true,
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage())
                                );
                              }
                            }
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color textColor = const Color(0xFF2D2D3A),
    Color iconColor = const Color(0xFF6C63FF),
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5)
          )
        ],
        border: isLogout ? Border.all(color: Colors.redAccent.withValues(alpha: 0.1)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600)),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}