import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'google_books_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // State variables for the "Auto-Fetcher"
  bool _isAutoFetching = false;
  int _totalToFetch = 0;
  int _currentFetchIndex = 0;
  String _statusMessage = "";

  // 1. The Manual "Magic Wand" (Single Book)
  Future<void> _enhanceBook(Book book, AppDatabase db) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Searching Google for '${book.title}'..."), duration: const Duration(milliseconds: 500)),
    );
    await _fetchAndSave(book, db);
    setState(() {}); // Refresh UI
  }

  // 2. The Core Logic (Fetch & Save)
  Future<void> _fetchAndSave(Book book, AppDatabase db) async {
    final details = await GoogleBooksService.fetchBookDetails(book.title, book.author);
    if (details['coverUrl'] != null || details['author'] != null) {
      await db.updateBookMetadata(
        book.id, 
        coverUrl: details['coverUrl'], 
        author: details['author'] ?? book.author
      );
    }
  }

  // 3. THE AUTO-PILOT (Loop with Delay)
  Future<void> _startAutoFetch(List<Book> allBooks, AppDatabase db) async {
    // Filter: Only get books that DON'T have a cover yet
    final missingCovers = allBooks.where((b) => b.coverUrl == null && !b.isOwned).toList();
    
    if (missingCovers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All books already have covers!")));
      return;
    }

    setState(() {
      _isAutoFetching = true;
      _totalToFetch = missingCovers.length;
      _currentFetchIndex = 0;
    });

    // The Loop
    for (int i = 0; i < missingCovers.length; i++) {
      // Emergency Stop Check
      if (!_isAutoFetching) break;

      final book = missingCovers[i];
      
      setState(() {
        _currentFetchIndex = i + 1;
        _statusMessage = "Fetching: ${book.title}";
      });

      // Fetch!
      await _fetchAndSave(book, db);

      // CRITICAL: The "Polite Delay" so Google doesn't ban us
      // 600ms = roughly 100 books per minute
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (mounted) {
      setState(() {
        _isAutoFetching = false;
        _statusMessage = "Done!";
      });
    }
  }

  // Stop Button Logic
  void _stopAutoFetch() {
    setState(() {
      _isAutoFetching = false;
      _statusMessage = "Stopped by user.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // THE CLOUD SYNC BUTTON
          if (!_isAutoFetching)
            IconButton(
              icon: const Icon(Icons.cloud_download, color: Colors.amberAccent),
              tooltip: "Auto-Fetch All Covers",
              onPressed: () async {
                final books = await database.getAllBooks();
                if (context.mounted) _startAutoFetch(books, database);
              },
            )
          else
            // SHOW STOP BUTTON IF RUNNING
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
              onPressed: _stopAutoFetch,
            ),
        ],
      ),
      body: Column(
        children: [
          // PROGRESS BAR (Only visible when running)
          if (_isAutoFetching)
            Container(
              color: Colors.black26,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _totalToFetch == 0 ? 0 : _currentFetchIndex / _totalToFetch,
                    backgroundColor: Colors.grey[800],
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "$_currentFetchIndex / $_totalToFetch - $_statusMessage",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // THE LIST
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: database.getAllBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !_isAutoFetching) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBooks = snapshot.data ?? [];
                // Filter: Wishlist books only
                final wishlistBooks = allBooks.where((b) => b.isOwned == false).toList();

                if (wishlistBooks.isEmpty) {
                  return const Center(
                    child: Text("Your Wishlist is empty.", style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  itemCount: wishlistBooks.length,
                  itemBuilder: (context, index) {
                    final book = wishlistBooks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        // LEADING: Show Image if we have it
                        leading: book.coverUrl != null
                            ? Image.network(book.coverUrl!, width: 50, fit: BoxFit.cover)
                            : const Icon(Icons.book, size: 40, color: Colors.grey),
                        
                        title: Text(
                          book.title, 
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis
                        ),
                        subtitle: Text(
                          book.author, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Manual Fix Button
                            IconButton(
                              icon: const Icon(Icons.auto_fix_high, size: 20, color: Colors.white24),
                              onPressed: () => _enhanceBook(book, database),
                            ),
                            // Move to Library Button
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                              onPressed: () async {
                                await database.markBookAsOwned(book.id);
                                setState(() {}); 
                              },
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
    );
  }
}