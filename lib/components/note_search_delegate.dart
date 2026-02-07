import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';


class NoteSearchDelegate extends SearchDelegate {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF6C63FF)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
      ),

      textTheme: TextTheme(
        titleLarge: GoogleFonts.poppins(
          color: const Color(0xFF2D2D3A),
          fontSize: 18,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF6C63FF),
        selectionColor: Color(0xFFE0E0FF),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Anılarda ara...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded, color: Colors.grey),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6C63FF)),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_rounded, size: 60, color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
            ),
            const SizedBox(height: 20),
            Text("Geçmiş günlerde ne yazmıştın?", style: GoogleFonts.poppins(color: Colors.grey[400])),
          ],
        ),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _firestoreService.searchNotes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_dissatisfied_rounded, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text("Hiçbir şey bulunamadı.", style: GoogleFonts.poppins(color: Colors.grey[500])),
              ],
            ),
          );
        }

        final results = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final data = results[index];
            final String note = data['note'];
            final DateTime date = data['realDate'];
            final int? colorCode = data['color'];
            Color noteColor = colorCode != null ? Color(colorCode) : Colors.grey;

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5)
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    close(context, null);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Bu anı ${date.day}.${date.month}.${date.year} tarihinde yaşandı.", style: GoogleFonts.poppins(color: Colors.white)),
                          backgroundColor: const Color(0xFF6C63FF),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        )
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: noteColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                              Icons.sticky_note_2_rounded,
                              color: noteColor,
                              size: 20
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF2D2D3A),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${date.day}.${date.month}.${date.year}",
                                style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        // Sağ Ok
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}