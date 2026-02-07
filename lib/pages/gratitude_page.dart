import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../components/app_drawer.dart';
import 'home_page.dart';

class GratitudePage extends StatefulWidget {
  const GratitudePage({super.key});

  @override
  State<GratitudePage> createState() => _GratitudePageState();
}

class _GratitudePageState extends State<GratitudePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _gratitudeController = TextEditingController();

  bool _isAdding = false;
  void _addGratitude() async {
    final text = _gratitudeController.text.trim();
    if (text.isEmpty || _isAdding) return;

    setState(() => _isAdding = true);
    FocusScope.of(context).unfocus();

    try {
      await _firestoreService.addGratitude(text);
      _gratitudeController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Kavanoza eklendi! ⭐", style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFF6C63FF),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata oluştu!", style: GoogleFonts.poppins()), backgroundColor: Colors.redAccent)
        );
      }
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _isAdding = false);
        });
      }
    }
  }
  void _deleteNote(String docId) {
    _firestoreService.deleteGratitude(docId);
  }
  void _pickRandomNote(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kavanoz boş!", style: GoogleFonts.poppins()), backgroundColor: Colors.redAccent));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(children: [const CircularProgressIndicator(color: Color(0xFF6C63FF)), const SizedBox(width: 20), Text("Karıştırılıyor...", style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A)))]),
      ),
    );

    Timer(const Duration(seconds: 1), () {
      Navigator.pop(context);
      if (docs.isNotEmpty) {
        var data = docs[Random().nextInt(docs.length)].data() as Map<String, dynamic>;
        _showGratitudeDialog(data['text'] ?? "", (data['date'] as Timestamp?)?.toDate());
      }
    });
  }

  void _showGratitudeDialog(String text, DateTime? date) {
    String dateStr = date != null ? "${date.day}.${date.month}.${date.year}" : "";
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6C63FF), size: 40),
              const SizedBox(height: 15),
              Text("\"$text\"", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 18, fontStyle: FontStyle.italic)),
              const SizedBox(height: 20),
              Text(dateStr, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Harika!", style: GoogleFonts.poppins(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
  void _showAllGratitudes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text("Tüm Şükürlerin", style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Silmek için sola kaydır", style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 10)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getGratitudesStream(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) return Center(child: Text("Kavanoz bomboş 🌑", style: GoogleFonts.poppins(color: Colors.grey)));

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      String dateStr = (data['date'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? "";

                      return Dismissible(
                        key: Key(docs[index].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                        ),
                        onDismissed: (_) => _deleteNote(docs[index].id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF7F9FC),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.1))
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFF6C63FF), size: 20),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['text'] ?? "", style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(dateStr, style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double boxSize = 300.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: const AppDrawer(),
      resizeToAvoidBottomInset: false,

      floatingActionButton: FloatingActionButton(
        onPressed: _addGratitude,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 5,
        child: _isAdding
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.send_rounded, color: Colors.white),
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
            top: 150,
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

              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: boxSize,
                  height: boxSize,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10)
                        )
                      ]
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getGratitudesStream(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: docs.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.volunteer_activism_rounded, size: 50, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text("Kavanozun boş 🌑", style: GoogleFonts.poppins(color: Colors.grey[400])),
                            ],
                          ),
                        )
                            : SingleChildScrollView(
                          child: Center(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: docs.map((doc) {
                                final random = Random(doc.id.hashCode);
                                Color starColor = [
                                  const Color(0xFF6C63FF),
                                  const Color(0xFF03DAC6),
                                  const Color(0xFFFF9F1C),
                                  const Color(0xFFFF4081),
                                ][random.nextInt(4)];

                                return Icon(
                                    Icons.star_rounded,
                                    color: starColor,
                                    size: 32
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('gratitudes')
                            .get()
                            .then((snapshot) => _pickRandomNote(snapshot.docs));
                      }
                    },
                    icon: const Icon(Icons.change_circle_rounded, color: Colors.white),
                    label: Text("Karıştır", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                  ),
                  const SizedBox(width: 15),
                  OutlinedButton.icon(
                    onPressed: () => _showAllGratitudes(),
                    icon: const Icon(Icons.list_rounded, color: Color(0xFF6C63FF)),
                    label: Text("Listeyi Gör", style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                  ),
                ],
              ),

              const Spacer(),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))]
                ),
                padding: EdgeInsets.only(left: 20, right: 80, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: TextField(
                  controller: _gratitudeController,
                  style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A)),
                  decoration: InputDecoration(
                    hintText: "Bugün neye şükrediyorsun?",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFFF4F5FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onSubmitted: (_) => _addGratitude(),
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
          bottom: 10,
          left: 20,
          right: 20
      ),
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
              "Şükür Kavanozu",
              style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 20, fontWeight: FontWeight.bold)
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}