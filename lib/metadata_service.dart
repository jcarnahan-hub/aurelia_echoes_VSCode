import 'dart:convert';
import 'package:http/http.dart' as http;

class MetadataService {
  
  static Future<Map<String, dynamic>> fetchBookDetails(String title, String author) async {
    // 1. Ask Google Books (Best for Series info)
    Map<String, dynamic> data = await _queryGoogleBooks(title, author);

    // 2. Fallback to Open Library if Author/Cover is missing
    if (data['coverUrl'] == null || data['author'] == null || data['author'] == "Unknown") {
      // print("Google missing data for '$title'. Checking Open Library...");
      Map<String, dynamic> olData = await _queryOpenLibrary(title, author);

      data['coverUrl'] ??= olData['coverUrl'];
      data['author'] ??= olData['author'];
    }

    // 3. LAST RESORT: Check the Title itself!
    // Often the series info is already in your CSV title like "Title (Series, Book 1)"
    if (data['seriesName'] == null) {
      final localSeries = _extractSeriesFromText(title);
      if (localSeries['name'] != null) {
        data['seriesName'] = localSeries['name'];
        data['seriesNumber'] = localSeries['number'];
      }
    }

    return data;
  }

  // --- SOURCE A: GOOGLE BOOKS ---
  static Future<Map<String, dynamic>> _queryGoogleBooks(String title, String author) async {
    try {
      String query = 'intitle:$title';
      if (author != "Unknown" && author.isNotEmpty) {
        query += '+inauthor:$author';
      }
      
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['totalItems'] > 0) {
          final info = jsonResponse['items'][0]['volumeInfo'];
          
          String? img = info['imageLinks']?['thumbnail'];
          img = img?.replaceFirst('http://', 'https://');

          String? foundAuthor = (info['authors'] as List?)?.first;

          // --- SMART SERIES DETECTION ---
          // Check Subtitle first (most reliable)
          String subtitle = info['subtitle'] ?? "";
          var seriesData = _extractSeriesFromText(subtitle);
          
          // If not in subtitle, check the Description
          if (seriesData['name'] == null) {
             seriesData = _extractSeriesFromText(info['description'] ?? "");
          }
          
          // If still nothing, check the Title (e.g. "Dune (Dune Chronicles #1)")
          if (seriesData['name'] == null) {
             seriesData = _extractSeriesFromText(info['title'] ?? "");
          }

          return {
            'coverUrl': img,
            'author': foundAuthor,
            'seriesName': seriesData['name'],
            'seriesNumber': seriesData['number'],
          };
        }
      }
    } catch (e) {
      // print("Google Error: $e");
    }
    return {};
  }

  // --- SOURCE B: OPEN LIBRARY ---
  static Future<Map<String, dynamic>> _queryOpenLibrary(String title, String author) async {
    try {
      String query = 'title=${Uri.encodeComponent(title)}';
      if (author != "Unknown" && author.isNotEmpty) {
        query += '&author=${Uri.encodeComponent(author)}';
      }

      final url = Uri.parse('https://openlibrary.org/search.json?$query&limit=1');
      final response = await http.get(url, headers: {'User-Agent': 'AureliaEchoes/1.0'});

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['docs'] != null && (jsonResponse['docs'] as List).isNotEmpty) {
          final doc = jsonResponse['docs'][0];
          
          String? img;
          if (doc['cover_i'] != null) {
            img = "https://covers.openlibrary.org/b/id/${doc['cover_i']}-L.jpg"; 
          }
          
          String? foundAuthor;
          if (doc['author_name'] != null) {
            foundAuthor = doc['author_name'][0];
          }

          return {
            'coverUrl': img,
            'author': foundAuthor,
            'seriesName': null, 
            'seriesNumber': null,
          };
        }
      }
    } catch (e) {
      // print("OL Error: $e");
    }
    return {};
  }

  // --- HELPER: THE REGEX ARMY ---
  static Map<String, dynamic> _extractSeriesFromText(String text) {
    if (text.isEmpty) return {'name': null, 'number': null};

    // We define a list of common patterns.
    // Order matters! We try the most specific ones first.
    final patterns = [
      // Pattern 1: "Title (Series Name, Book 1)"  <-- Common in CSVs
      RegExp(r'\((.*), Book (\d+)\)', caseSensitive: false),
      
      // Pattern 2: "Title (Series Name #1)"
      RegExp(r'\((.*) #(\d+)\)', caseSensitive: false),

      // Pattern 3: "Title: Series Name, Book 1" <-- Audible Style
      RegExp(r': (.*), Book (\d+)', caseSensitive: false),

      // Pattern 4: "Book 1 of the Series Name" <-- Google Subtitle Style
      RegExp(r'Book (\d+) of (?:the )?(.*)', caseSensitive: false),
      
      // Pattern 5: "Series Name, Book 1" <-- Simple Subtitle
      RegExp(r'^(.*), Book (\d+)$', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String name;
        double number;

        // Handle the difference in group positions (some have Number first, some Name first)
        // Pattern 4 starts with Number (Group 1)
        if (pattern.pattern.startsWith('Book')) {
           number = double.tryParse(match.group(1) ?? "0") ?? 0;
           name = match.group(2) ?? "";
        } else {
           // Others have Name first (Group 1)
           name = match.group(1) ?? "";
           number = double.tryParse(match.group(2) ?? "0") ?? 0;
        }

        // Clean up the name
        name = name.trim();
        if (name.endsWith(" Series")) name = name.replaceAll(" Series", "");
        
        // Anti-Junk Filter: If the name is too long (like a full description), ignore it
        if (name.length > 50) continue; 

        return {'name': name, 'number': number};
      }
    }

    return {'name': null, 'number': null};
  }
}