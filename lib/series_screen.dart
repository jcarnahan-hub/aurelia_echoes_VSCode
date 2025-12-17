import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'metadata_service.dart'; // Uses the new dual-engine service
import 'book_details_screen.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  
  bool _isAnalyzing = false;
  String _status = "";

  // --- 1. THE DEEP SCAN (Google + OpenLibrary) ---
  Future<void> _deepScanSeries(List<Book> allBooks, AppDatabase db) async {
    setState(() {
      _isAnalyzing = true;
      _status = "Scanning Library...";
    });

    int fixedCount = 0;

    // Check books with missing series OR missing covers
    final booksToCheck = allBooks.where((b) => b.seriesName == null || b.coverUrl == null).toList();

    for (int i = 0; i < booksToCheck.length; i++) {
      if (!_isAnalyzing) break; // Stop button check

      final book = booksToCheck[i];
      setState(() {
        _status = "Checking Sources for: ${book.title}";
      });

      // Ask our new Unified Service
      final details = await MetadataService.fetchBookDetails(book.title, book.author);

      bool updated = false;
      // Logic: Only update if we found something new that we were missing
      if (details['seriesName'] != null && (book.seriesName == null || book.seriesName!.isEmpty)) updated = true;
      if (details['coverUrl'] != null && book.coverUrl == null) updated = true;
      if (details['author'] != null && (book.author == "Unknown" || book.author.isEmpty)) updated = true;

      if (updated) {
        await db.updateBookMetadata(
          book.id,
          seriesName: details['seriesName'] ?? book.seriesName,
          seriesNumber: details['seriesNumber'] ?? book.seriesNumber,
          author: details['author'] ?? book.author,
          coverUrl: details['coverUrl'] ?? book.coverUrl,
        );
        fixedCount++;
      }

      // Polite delay
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Analysis Complete. Updated $fixedCount books!"), 
          backgroundColor: Colors.green
        ),
      );
      setState(() {
        _isAnalyzing = false;
        _status = "";
      });
    }
  }

  // --- 2. GROUPING LOGIC ---
  Map<String, List<Book>> _groupBooksBySeries(List<Book> allBooks) {
    Map<String, List<Book>> groups = {};

    for (var book in allBooks) {
      if (book.seriesName == null || book.seriesName!.trim().isEmpty) {
        continue;
      }
      
      // Group by Series Name AND Author to prevent collisions
      final uniqueKey = "${book.seriesName}|${book.author}";
      
      if (!groups.containsKey(uniqueKey)) {
        groups[uniqueKey] = [];
      }
      groups[uniqueKey]!.add(book);
    }

    // Sort books inside series by Number
    for (var key in groups.keys) {
      groups[key]!.sort((a, b) {
        final numA = a.seriesNumber ?? 999;
        final numB = b.seriesNumber ?? 999;
        return numA.compareTo(numB);
      });
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Series"),
        actions: [
          // SCAN BUTTON
          if (!_isAnalyzing)
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.amber),
              tooltip: "Deep Scan for Series Data",
              onPressed: () async {
                final books = await database.getAllBooks();
                if (context.mounted) _deepScanSeries(books, database);
              },
            )
          else
             IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
              onPressed: () {
                setState(() { _isAnalyzing = false; });
              },
            )
        ],
      ),
      body: Column(
        children: [
          // PROGRESS BAR
          if (_isAnalyzing)
             Container(
              width: double.infinity,
              color: Colors.amber.withOpacity(0.2),
              padding: const EdgeInsets.all(8),
              child: Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber)),
             ),

          Expanded(
            child: FutureBuilder<List<Book>>(
              future: database.getAllBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !_isAnalyzing) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBooks = snapshot.data ?? [];
                final seriesGroups = _groupBooksBySeries(allBooks);
                
                final sortedKeys = seriesGroups.keys.toList();
                sortedKeys.sort((a, b) {
                  final nameA = a.split('|')[0];
                  final nameB = b.split('|')[0];
                  return nameA.compareTo(nameB);
                });

                if (sortedKeys.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shelves, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No series groups found yet.", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 20),
                        Text("Tap ✨ to search online for series info!", style: TextStyle(color: Colors.amber)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final key = sortedKeys[index];
                    final booksInSeries = seriesGroups[key]!;
                    
                    final parts = key.split('|');
                    final seriesName = parts[0];
                    final authorName = parts.length > 1 ? parts[1] : "";

                    final readCount = booksInSeries.where((b) => b.isRead).length;
                    final totalCount = booksInSeries.length;
                    final progress = totalCount > 0 ? readCount / totalCount : 0.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ExpansionTile(
                        leading: CircularProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[800],
                          color: Colors.amber,
                        ),
                        title: Text(seriesName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text("$authorName • $readCount/$totalCount Read"),
                        children: booksInSeries.map((book) {
                          return ListTile(
                            onTap: () {
                               Navigator.push(
                                 context, 
                                 MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book))
                               ).then((_) => setState((){}));
                            },
                            contentPadding: const EdgeInsets.only(left: 20, right: 10),
                            leading: book.coverUrl != null
                                ? Image.network(book.coverUrl!, width: 30, fit: BoxFit.cover)
                                : const Icon(Icons.bookmark, size: 20, color: Colors.grey),
                            title: Text(
                              book.title,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: book.isRead ? TextDecoration.lineThrough : null,
                                color: book.isRead ? Colors.grey : Colors.white,
                              ),
                            ),
                            trailing: Text(
                              "#${book.seriesNumber?.toStringAsFixed(1).replaceAll('.0', '') ?? '?'}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}