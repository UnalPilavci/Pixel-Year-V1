import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/modern_theme.dart';

class MoodSelector extends StatefulWidget {
  final int? existingMoodColor;
  final String? existingNote;
  final Function(Color, String, dynamic) onSaved;
  final VoidCallback onDelete;

  const MoodSelector({
    super.key,
    this.existingMoodColor,
    this.existingNote,
    required this.onSaved,
    required this.onDelete,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  int? _selectedColorIndex;
  int? _selectedIconIndex;

  final TextEditingController _noteController = TextEditingController();
  final List<String> _moodLabels = ["Harika", "İyi", "Orta", "Kötü", "Berbat"];
  final List<IconData> _icons = [
    Icons.fitness_center_rounded, Icons.menu_book_rounded, Icons.code_rounded, Icons.videogame_asset_rounded,
    Icons.movie_rounded, Icons.music_note_rounded, Icons.restaurant_rounded, Icons.bed_rounded,
    Icons.work_rounded, Icons.school_rounded, Icons.favorite_rounded, Icons.flight_rounded,
    Icons.shopping_cart_rounded, Icons.cleaning_services_rounded, Icons.pets_rounded,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingMoodColor != null) {
      int index = ModernTheme.moodColors.indexWhere((c) => c.toARGB32() == widget.existingMoodColor);
      if (index == -1) {
        index = ModernTheme.moodColors.indexWhere((c) => c.toARGB32() == widget.existingMoodColor);
      }

      if (index != -1) _selectedColorIndex = index;
    }
    if (widget.existingNote != null) {
      _noteController.text = widget.existingNote!;
    }
  }

  @override
  Widget build(BuildContext context) {
    int displayCount = ModernTheme.moodColors.length - 1;

    return Container(
      padding: EdgeInsets.only(
          top: 15,
          left: 25,
          right: 25,
          bottom: MediaQuery.of(context).viewInsets.bottom + 25
      ),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 30, spreadRadius: 5)
          ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 25),

          Text("Günün nasıldı?", style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayCount,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                int realIndex = i + 1;
                Color color = ModernTheme.moodColors[realIndex];
                bool isSelected = _selectedColorIndex == realIndex;

                String label = "";
                if (i < _moodLabels.length) label = _moodLabels[i];

                bool isGold = realIndex == 1;
                bool showGlow = isGold && isSelected;

                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = realIndex),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isSelected ? 60 : 45,
                          height: isSelected ? 60 : 45,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
                            boxShadow: showGlow
                                ? [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.6),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ]
                                : isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 15, offset: const Offset(0, 5))]
                                : [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                              color: isSelected ? const Color(0xFF2D2D3A) : Colors.grey[400],
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF4F5FA), thickness: 2),
          const SizedBox(height: 20),

          Text("Günün aktivitesi?", style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A), fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _icons.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                bool isSelected = _selectedIconIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIconIndex = isSelected ? null : index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFFF4F5FA),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: isSelected
                          ? [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Icon(
                      _icons[index],
                      color: isSelected ? Colors.white : Colors.grey[400],
                      size: 26,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 25),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _noteController,
              style: GoogleFonts.poppins(color: const Color(0xFF2D2D3A)),
              decoration: InputDecoration(
                hintText: "Günün notunu ekle...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              maxLines: 3,
            ),
          ),

          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedColorIndex == null) return;
                IconData? selectedIconData = _selectedIconIndex != null ? _icons[_selectedIconIndex!] : null;
                widget.onSaved(
                    ModernTheme.moodColors[_selectedColorIndex!],
                    _noteController.text,
                    selectedIconData
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColorIndex != null
                    ? ModernTheme.moodColors[_selectedColorIndex!]
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                elevation: _selectedColorIndex != null ? 5 : 0,
                shadowColor: _selectedColorIndex != null
                    ? ModernTheme.moodColors[_selectedColorIndex!].withValues(alpha: 0.5)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text("Kaydet", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          if (widget.existingMoodColor != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextButton(
                  onPressed: widget.onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent.withValues(alpha: 0.8),
                  ),
                  child: Text("Bu kaydı sil", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}