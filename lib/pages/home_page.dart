import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/quote_service.dart';
import '../themes/modern_theme.dart';
import '../components/app_drawer.dart';
import '../components/mood_selector.dart';
import '../components/note_search_delegate.dart';
import '../components/year_progress.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = AuthService().currentUser;

  DateTime _focusedDate = DateTime.now();
  final List<String?> _moodLabels = [null, "Harika", "İyi", "Orta", "Kötü", "Berbat"];
  void _showMoodSelector(BuildContext context, DateTime date, [int? currentMood, String? currentNote]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MoodSelector(
        existingMoodColor: currentMood,
        existingNote: currentNote,
        onSaved: (color, note, dynamic activityIcon) {
          int? iconCode;
          if (activityIcon != null) {
            if (activityIcon is int) {
              iconCode = activityIcon;
            } else if (activityIcon is IconData) {
              iconCode = activityIcon.codePoint;
            }
          }
          _firestoreService.addPixel(date, color.toARGB32(), note, iconCode);
          Navigator.pop(context);
          setState(() {});
        },
        onDelete: () {
          _firestoreService.deletePixel(date);
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: const AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getPixelsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
          }

          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

          return Stack(
            children: [
              Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6C63FF),
                      Color(0xFF03DAC6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
              ),
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMonthNavigator(),
                              const SizedBox(height: 20),
                              _buildModernPixelGrid(docs),
                              const SizedBox(height: 30),
                              _buildSoftStatsCard(docs),
                              const SizedBox(height: 30),
                              const YearProgress(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMoodSelector(context, DateTime.now()),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Bugünü Ekle", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        Text(
            "Pixel Year",
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))]
            )
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () => showSearch(context: context, delegate: NoteSearchDelegate()),
          ),
        ),
      ],
    );
  }
  Widget _buildMonthNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6C63FF), size: 18),
            onPressed: () => setState(() => _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1)),
          ),
          Text(
            "${_monthName(_focusedDate.month)} ${_focusedDate.year}",
            style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF6C63FF), size: 18),
            onPressed: () => setState(() => _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1)),
          ),
        ],
      ),
    );
  }
  Widget _buildModernPixelGrid(List<QueryDocumentSnapshot> docs) {
    int daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        DateTime day = DateTime(_focusedDate.year, _focusedDate.month, index + 1);

        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);
        bool isFuture = day.isAfter(today);
        bool isToday = day.year == now.year && day.month == now.month && day.day == now.day;

        final int docIndex = docs.indexWhere((doc) {
          Timestamp t = (doc.data() as Map<String, dynamic>)['date'];
          DateTime d = t.toDate();
          return d.year == day.year && d.month == day.month && d.day == day.day;
        });

        bool hasData = docIndex != -1;

        int colorValue = 0;
        String? note;
        int? iconCode;
        if (hasData) {
          final data = docs[docIndex].data() as Map<String, dynamic>;
          colorValue = data['color'];
          note = data['note'];
          iconCode = data['icon'];
        }
        Color boxColor = hasData ? Color(colorValue) : const Color(0xFFF3F2FF);
        Color iconColor = boxColor.computeLuminance() > 0.5 ? const Color(0xFF6C63FF) : Colors.white;
        Color textColor = hasData ? iconColor : Colors.grey[400]!;
        if (isFuture) {
          boxColor = Colors.white.withValues(alpha: 0.5);
        }
        return GestureDetector(
          onTap: () {
            if (isFuture) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Bu güne henüz gelmedik! ⏳", style: GoogleFonts.poppins(color: Colors.white)),
                  backgroundColor: const Color(0xFF6C63FF),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }
            _showMoodSelector(context, day, hasData ? colorValue : null, note);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                  : null,
              boxShadow: [
                if (hasData)
                  BoxShadow(color: boxColor.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${index + 1}",
                  style: GoogleFonts.poppins(
                      color: isFuture ? Colors.grey[300] : textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13
                  ),
                ),
                if (hasData && iconCode != null) ...[
                  const SizedBox(height: 2),
                  Icon(
                    IconData(iconCode, fontFamily: 'MaterialIcons'),
                    color: iconColor,
                    size: 16,
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildSoftStatsCard(List<QueryDocumentSnapshot> docs) {
    List<DateTime> filledDates = [];
    Map<int, int> moodCounts = {};

    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['date'] != null) {
        DateTime date = (data['date'] as Timestamp).toDate();
        filledDates.add(DateTime(date.year, date.month, date.day));
        int? color = data['color'];
        if (color != null) moodCounts[color] = (moodCounts[color] ?? 0) + 1;
      }
    }

    filledDates.sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    if (!filledDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    while (filledDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    int? dominantColorValue;
    String dominantLabel = "Veri Yok";
    int maxCount = 0;

    if (moodCounts.isNotEmpty) {
      moodCounts.forEach((colorVal, moodCount) {
        if (moodCount > maxCount) {
          maxCount = moodCount;
          dominantColorValue = colorVal;
        }
      });
    }
    if (dominantColorValue != null) {
      int colorIndex = ModernTheme.moodColors.indexWhere((c) => c.toARGB32() == dominantColorValue);
      if (colorIndex != -1 && colorIndex < _moodLabels.length) {
        dominantLabel = _moodLabels[colorIndex] ?? "Baskın";
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E85FF)]),
                    shape: BoxShape.circle
                ),
                child: const Icon(Icons.format_quote_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FutureBuilder<String>(
                  future: QuoteService.getDailyQuote(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Günün İlhamı", style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(snapshot.data!, style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 14, fontStyle: FontStyle.italic)),
                        ],
                      );
                    }
                    return Text("Yükleniyor...", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(color: Color(0xFFF4F5FA), thickness: 2),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _buildStatItem(Icons.local_fire_department_rounded, Colors.orangeAccent, "$streak Gün", "Seri")),
              Expanded(
                  child: _buildStatItem(
                      Icons.emoji_events_rounded,
                      dominantColorValue != null ? Color(dominantColorValue!) : Colors.grey[300]!,
                      dominantLabel,
                      "Mod"
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStatItem(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13)),
          ],
        )
      ],
    );
  }
  String _monthName(int month) {
    const months = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    return months[month];
  }
}