import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'database.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  // Controllers to handle text editing
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _seriesNameController;
  late TextEditingController _seriesNumberController;
  late TextEditingController _descController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the boxes with existing data
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _seriesNameController = TextEditingController(text: widget.book.seriesName ?? "");
    _seriesNumberController = TextEditingController(text: widget.book.seriesNumber?.toString() ?? "");
    _descController = TextEditingController(text: widget.book.description ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _seriesNameController.dispose();
    _seriesNumberController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    
    // Parse the series number (handle if user types text instead of numbers)
    double? sNum = double.tryParse(_seriesNumberController.text);

    // Create the updated data package
    final updatedBook = BooksCompanion(
      title: drift.Value(_titleController.text),
      author: drift.Value(_authorController.text),
      seriesName: drift.Value(_seriesNameController.text.isEmpty ? null : _seriesNameController.text),
      seriesNumber: drift.Value(sNum),
      description: drift.Value(_descController.text),
    );

    // Save to Database
    await (db.update(db.books)..where((t) => t.id.equals(widget.book.id)))
        .write(updatedBook);

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Changes Saved!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Go back to refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we are not editing, just show the nice view
    // If we ARE editing, show text boxes
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: Cover & Basic Info ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    image: widget.book.coverUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.book.coverUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.book.coverUrl == null
                      ? const Icon(Icons.book, size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Title & Author Inputs
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField("Title", _titleController, isBold: true),
                      const SizedBox(height: 10),
                      _buildTextField("Author", _authorController),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            
            // --- SERIES INFO ---
            const Text("Series Information", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField("Series Name (e.g. Harry Potter)", _seriesNameController),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _buildTextField("#", _seriesNumberController),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),

            // --- DESCRIPTION ---
            const Text("Description", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField("Summary...", _descController, maxLines: 8),
          ],
        ),
      ),
    );
  }

  // Helper widget to build text boxes nicely
  Widget _buildTextField(String label, TextEditingController controller, {bool isBold = false, int maxLines = 1}) {
    if (!_isEditing) {
      // READ-ONLY MODE
      if (controller.text.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          controller.text,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.white : Colors.white70,
          ),
        ),
      );
    } else {
      // EDIT MODE
      return TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: isBold ? 18 : 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      );
    }
  }
}