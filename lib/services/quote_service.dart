import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class QuoteService {
  static const String _fallbackQuote = "Her gün yeni bir başlangıçtır. (Bağlantı Sorunu)";

  static Future<String> getDailyQuote() async {
    try {
      final url = Uri.parse('https://dummyjson.com/quotes/random');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String englishQuote = data['quote'];
        String author = data['author'];
        final translator = GoogleTranslator();
        var translation = await translator.translate(englishQuote, from: 'en', to: 'tr');
        return "\"${translation.text}\"\n- $author";
      } else {
        debugPrint("API Hatası: ${response.statusCode}");
        return _fallbackQuote;
      }
    } catch (e) {
      debugPrint("Quote Servis Hatası: $e");
      return _fallbackQuote;
    }
  }
}