import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../components/app_drawer.dart';
import 'home_page.dart';

class FuturePage extends StatefulWidget {
  const FuturePage({super.key});

  @override
  State<FuturePage> createState() => _FuturePageState();
}

class _FuturePageState extends State<FuturePage> {
  final FirestoreService _firestoreService = FirestoreService();
  void _writeLetter() async {
    TextEditingController noteController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    bool? isSaved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Geleceğe Mesaj 🚀", style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A)),
                    decoration: InputDecoration(
                      hintText: "Sevgili gelecekteki ben...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF4F5FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF6C63FF), size: 20),
                      const SizedBox(width: 10),
                      Text("Açılış Tarihi:", style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(primary: Color(0xFF6C63FF)),
                              ),
                              child: child!
                          );
                        },
                      );
                      if (!dialogContext.mounted) return;
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${selectedDate.day}.${selectedDate.month}.${selectedDate.year}",
                        style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text("Vazgeç", style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (noteController.text.isNotEmpty) {
                      await _firestoreService.addFutureLetter(noteController.text, selectedDate);
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: Text("Mühürle & Gönder", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (isSaved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Zaman kapsülü mühürlendi! ⏳", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: const Color(0xFF6C63FF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: const AppDrawer(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _writeLetter,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 5,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: Text("Mektup Yaz", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

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
            top: 100,
            right: -50,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF03DAC6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getFutureLettersStream(),
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
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
                              ),
                              child: const Icon(Icons.rocket_launch_rounded, size: 60, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            Text("Gelecek boş görünüyor...", style: GoogleFonts.poppins(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var data = docs[index].data() as Map<String, dynamic>;
                        String docId = docs[index].id;
                        String content = data['note'];
                        DateTime unlockDate = (data['unlockDate'] as Timestamp).toDate();
                        bool isLocked = DateTime.now().isBefore(unlockDate);

                        return _buildFutureCard(docId, content, unlockDate, isLocked);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          bottom: 20,
          left: 20,
          right: 20
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage())
                );
              },
            ),
          ),

          Text(
              "Zaman Kapsülü",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
  Widget _buildFutureCard(String docId, String content, DateTime unlockDate, bool isLocked) {
    Color iconColor = isLocked ? Colors.grey : const Color(0xFF6C63FF);
    Color bgColor = Colors.white;
    Color borderColor = isLocked ? Colors.transparent : const Color(0xFF6C63FF).withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Henüz zamanı gelmedi! 🤫", style: GoogleFonts.poppins(color: Colors.white)),
                    backgroundColor: const Color(0xFF2D2D3A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  )
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      const Icon(Icons.mark_email_read_rounded, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 10),
                      Text("Geçmişten Mesaj", style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  content: SingleChildScrollView(
                      child: Text(content, style: GoogleFonts.poppins(color: const Color(0xFF4A4A58), fontSize: 15))
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Kapat", style: GoogleFonts.poppins(color: const Color(0xFF6C63FF)))
                    )
                  ],
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLocked ? "KİLİTLİ MESAJ" : "OKUNABİLİR",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : const Color(0xFF6C63FF),
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isLocked
                            ? "Açılış: ${unlockDate.day}.${unlockDate.month}.${unlockDate.year}"
                            : content,
                        maxLines: isLocked ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2D2D3A),
                            fontSize: 14,
                            fontWeight: isLocked ? FontWeight.bold : FontWeight.normal
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isLocked)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () => _firestoreService.deleteFutureLetter(docId),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}