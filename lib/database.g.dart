// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seriesNameMeta =
      const VerificationMeta('seriesName');
  @override
  late final GeneratedColumn<String> seriesName = GeneratedColumn<String>(
      'series_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seriesNumberMeta =
      const VerificationMeta('seriesNumber');
  @override
  late final GeneratedColumn<double> seriesNumber = GeneratedColumn<double>(
      'series_number', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateAddedMeta =
      const VerificationMeta('dateAdded');
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
      'date_added', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isOwnedMeta =
      const VerificationMeta('isOwned');
  @override
  late final GeneratedColumn<bool> isOwned = GeneratedColumn<bool>(
      'is_owned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_owned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Manual'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        author,
        seriesName,
        seriesNumber,
        coverUrl,
        description,
        dateAdded,
        isRead,
        isOwned,
        source
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('series_name')) {
      context.handle(
          _seriesNameMeta,
          seriesName.isAcceptableOrUnknown(
              data['series_name']!, _seriesNameMeta));
    }
    if (data.containsKey('series_number')) {
      context.handle(
          _seriesNumberMeta,
          seriesNumber.isAcceptableOrUnknown(
              data['series_number']!, _seriesNumberMeta));
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('date_added')) {
      context.handle(_dateAddedMeta,
          dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('is_owned')) {
      context.handle(_isOwnedMeta,
          isOwned.isAcceptableOrUnknown(data['is_owned']!, _isOwnedMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      seriesName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series_name']),
      seriesNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}series_number']),
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      dateAdded: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_added']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      isOwned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_owned'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String author;
  final String? seriesName;
  final double? seriesNumber;
  final String? coverUrl;
  final String? description;
  final DateTime? dateAdded;
  final bool isRead;
  final bool isOwned;
  final String source;
  const Book(
      {required this.id,
      required this.title,
      required this.author,
      this.seriesName,
      this.seriesNumber,
      this.coverUrl,
      this.description,
      this.dateAdded,
      required this.isRead,
      required this.isOwned,
      required this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || seriesName != null) {
      map['series_name'] = Variable<String>(seriesName);
    }
    if (!nullToAbsent || seriesNumber != null) {
      map['series_number'] = Variable<double>(seriesNumber);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || dateAdded != null) {
      map['date_added'] = Variable<DateTime>(dateAdded);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['is_owned'] = Variable<bool>(isOwned);
    map['source'] = Variable<String>(source);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      seriesName: seriesName == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesName),
      seriesNumber: seriesNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesNumber),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dateAdded: dateAdded == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAdded),
      isRead: Value(isRead),
      isOwned: Value(isOwned),
      source: Value(source),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      seriesName: serializer.fromJson<String?>(json['seriesName']),
      seriesNumber: serializer.fromJson<double?>(json['seriesNumber']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      description: serializer.fromJson<String?>(json['description']),
      dateAdded: serializer.fromJson<DateTime?>(json['dateAdded']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isOwned: serializer.fromJson<bool>(json['isOwned']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'seriesName': serializer.toJson<String?>(seriesName),
      'seriesNumber': serializer.toJson<double?>(seriesNumber),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'description': serializer.toJson<String?>(description),
      'dateAdded': serializer.toJson<DateTime?>(dateAdded),
      'isRead': serializer.toJson<bool>(isRead),
      'isOwned': serializer.toJson<bool>(isOwned),
      'source': serializer.toJson<String>(source),
    };
  }

  Book copyWith(
          {int? id,
          String? title,
          String? author,
          Value<String?> seriesName = const Value.absent(),
          Value<double?> seriesNumber = const Value.absent(),
          Value<String?> coverUrl = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<DateTime?> dateAdded = const Value.absent(),
          bool? isRead,
          bool? isOwned,
          String? source}) =>
      Book(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        seriesName: seriesName.present ? seriesName.value : this.seriesName,
        seriesNumber:
            seriesNumber.present ? seriesNumber.value : this.seriesNumber,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        description: description.present ? description.value : this.description,
        dateAdded: dateAdded.present ? dateAdded.value : this.dateAdded,
        isRead: isRead ?? this.isRead,
        isOwned: isOwned ?? this.isOwned,
        source: source ?? this.source,
      );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      seriesName:
          data.seriesName.present ? data.seriesName.value : this.seriesName,
      seriesNumber: data.seriesNumber.present
          ? data.seriesNumber.value
          : this.seriesNumber,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      description:
          data.description.present ? data.description.value : this.description,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isOwned: data.isOwned.present ? data.isOwned.value : this.isOwned,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('seriesName: $seriesName, ')
          ..write('seriesNumber: $seriesNumber, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('description: $description, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('isRead: $isRead, ')
          ..write('isOwned: $isOwned, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, author, seriesName, seriesNumber,
      coverUrl, description, dateAdded, isRead, isOwned, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.seriesName == this.seriesName &&
          other.seriesNumber == this.seriesNumber &&
          other.coverUrl == this.coverUrl &&
          other.description == this.description &&
          other.dateAdded == this.dateAdded &&
          other.isRead == this.isRead &&
          other.isOwned == this.isOwned &&
          other.source == this.source);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String?> seriesName;
  final Value<double?> seriesNumber;
  final Value<String?> coverUrl;
  final Value<String?> description;
  final Value<DateTime?> dateAdded;
  final Value<bool> isRead;
  final Value<bool> isOwned;
  final Value<String> source;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.seriesName = const Value.absent(),
    this.seriesNumber = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isOwned = const Value.absent(),
    this.source = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String author,
    this.seriesName = const Value.absent(),
    this.seriesNumber = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isOwned = const Value.absent(),
    this.source = const Value.absent(),
  })  : title = Value(title),
        author = Value(author);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? seriesName,
    Expression<double>? seriesNumber,
    Expression<String>? coverUrl,
    Expression<String>? description,
    Expression<DateTime>? dateAdded,
    Expression<bool>? isRead,
    Expression<bool>? isOwned,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (seriesName != null) 'series_name': seriesName,
      if (seriesNumber != null) 'series_number': seriesNumber,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (description != null) 'description': description,
      if (dateAdded != null) 'date_added': dateAdded,
      if (isRead != null) 'is_read': isRead,
      if (isOwned != null) 'is_owned': isOwned,
      if (source != null) 'source': source,
    });
  }

  BooksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? author,
      Value<String?>? seriesName,
      Value<double?>? seriesNumber,
      Value<String?>? coverUrl,
      Value<String?>? description,
      Value<DateTime?>? dateAdded,
      Value<bool>? isRead,
      Value<bool>? isOwned,
      Value<String>? source}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      seriesName: seriesName ?? this.seriesName,
      seriesNumber: seriesNumber ?? this.seriesNumber,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      dateAdded: dateAdded ?? this.dateAdded,
      isRead: isRead ?? this.isRead,
      isOwned: isOwned ?? this.isOwned,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (seriesName.present) {
      map['series_name'] = Variable<String>(seriesName.value);
    }
    if (seriesNumber.present) {
      map['series_number'] = Variable<double>(seriesNumber.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isOwned.present) {
      map['is_owned'] = Variable<bool>(isOwned.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('seriesName: $seriesName, ')
          ..write('seriesNumber: $seriesNumber, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('description: $description, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('isRead: $isRead, ')
          ..write('isOwned: $isOwned, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [books];
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String title,
  required String author,
  Value<String?> seriesName,
  Value<double?> seriesNumber,
  Value<String?> coverUrl,
  Value<String?> description,
  Value<DateTime?> dateAdded,
  Value<bool> isRead,
  Value<bool> isOwned,
  Value<String> source,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> author,
  Value<String?> seriesName,
  Value<double?> seriesNumber,
  Value<String?> coverUrl,
  Value<String?> description,
  Value<DateTime?> dateAdded,
  Value<bool> isRead,
  Value<bool> isOwned,
  Value<String> source,
});

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seriesName => $composableBuilder(
      column: $table.seriesName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get seriesNumber => $composableBuilder(
      column: $table.seriesNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOwned => $composableBuilder(
      column: $table.isOwned, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seriesName => $composableBuilder(
      column: $table.seriesName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get seriesNumber => $composableBuilder(
      column: $table.seriesNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOwned => $composableBuilder(
      column: $table.isOwned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get seriesName => $composableBuilder(
      column: $table.seriesName, builder: (column) => column);

  GeneratedColumn<double> get seriesNumber => $composableBuilder(
      column: $table.seriesNumber, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isOwned =>
      $composableBuilder(column: $table.isOwned, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$BooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
    Book,
    PrefetchHooks Function()> {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String?> seriesName = const Value.absent(),
            Value<double?> seriesNumber = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime?> dateAdded = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isOwned = const Value.absent(),
            Value<String> source = const Value.absent(),
          }) =>
              BooksCompanion(
            id: id,
            title: title,
            author: author,
            seriesName: seriesName,
            seriesNumber: seriesNumber,
            coverUrl: coverUrl,
            description: description,
            dateAdded: dateAdded,
            isRead: isRead,
            isOwned: isOwned,
            source: source,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String author,
            Value<String?> seriesName = const Value.absent(),
            Value<double?> seriesNumber = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime?> dateAdded = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isOwned = const Value.absent(),
            Value<String> source = const Value.absent(),
          }) =>
              BooksCompanion.insert(
            id: id,
            title: title,
            author: author,
            seriesName: seriesName,
            seriesNumber: seriesNumber,
            coverUrl: coverUrl,
            description: description,
            dateAdded: dateAdded,
            isRead: isRead,
            isOwned: isOwned,
            source: source,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
    Book,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
}
