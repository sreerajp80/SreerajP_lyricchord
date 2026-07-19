// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongNotesTable extends SongNotes
    with TableInfo<$SongNotesTable, SongNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lyricsMeta = const VerificationMeta('lyrics');
  @override
  late final GeneratedColumn<String> lyrics = GeneratedColumn<String>(
    'lyrics',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('C'),
  );
  static const VerificationMeta _bpmMeta = const VerificationMeta('bpm');
  @override
  late final GeneratedColumn<int> bpm = GeneratedColumn<int>(
    'bpm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    lyrics,
    key,
    bpm,
    favorite,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('lyrics')) {
      context.handle(
        _lyricsMeta,
        lyrics.isAcceptableOrUnknown(data['lyrics']!, _lyricsMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    }
    if (data.containsKey('bpm')) {
      context.handle(
        _bpmMeta,
        bpm.isAcceptableOrUnknown(data['bpm']!, _bpmMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongNoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      lyrics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lyrics'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      bpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bpm'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $SongNotesTable createAlias(String alias) {
    return $SongNotesTable(attachedDatabase, alias);
  }
}

class SongNoteRow extends DataClass implements Insertable<SongNoteRow> {
  final int id;
  final String title;
  final String artist;
  final String lyrics;
  final String key;
  final int bpm;
  final bool favorite;
  final int timestamp;
  const SongNoteRow({
    required this.id,
    required this.title,
    required this.artist,
    required this.lyrics,
    required this.key,
    required this.bpm,
    required this.favorite,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['lyrics'] = Variable<String>(lyrics);
    map['key'] = Variable<String>(key);
    map['bpm'] = Variable<int>(bpm);
    map['favorite'] = Variable<bool>(favorite);
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  SongNotesCompanion toCompanion(bool nullToAbsent) {
    return SongNotesCompanion(
      id: Value(id),
      title: Value(title),
      artist: Value(artist),
      lyrics: Value(lyrics),
      key: Value(key),
      bpm: Value(bpm),
      favorite: Value(favorite),
      timestamp: Value(timestamp),
    );
  }

  factory SongNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongNoteRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      lyrics: serializer.fromJson<String>(json['lyrics']),
      key: serializer.fromJson<String>(json['key']),
      bpm: serializer.fromJson<int>(json['bpm']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'lyrics': serializer.toJson<String>(lyrics),
      'key': serializer.toJson<String>(key),
      'bpm': serializer.toJson<int>(bpm),
      'favorite': serializer.toJson<bool>(favorite),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  SongNoteRow copyWith({
    int? id,
    String? title,
    String? artist,
    String? lyrics,
    String? key,
    int? bpm,
    bool? favorite,
    int? timestamp,
  }) => SongNoteRow(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    lyrics: lyrics ?? this.lyrics,
    key: key ?? this.key,
    bpm: bpm ?? this.bpm,
    favorite: favorite ?? this.favorite,
    timestamp: timestamp ?? this.timestamp,
  );
  SongNoteRow copyWithCompanion(SongNotesCompanion data) {
    return SongNoteRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      lyrics: data.lyrics.present ? data.lyrics.value : this.lyrics,
      key: data.key.present ? data.key.value : this.key,
      bpm: data.bpm.present ? data.bpm.value : this.bpm,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongNoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('lyrics: $lyrics, ')
          ..write('key: $key, ')
          ..write('bpm: $bpm, ')
          ..write('favorite: $favorite, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, artist, lyrics, key, bpm, favorite, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongNoteRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.lyrics == this.lyrics &&
          other.key == this.key &&
          other.bpm == this.bpm &&
          other.favorite == this.favorite &&
          other.timestamp == this.timestamp);
}

class SongNotesCompanion extends UpdateCompanion<SongNoteRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> lyrics;
  final Value<String> key;
  final Value<int> bpm;
  final Value<bool> favorite;
  final Value<int> timestamp;
  const SongNotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.key = const Value.absent(),
    this.bpm = const Value.absent(),
    this.favorite = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  SongNotesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.artist = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.key = const Value.absent(),
    this.bpm = const Value.absent(),
    this.favorite = const Value.absent(),
    required int timestamp,
  }) : title = Value(title),
       timestamp = Value(timestamp);
  static Insertable<SongNoteRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? lyrics,
    Expression<String>? key,
    Expression<int>? bpm,
    Expression<bool>? favorite,
    Expression<int>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (lyrics != null) 'lyrics': lyrics,
      if (key != null) 'key': key,
      if (bpm != null) 'bpm': bpm,
      if (favorite != null) 'favorite': favorite,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  SongNotesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? lyrics,
    Value<String>? key,
    Value<int>? bpm,
    Value<bool>? favorite,
    Value<int>? timestamp,
  }) {
    return SongNotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      lyrics: lyrics ?? this.lyrics,
      key: key ?? this.key,
      bpm: bpm ?? this.bpm,
      favorite: favorite ?? this.favorite,
      timestamp: timestamp ?? this.timestamp,
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
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (lyrics.present) {
      map['lyrics'] = Variable<String>(lyrics.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (bpm.present) {
      map['bpm'] = Variable<int>(bpm.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongNotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('lyrics: $lyrics, ')
          ..write('key: $key, ')
          ..write('bpm: $bpm, ')
          ..write('favorite: $favorite, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongNotesTable songNotes = $SongNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [songNotes];
}

typedef $$SongNotesTableCreateCompanionBuilder =
    SongNotesCompanion Function({
      Value<int> id,
      required String title,
      Value<String> artist,
      Value<String> lyrics,
      Value<String> key,
      Value<int> bpm,
      Value<bool> favorite,
      required int timestamp,
    });
typedef $$SongNotesTableUpdateCompanionBuilder =
    SongNotesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> artist,
      Value<String> lyrics,
      Value<String> key,
      Value<int> bpm,
      Value<bool> favorite,
      Value<int> timestamp,
    });

class $$SongNotesTableFilterComposer
    extends Composer<_$AppDatabase, $SongNotesTable> {
  $$SongNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $SongNotesTable> {
  $$SongNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongNotesTable> {
  $$SongNotesTableAnnotationComposer({
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

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get lyrics =>
      $composableBuilder(column: $table.lyrics, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get bpm =>
      $composableBuilder(column: $table.bpm, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$SongNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongNotesTable,
          SongNoteRow,
          $$SongNotesTableFilterComposer,
          $$SongNotesTableOrderingComposer,
          $$SongNotesTableAnnotationComposer,
          $$SongNotesTableCreateCompanionBuilder,
          $$SongNotesTableUpdateCompanionBuilder,
          (
            SongNoteRow,
            BaseReferences<_$AppDatabase, $SongNotesTable, SongNoteRow>,
          ),
          SongNoteRow,
          PrefetchHooks Function()
        > {
  $$SongNotesTableTableManager(_$AppDatabase db, $SongNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> lyrics = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<int> bpm = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
              }) => SongNotesCompanion(
                id: id,
                title: title,
                artist: artist,
                lyrics: lyrics,
                key: key,
                bpm: bpm,
                favorite: favorite,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> artist = const Value.absent(),
                Value<String> lyrics = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<int> bpm = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                required int timestamp,
              }) => SongNotesCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                lyrics: lyrics,
                key: key,
                bpm: bpm,
                favorite: favorite,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongNotesTable,
      SongNoteRow,
      $$SongNotesTableFilterComposer,
      $$SongNotesTableOrderingComposer,
      $$SongNotesTableAnnotationComposer,
      $$SongNotesTableCreateCompanionBuilder,
      $$SongNotesTableUpdateCompanionBuilder,
      (
        SongNoteRow,
        BaseReferences<_$AppDatabase, $SongNotesTable, SongNoteRow>,
      ),
      SongNoteRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongNotesTableTableManager get songNotes =>
      $$SongNotesTableTableManager(_db, _db.songNotes);
}
