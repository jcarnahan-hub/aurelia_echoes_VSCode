import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'database.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // To get temp folder
import 'package:share_plus/share_plus.dart'; // To save/share the file

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isLoading = false;
  String _statusMessage = "Ready to manage library";

  // --- DATE HELPER ---
  DateTime? _parseDate(String rawDate) {
    if (rawDate.isEmpty) return null;
    try {
      if (rawDate.contains('/')) {
        return DateFormat("MM/dd/yyyy").parse(rawDate); 
      } else if (rawDate.contains('-')) {
        return DateTime.parse(rawDate);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // --- COLUMN HELPER ---
  int _findColumn(List<String> headers, List<String> possibleNames) {
    for (var name in possibleNames) {
      int index = headers.indexOf(name);
      if (index != -1) return index;
    }
    return -1;
  }

  // --- IMPORT LOGIC ---
  Future<void> _pickAndImportCsv() async {
    setState(() { _isLoading = true; _statusMessage = "Picking file..."; });

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null) {
        final file = File(result.files.single.path!);
        final input = file.openRead();
        final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

        if (fields.isEmpty) throw Exception("File is empty!");

        final headers = fields[0].map((e) => e.toString().toLowerCase().trim()).toList();
        final titleIndex = _findColumn(headers, ['title', 'book title', 'name', 'book']);
        final authorIndex = _findColumn(headers, ['author', 'authors', 'written by']);
        
        if (titleIndex == -1 || authorIndex == -1) {
          throw Exception("Could not find 'Title' or 'Author' columns.");
        }

        final dateIndex = _findColumn(headers, ['date added', 'added', 'purchase date', 'date']);
        bool isWishlist = result.files.single.name.toLowerCase().contains('wishlist');
        bool isLibrary = !isWishlist;
        int addedCount = 0;
        
        final db = Provider.of<AppDatabase>(context, listen: false);

        for (var i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length <= titleIndex || row.length <= authorIndex) continue;

          String title = row[titleIndex].toString();
          String author = row[authorIndex].toString();
          DateTime? dateAdded;

          if (dateIndex != -1 && row.length > dateIndex) {
            dateAdded = _parseDate(row[dateIndex].toString());
          }

          await db.insertBookIfNotExists(BooksCompanion(
            title: drift.Value(title),
            author: drift.Value(author),
            isOwned: drift.Value(isLibrary),
            source: const drift.Value("CSV Import"),
            dateAdded: dateAdded != null ? drift.Value(dateAdded) : const drift.Value.absent(),
          ));
          addedCount++;
        }
        setState(() { _statusMessage = "Success! Processed $addedCount books."; });
      } else {
        setState(() { _statusMessage = "Cancelled"; });
      }
    } catch (e) {
      setState(() { _statusMessage = "Error: $e"; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // --- EXPORT / BACKUP LOGIC ---
  Future<void> _backupLibrary() async {
    setState(() { _isLoading = true; _statusMessage = "Preparing backup..."; });

    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final allBooks = await db.getAllBooks();

      // Convert all books to a List of Maps (JSON)
      List<Map<String, dynamic>> jsonList = allBooks.map((book) {
        return {
          'title': book.title,
          'author': book.author,
          'seriesName': book.seriesName,
          'seriesNumber': book.seriesNumber,
          'coverUrl': book.coverUrl,
          'dateAdded': book.dateAdded?.toIso8601String(),
          'isRead': book.isRead,
          'isOwned': book.isOwned,
          'description': book.description,
        };
      }).toList();

      // Encode to String
      String jsonString = jsonEncode(jsonList);

      // Save to a temporary file
      final directory = await getTemporaryDirectory();
      final backupFile = File('${directory.path}/aurelia_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await backupFile.writeAsString(jsonString);

      // Share it (so user can save to Drive)
      await Share.shareXFiles([XFile(backupFile.path)], text: 'My Aurelia Echoes Library Backup');

      setState(() { _statusMessage = "Backup ready to save!"; });

    } catch (e) {
      setState(() { _statusMessage = "Backup Error: $e"; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _resetDatabase() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.deleteAllBooks();
    setState(() { _statusMessage = "Database cleared."; });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // IMPORT SECTION
            Icon(Icons.cloud_upload, size: 60, color: Colors.grey[800]),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickAndImportCsv,
              icon: const Icon(Icons.file_download),
              label: const Text("Import CSV (Audible)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),

            // EXPORT SECTION
            Icon(Icons.save, size: 60, color: Colors.amber[800]),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _backupLibrary,
              icon: const Icon(Icons.share),
              label: const Text("Backup Library (Save JSON)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[900],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            
            const SizedBox(height: 20),
            Text(_statusMessage, textAlign: TextAlign.center, style: TextStyle(color: _statusMessage.startsWith("Error") ? Colors.red : Colors.grey)),
            
            const SizedBox(height: 50),
            TextButton(
              onPressed: _resetDatabase,
              child: const Text("Reset Library (Delete All)", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}