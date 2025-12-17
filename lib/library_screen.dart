import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'database.dart';
import 'metadata_service.dart';
import 'book_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

// SORT ENUMS
enum SortOption { titleAsc, titleDesc, authorAsc, authorDesc, dateNewest, dateOldest }
// NEW: FILTER ENUMS
enum FilterOption { all, unread, read }

class _LibraryScreenState extends State<LibraryScreen> {
  // --- STATE VARIABLES ---
  bool _isAutoFetching = false;
  int _totalToFetch = 0;
  int _currentFetchIndex = 0;
  String _statusMessage = "";
  
  // Settings
  SortOption _currentSort = SortOption.dateNewest; 
  FilterOption _currentFilter = FilterOption.all; // Default: Show everything

  // --- LOGIC ---

  Future<void> _fetchAndSave(Book book, AppDatabase db) async {
    final details = await MetadataService.fetchBookDetails(book.title, book.author);
    if (details['coverUrl'] != null || details['author'] != null) {
      await db.updateBookMetadata(
        book.id, 
        coverUrl: details['coverUrl'], 
        author: details['author'] ?? book.author,
        seriesName: details['seriesName'],
        seriesNumber: details['seriesNumber']
      );
    }
  }

  Future<void> _startAutoFetch(List<Book> allBooks, AppDatabase db) async {
    final missingCovers = allBooks.where((b) => b.isOwned && b.coverUrl == null).toList();
    if (missingCovers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Your Library is fully covered!")));
      return;
    }
    setState(() {
      _isAutoFetching = true;
      _totalToFetch = missingCovers.length;
      _currentFetchIndex = 0;
    });

    for (int i = 0; i < missingCovers.length; i++) {
      if (!_isAutoFetching) break;
      final book = missingCovers[i];
      setState(() {
        _currentFetchIndex = i + 1;
        _statusMessage = "Fetching: ${book.title}";
      });
      await _fetchAndSave(book, db);
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (mounted) {
      setState(() {
        _isAutoFetching = false;
        _statusMessage = "Update Complete!";
      });
    }
  }

  void _stopAutoFetch() {
    setState(() { _isAutoFetching = false; _statusMessage = "Stopped."; });
  }

  Future<void> _toggleRead(Book book, AppDatabase db) async {
    final newStatus = !book.isRead;
    await db.updateBookReadStatus(book.id, newStatus);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("My Library"),
            // Show a tiny subtitle if a filter is active
            if (_currentFilter != FilterOption.all)
              Text(
                _currentFilter == FilterOption.unread ? "(Unread Only)" : "(Finished)",
                style: const TextStyle(fontSize: 12, color: Colors.amber),
              )
          ],
        ),
        actions: [
          // 1. FILTER BUTTON (Funnel)
          if (!_isAutoFetching)
            PopupMenuButton<FilterOption>(
              icon: Icon(
                Icons.filter_list, 
                color: _currentFilter == FilterOption.all ? Colors.white : Colors.amber
              ),
              tooltip: "Filter Books",
              onSelected: (FilterOption result) {
                setState(() { _currentFilter = result; });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterOption>>[
                const PopupMenuItem<FilterOption>(
                  value: FilterOption.all,
                  child: Text('Show All Books'),
                ),
                const PopupMenuItem<FilterOption>(
                  value: FilterOption.unread,
                  child: Text('Show Unread Only'),
                ),
                const PopupMenuItem<FilterOption>(
                  value: FilterOption.read,
                  child: Text('Show Read Only'),
                ),
              ],
            ),

          // 2. SORT BUTTON
          if (!_isAutoFetching)
            PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort),
              tooltip: "Sort Books",
              onSelected: (SortOption result) {
                setState(() { _currentSort = result; });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
                const PopupMenuItem<SortOption>(
                  value: SortOption.dateNewest,
                  child: Text('Date Added (Newest)'),
                ),
                const PopupMenuItem<SortOption>(
                  value: SortOption.dateOldest,
                  child: Text('Date Added (Oldest)'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<SortOption>(
                  value: SortOption.authorAsc,
                  child: Text('Author (A-Z)'),
                ),
                const PopupMenuItem<SortOption>(
                  value: SortOption.titleAsc,
                  child: Text('Title (A-Z)'),
                ),
              ],
            ),

          // 3. FETCH BUTTON
          if (!_isAutoFetching)
            IconButton(
              icon: const Icon(Icons.cloud_download, color: Colors.white54),
              onPressed: () async {
                final books = await database.getAllBooks();
                if (context.mounted) _startAutoFetch(books, database);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
              onPressed: _stopAutoFetch,
            ),
        ],
      ),
      body: Column(
        children: [
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
                  Text("$_currentFetchIndex / $_totalToFetch - $_statusMessage", style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

          Expanded(
            child: FutureBuilder<List<Book>>(
              future: database.getAllBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !_isAutoFetching) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBooks = snapshot.data ?? [];
                // 1. Basic Filter: Owned Books only
                var libraryBooks = allBooks.where((b) => b.isOwned == true).toList();
                
                // 2. Status Filter (Read/Unread)
                if (_currentFilter == FilterOption.unread) {
                  libraryBooks = libraryBooks.where((b) => !b.isRead).toList();
                } else if (_currentFilter == FilterOption.read) {
                  libraryBooks = libraryBooks.where((b) => b.isRead).toList();
                }

                // 3. Sorting
                libraryBooks.sort((a, b) {
                  switch (_currentSort) {
                    case SortOption.titleAsc:
                      return a.title.compareTo(b.title);
                    case SortOption.titleDesc:
                      return b.title.compareTo(a.title);
                    case SortOption.authorAsc:
                      return a.author.compareTo(b.author);
                    case SortOption.authorDesc:
                      return b.author.compareTo(a.author);
                    case SortOption.dateNewest:
                      if (a.dateAdded == null) return 1;
                      if (b.dateAdded == null) return -1;
                      return b.dateAdded!.compareTo(a.dateAdded!);
                    case SortOption.dateOldest:
                      if (a.dateAdded == null) return 1;
                      if (b.dateAdded == null) return -1;
                      return a.dateAdded!.compareTo(b.dateAdded!);
                  }
                });

                if (libraryBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list_off, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          _currentFilter == FilterOption.unread 
                            ? "You've read everything! Time to buy more books." 
                            : "No books match this filter.",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: libraryBooks.length,
                  itemBuilder: (context, index) {
                    final book = libraryBooks[index];
                    
                    return Dismissible(
                      key: Key(book.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        await database.deleteBook(book.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Deleted '${book.title}'"),
                              action: SnackBarAction(
                                label: "UNDO",
                                onPressed: () async {
                                  await database.insertBookIfNotExists(
                                    BooksCompanion.insert(
                                      title: book.title,
                                      author: book.author,
                                      isOwned: const drift.Value(true),
                                      isRead: drift.Value(book.isRead),
                                      coverUrl: drift.Value(book.coverUrl),
                                      seriesName: drift.Value(book.seriesName),
                                      seriesNumber: drift.Value(book.seriesNumber),
                                      dateAdded: drift.Value(book.dateAdded)
                                    )
                                  );
                                  setState(() {}); 
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: book.isRead ? Colors.black26 : null, 
                        child: ListTile(
                          onTap: () {
                             Navigator.push(
                               context, 
                               MaterialPageRoute(
                                 builder: (context) => BookDetailsScreen(book: book),
                               ),
                             ).then((_) {
                               setState(() {});
                             });
                          },
                          
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${index + 1}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(width: 8),
                              book.coverUrl != null
                                  ? Image.network(book.coverUrl!, width: 40, fit: BoxFit.cover)
                                  : const Icon(Icons.book, size: 30, color: Colors.deepPurple),
                            ],
                          ),
                          title: Text(
                            book.title, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: book.isRead ? TextDecoration.lineThrough : null,
                              color: book.isRead ? Colors.grey : Colors.white,
                            )
                          ),
                          subtitle: Text(book.author),
                          trailing: Checkbox(
                            value: book.isRead,
                            activeColor: Colors.green,
                            onChanged: (bool? value) {
                              _toggleRead(book, database);
                            },
                          ),
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