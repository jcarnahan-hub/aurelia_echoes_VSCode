import 'package:flutter/material.dart';
import 'database.dart';
import 'book_details_screen.dart'; // <--- Import the details screen

class BookSearchDelegate extends SearchDelegate {
  final List<Book> allBooks;
  final Function(Book) onBookUpdate;

  BookSearchDelegate({required this.allBooks, required this.onBookUpdate});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; 
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Book> displayList;
    
    if (query.isEmpty) {
      displayList = allBooks.take(50).toList();
    } else {
      displayList = allBooks.where((book) {
        final titleLower = book.title.toLowerCase();
        final authorLower = book.author.toLowerCase();
        final searchLower = query.toLowerCase();
        return titleLower.contains(searchLower) || authorLower.contains(searchLower);
      }).toList();
    }

    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              query.isEmpty ? "No books in database." : "No matching books found.",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF121212),
      child: ListView.builder(
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final book = displayList[index];
          return ListTile(
            leading: book.coverUrl != null 
              ? Image.network(book.coverUrl!, width: 40, fit: BoxFit.cover)
              : Icon(
                  book.isOwned ? Icons.book : Icons.favorite, 
                  color: book.isOwned ? Colors.deepPurpleAccent : Colors.redAccent
                ),
            title: Text(book.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(book.author, style: const TextStyle(color: Colors.grey)),
            onTap: () {
              // 1. Close the search bar logic
              // close(context, null); 
              
              // 2. Open the Details Screen directly!
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book))
              );
            },
          );
        },
      ),
    );
  }
}