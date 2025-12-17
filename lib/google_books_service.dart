import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // We now return a Map containing Cover, Author, AND Series info
  static Future<Map<String, dynamic>> fetchBookDetails(String title, String author) async {
    try {
      String query = 'intitle:$title';
      if (author != "Unknown" && author.isNotEmpty) {
        query += '+inauthor:$author';
      }

      final url = Uri.parse('$_baseUrl?q=$query&maxResults=1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['totalItems'] > 0) {
          final bookData = data['items'][0]['volumeInfo'];
          
          // 1. Image Logic
          String? imageUrl;
          if (bookData['imageLinks'] != null) {
            imageUrl = bookData['imageLinks']['thumbnail'];
            imageUrl = imageUrl?.replaceFirst('http://', 'https://');
          }

          // 2. Author Logic
          String? foundAuthor;
          if (bookData['authors'] != null && (bookData['authors'] as List).isNotEmpty) {
            foundAuthor = bookData['authors'][0];
          }

          // 3. SERIES DETECTIVE LOGIC
          // Google doesn't have a dedicated "Series" field, but they often hide it in the "subtitle"
          // e.g., "Subtitle": "Book 1 of the Stormlight Archive"
          String? foundSeriesName;
          double? foundSeriesNumber;
          
          String subtitle = bookData['subtitle'] ?? "";
          String description = bookData['description'] ?? "";
          String titleFull = bookData['title'] ?? "";

          // Combine them to search for clues
          String textToSearch = "$titleFull $subtitle";

          // Pattern A: "SeriesName, Book 5"
          final patternA = RegExp(r'(.*), Book (\d+)');
          // Pattern B: "Book 5 of the SeriesName"
          final patternB = RegExp(r'Book (\d+) of (?:the )?(.*)');
          // Pattern C: "Vol 5 of SeriesName"
          final patternC = RegExp(r'Vol\.? (\d+) of (?:the )?(.*)');

          // Search!
          var match = patternA.firstMatch(textToSearch);
          if (match != null) {
             foundSeriesName = match.group(1);
             foundSeriesNumber = double.tryParse(match.group(2) ?? "1");
          } else {
            match = patternB.firstMatch(textToSearch);
            if (match == null) match = patternC.firstMatch(textToSearch);
            
            if (match != null) {
              foundSeriesNumber = double.tryParse(match.group(1) ?? "1");
              foundSeriesName = match.group(2);
            }
          }
          
          // Clean up the Series Name (remove trailing punctuation)
          if (foundSeriesName != null) {
            foundSeriesName = foundSeriesName.trim();
            if (foundSeriesName.endsWith(" Series")) {
              foundSeriesName = foundSeriesName.replaceAll(" Series", "");
            }
          }

          return {
            'coverUrl': imageUrl,
            'author': foundAuthor,
            'seriesName': foundSeriesName,
            'seriesNumber': foundSeriesNumber,
          };
        }
      }
    } catch (e) {
      print("Error fetching book: $e");
    }
    
    return {};
  }
}