import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart'; 

// --- 1. The Books Table ---
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  
  // Series Data
  TextColumn get seriesName => text().nullable()();
  RealColumn get seriesNumber => real().nullable()();
  
  // Metadata
  TextColumn get coverUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  
  // NEW: Date Added (Purchase/Loan Date)
  DateTimeColumn get dateAdded => dateTime().nullable()();

  // Status
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isOwned => boolean().withDefault(const Constant(false))(); 
  TextColumn get source => text().withDefault(const Constant('Manual'))();
}

// --- 2. The Database Class ---
@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Bump version to 2 because we added a column
  @override
  int get schemaVersion => 2;

  // Migration Logic: Instructions on how to upgrade from v1 to v2
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // We are upgrading from v1. Add the new column.
          await m.addColumn(books, books.dateAdded);
        }
      },
    );
  }

  // --- LOGIC ---
  
  Future<String> insertBookIfNotExists(BooksCompanion book) async {
    final existing = await (select(books)
      ..where((row) => row.title.equals(book.title.value))
      ..where((row) => row.author.equals(book.author.value))
    ).getSingleOrNull();

    if (existing == null) {
      await into(books).insert(book);
      return "Added";
    } else {
      return "Skipped (Duplicate)";
    }
  }
  
  Future<List<Book>> getAllBooks() => select(books).get();

  Future<void> deleteAllBooks() => delete(books).go();

  Future<void> markBookAsOwned(int id) {
    return (update(books)..where((t) => t.id.equals(id))).write(
      const BooksCompanion(
        isOwned: Value(true),
      ),
    );
  }

  Future<void> updateBookReadStatus(int id, bool isRead) {
    return (update(books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(
        isRead: Value(isRead),
      ),
    );
  }

  Future<void> deleteBook(int id) {
    return (delete(books)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateBookMetadata(int id, {
    String? coverUrl, 
    String? author, 
    String? seriesName, 
    double? seriesNumber
  }) {
    return (update(books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(
        coverUrl: coverUrl != null ? Value(coverUrl) : const Value.absent(),
        author: author != null ? Value(author) : const Value.absent(),
        seriesName: seriesName != null ? Value(seriesName) : const Value.absent(),
        seriesNumber: seriesNumber != null ? Value(seriesNumber) : const Value.absent(),
      ),
    );
  }
}

// --- 3. Connection Setup ---
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    return NativeDatabase.createInBackground(file);
  });
}