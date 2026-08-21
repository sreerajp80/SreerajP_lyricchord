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
  static const VerificationMeta _scrollSpeedMeta = const VerificationMeta(
    'scrollSpeed',
  );
  @override
  late final GeneratedColumn<double> scrollSpeed = GeneratedColumn<double>(
    'scroll_speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _scrollMeasuresMeta = const VerificationMeta(
    'scrollMeasures',
  );
  @override
  late final GeneratedColumn<int> scrollMeasures = GeneratedColumn<int>(
    'scroll_measures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(32),
  );
  static const VerificationMeta _ragaMeta = const VerificationMeta('raga');
  @override
  late final GeneratedColumn<String> raga = GeneratedColumn<String>(
    'raga',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _talaMeta = const VerificationMeta('tala');
  @override
  late final GeneratedColumn<String> tala = GeneratedColumn<String>(
    'tala',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _traditionMeta = const VerificationMeta(
    'tradition',
  );
  @override
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
    'tradition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    scrollSpeed,
    scrollMeasures,
    raga,
    tala,
    tradition,
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
    if (data.containsKey('scroll_speed')) {
      context.handle(
        _scrollSpeedMeta,
        scrollSpeed.isAcceptableOrUnknown(
          data['scroll_speed']!,
          _scrollSpeedMeta,
        ),
      );
    }
    if (data.containsKey('scroll_measures')) {
      context.handle(
        _scrollMeasuresMeta,
        scrollMeasures.isAcceptableOrUnknown(
          data['scroll_measures']!,
          _scrollMeasuresMeta,
        ),
      );
    }
    if (data.containsKey('raga')) {
      context.handle(
        _ragaMeta,
        raga.isAcceptableOrUnknown(data['raga']!, _ragaMeta),
      );
    }
    if (data.containsKey('tala')) {
      context.handle(
        _talaMeta,
        tala.isAcceptableOrUnknown(data['tala']!, _talaMeta),
      );
    }
    if (data.containsKey('tradition')) {
      context.handle(
        _traditionMeta,
        tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta),
      );
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
      scrollSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scroll_speed'],
      )!,
      scrollMeasures: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scroll_measures'],
      )!,
      raga: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raga'],
      )!,
      tala: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tala'],
      )!,
      tradition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tradition'],
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

  /// Manual auto-scroll speed the user last set for this song (schema
  /// version 3). Saved per song so a sheet opens at the speed it was performed
  /// at last time.
  final double scrollSpeed;

  /// Tempo-Auto length in measures the user last set for this song (schema
  /// version 3).
  final int scrollMeasures;

  /// Raga name for an Indian song, `''` for a Western one (schema version 9).
  final String raga;

  /// Tala name for an Indian song, `''` for a Western one (schema version 9).
  final String tala;

  /// `western`, `carnatic`, `hindustani`, or `''` when not yet classified
  /// (schema version 9).
  ///
  /// Stored rather than worked out from the lyrics on every read. The old
  /// behaviour keyed off a `{raga: …}` header line, so a typo such as
  /// `{ragam: …}` made an Indian song look Western — and the transposer would
  /// then shift its `[Sa]` and `[Ma]` markers as if they were chord letters,
  /// quietly corrupting the sheet.
  final String tradition;
  const SongNoteRow({
    required this.id,
    required this.title,
    required this.artist,
    required this.lyrics,
    required this.key,
    required this.bpm,
    required this.favorite,
    required this.timestamp,
    required this.scrollSpeed,
    required this.scrollMeasures,
    required this.raga,
    required this.tala,
    required this.tradition,
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
    map['scroll_speed'] = Variable<double>(scrollSpeed);
    map['scroll_measures'] = Variable<int>(scrollMeasures);
    map['raga'] = Variable<String>(raga);
    map['tala'] = Variable<String>(tala);
    map['tradition'] = Variable<String>(tradition);
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
      scrollSpeed: Value(scrollSpeed),
      scrollMeasures: Value(scrollMeasures),
      raga: Value(raga),
      tala: Value(tala),
      tradition: Value(tradition),
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
      scrollSpeed: serializer.fromJson<double>(json['scrollSpeed']),
      scrollMeasures: serializer.fromJson<int>(json['scrollMeasures']),
      raga: serializer.fromJson<String>(json['raga']),
      tala: serializer.fromJson<String>(json['tala']),
      tradition: serializer.fromJson<String>(json['tradition']),
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
      'scrollSpeed': serializer.toJson<double>(scrollSpeed),
      'scrollMeasures': serializer.toJson<int>(scrollMeasures),
      'raga': serializer.toJson<String>(raga),
      'tala': serializer.toJson<String>(tala),
      'tradition': serializer.toJson<String>(tradition),
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
    double? scrollSpeed,
    int? scrollMeasures,
    String? raga,
    String? tala,
    String? tradition,
  }) => SongNoteRow(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    lyrics: lyrics ?? this.lyrics,
    key: key ?? this.key,
    bpm: bpm ?? this.bpm,
    favorite: favorite ?? this.favorite,
    timestamp: timestamp ?? this.timestamp,
    scrollSpeed: scrollSpeed ?? this.scrollSpeed,
    scrollMeasures: scrollMeasures ?? this.scrollMeasures,
    raga: raga ?? this.raga,
    tala: tala ?? this.tala,
    tradition: tradition ?? this.tradition,
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
      scrollSpeed: data.scrollSpeed.present
          ? data.scrollSpeed.value
          : this.scrollSpeed,
      scrollMeasures: data.scrollMeasures.present
          ? data.scrollMeasures.value
          : this.scrollMeasures,
      raga: data.raga.present ? data.raga.value : this.raga,
      tala: data.tala.present ? data.tala.value : this.tala,
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
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
          ..write('timestamp: $timestamp, ')
          ..write('scrollSpeed: $scrollSpeed, ')
          ..write('scrollMeasures: $scrollMeasures, ')
          ..write('raga: $raga, ')
          ..write('tala: $tala, ')
          ..write('tradition: $tradition')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    lyrics,
    key,
    bpm,
    favorite,
    timestamp,
    scrollSpeed,
    scrollMeasures,
    raga,
    tala,
    tradition,
  );
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
          other.timestamp == this.timestamp &&
          other.scrollSpeed == this.scrollSpeed &&
          other.scrollMeasures == this.scrollMeasures &&
          other.raga == this.raga &&
          other.tala == this.tala &&
          other.tradition == this.tradition);
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
  final Value<double> scrollSpeed;
  final Value<int> scrollMeasures;
  final Value<String> raga;
  final Value<String> tala;
  final Value<String> tradition;
  const SongNotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.key = const Value.absent(),
    this.bpm = const Value.absent(),
    this.favorite = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.scrollSpeed = const Value.absent(),
    this.scrollMeasures = const Value.absent(),
    this.raga = const Value.absent(),
    this.tala = const Value.absent(),
    this.tradition = const Value.absent(),
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
    this.scrollSpeed = const Value.absent(),
    this.scrollMeasures = const Value.absent(),
    this.raga = const Value.absent(),
    this.tala = const Value.absent(),
    this.tradition = const Value.absent(),
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
    Expression<double>? scrollSpeed,
    Expression<int>? scrollMeasures,
    Expression<String>? raga,
    Expression<String>? tala,
    Expression<String>? tradition,
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
      if (scrollSpeed != null) 'scroll_speed': scrollSpeed,
      if (scrollMeasures != null) 'scroll_measures': scrollMeasures,
      if (raga != null) 'raga': raga,
      if (tala != null) 'tala': tala,
      if (tradition != null) 'tradition': tradition,
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
    Value<double>? scrollSpeed,
    Value<int>? scrollMeasures,
    Value<String>? raga,
    Value<String>? tala,
    Value<String>? tradition,
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
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      scrollMeasures: scrollMeasures ?? this.scrollMeasures,
      raga: raga ?? this.raga,
      tala: tala ?? this.tala,
      tradition: tradition ?? this.tradition,
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
    if (scrollSpeed.present) {
      map['scroll_speed'] = Variable<double>(scrollSpeed.value);
    }
    if (scrollMeasures.present) {
      map['scroll_measures'] = Variable<int>(scrollMeasures.value);
    }
    if (raga.present) {
      map['raga'] = Variable<String>(raga.value);
    }
    if (tala.present) {
      map['tala'] = Variable<String>(tala.value);
    }
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
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
          ..write('timestamp: $timestamp, ')
          ..write('scrollSpeed: $scrollSpeed, ')
          ..write('scrollMeasures: $scrollMeasures, ')
          ..write('raga: $raga, ')
          ..write('tala: $tala, ')
          ..write('tradition: $tradition')
          ..write(')'))
        .toString();
  }
}

class $SetlistsTable extends Setlists
    with TableInfo<$SetlistsTable, SetlistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetlistsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetlistRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetlistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetlistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SetlistsTable createAlias(String alias) {
    return $SetlistsTable(attachedDatabase, alias);
  }
}

class SetlistRow extends DataClass implements Insertable<SetlistRow> {
  final int id;
  final String name;
  final String description;
  final int createdAt;
  final int updatedAt;
  const SetlistRow({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SetlistsCompanion toCompanion(bool nullToAbsent) {
    return SetlistsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SetlistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetlistRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SetlistRow copyWith({
    int? id,
    String? name,
    String? description,
    int? createdAt,
    int? updatedAt,
  }) => SetlistRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SetlistRow copyWithCompanion(SetlistsCompanion data) {
    return SetlistRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetlistRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetlistRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SetlistsCompanion extends UpdateCompanion<SetlistRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const SetlistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SetlistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SetlistRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SetlistsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return SetlistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetlistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SetlistItemsTable extends SetlistItems
    with TableInfo<$SetlistItemsTable, SetlistItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetlistItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _setlistIdMeta = const VerificationMeta(
    'setlistId',
  );
  @override
  late final GeneratedColumn<int> setlistId = GeneratedColumn<int>(
    'setlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES setlists(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES song_notes(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, setlistId, songId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetlistItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('setlist_id')) {
      context.handle(
        _setlistIdMeta,
        setlistId.isAcceptableOrUnknown(data['setlist_id']!, _setlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_setlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetlistItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetlistItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      setlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}setlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SetlistItemsTable createAlias(String alias) {
    return $SetlistItemsTable(attachedDatabase, alias);
  }
}

class SetlistItemRow extends DataClass implements Insertable<SetlistItemRow> {
  final int id;
  final int setlistId;
  final int songId;
  final int sortOrder;
  const SetlistItemRow({
    required this.id,
    required this.setlistId,
    required this.songId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['setlist_id'] = Variable<int>(setlistId);
    map['song_id'] = Variable<int>(songId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SetlistItemsCompanion toCompanion(bool nullToAbsent) {
    return SetlistItemsCompanion(
      id: Value(id),
      setlistId: Value(setlistId),
      songId: Value(songId),
      sortOrder: Value(sortOrder),
    );
  }

  factory SetlistItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetlistItemRow(
      id: serializer.fromJson<int>(json['id']),
      setlistId: serializer.fromJson<int>(json['setlistId']),
      songId: serializer.fromJson<int>(json['songId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'setlistId': serializer.toJson<int>(setlistId),
      'songId': serializer.toJson<int>(songId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  SetlistItemRow copyWith({
    int? id,
    int? setlistId,
    int? songId,
    int? sortOrder,
  }) => SetlistItemRow(
    id: id ?? this.id,
    setlistId: setlistId ?? this.setlistId,
    songId: songId ?? this.songId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  SetlistItemRow copyWithCompanion(SetlistItemsCompanion data) {
    return SetlistItemRow(
      id: data.id.present ? data.id.value : this.id,
      setlistId: data.setlistId.present ? data.setlistId.value : this.setlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetlistItemRow(')
          ..write('id: $id, ')
          ..write('setlistId: $setlistId, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, setlistId, songId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetlistItemRow &&
          other.id == this.id &&
          other.setlistId == this.setlistId &&
          other.songId == this.songId &&
          other.sortOrder == this.sortOrder);
}

class SetlistItemsCompanion extends UpdateCompanion<SetlistItemRow> {
  final Value<int> id;
  final Value<int> setlistId;
  final Value<int> songId;
  final Value<int> sortOrder;
  const SetlistItemsCompanion({
    this.id = const Value.absent(),
    this.setlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SetlistItemsCompanion.insert({
    this.id = const Value.absent(),
    required int setlistId,
    required int songId,
    required int sortOrder,
  }) : setlistId = Value(setlistId),
       songId = Value(songId),
       sortOrder = Value(sortOrder);
  static Insertable<SetlistItemRow> custom({
    Expression<int>? id,
    Expression<int>? setlistId,
    Expression<int>? songId,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setlistId != null) 'setlist_id': setlistId,
      if (songId != null) 'song_id': songId,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SetlistItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? setlistId,
    Value<int>? songId,
    Value<int>? sortOrder,
  }) {
    return SetlistItemsCompanion(
      id: id ?? this.id,
      setlistId: setlistId ?? this.setlistId,
      songId: songId ?? this.songId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (setlistId.present) {
      map['setlist_id'] = Variable<int>(setlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('setlistId: $setlistId, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongNotesTable songNotes = $SongNotesTable(this);
  late final $SetlistsTable setlists = $SetlistsTable(this);
  late final $SetlistItemsTable setlistItems = $SetlistItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songNotes,
    setlists,
    setlistItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'setlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('setlist_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'song_notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('setlist_items', kind: UpdateKind.delete)],
    ),
  ]);
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
      Value<double> scrollSpeed,
      Value<int> scrollMeasures,
      Value<String> raga,
      Value<String> tala,
      Value<String> tradition,
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
      Value<double> scrollSpeed,
      Value<int> scrollMeasures,
      Value<String> raga,
      Value<String> tala,
      Value<String> tradition,
    });

final class $$SongNotesTableReferences
    extends BaseReferences<_$AppDatabase, $SongNotesTable, SongNoteRow> {
  $$SongNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SetlistItemsTable, List<SetlistItemRow>>
  _setlistItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setlistItems,
    aliasName: 'song_notes__id__setlist_items__song_id',
  );

  $$SetlistItemsTableProcessedTableManager get setlistItemsRefs {
    final manager = $$SetlistItemsTableTableManager(
      $_db,
      $_db.setlistItems,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setlistItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<double> get scrollSpeed => $composableBuilder(
    column: $table.scrollSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scrollMeasures => $composableBuilder(
    column: $table.scrollMeasures,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raga => $composableBuilder(
    column: $table.raga,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tala => $composableBuilder(
    column: $table.tala,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradition => $composableBuilder(
    column: $table.tradition,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> setlistItemsRefs(
    Expression<bool> Function($$SetlistItemsTableFilterComposer f) f,
  ) {
    final $$SetlistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setlistItems,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetlistItemsTableFilterComposer(
            $db: $db,
            $table: $db.setlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<double> get scrollSpeed => $composableBuilder(
    column: $table.scrollSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scrollMeasures => $composableBuilder(
    column: $table.scrollMeasures,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raga => $composableBuilder(
    column: $table.raga,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tala => $composableBuilder(
    column: $table.tala,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradition => $composableBuilder(
    column: $table.tradition,
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

  GeneratedColumn<double> get scrollSpeed => $composableBuilder(
    column: $table.scrollSpeed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scrollMeasures => $composableBuilder(
    column: $table.scrollMeasures,
    builder: (column) => column,
  );

  GeneratedColumn<String> get raga =>
      $composableBuilder(column: $table.raga, builder: (column) => column);

  GeneratedColumn<String> get tala =>
      $composableBuilder(column: $table.tala, builder: (column) => column);

  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  Expression<T> setlistItemsRefs<T extends Object>(
    Expression<T> Function($$SetlistItemsTableAnnotationComposer a) f,
  ) {
    final $$SetlistItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setlistItems,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetlistItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.setlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (SongNoteRow, $$SongNotesTableReferences),
          SongNoteRow,
          PrefetchHooks Function({bool setlistItemsRefs})
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
                Value<double> scrollSpeed = const Value.absent(),
                Value<int> scrollMeasures = const Value.absent(),
                Value<String> raga = const Value.absent(),
                Value<String> tala = const Value.absent(),
                Value<String> tradition = const Value.absent(),
              }) => SongNotesCompanion(
                id: id,
                title: title,
                artist: artist,
                lyrics: lyrics,
                key: key,
                bpm: bpm,
                favorite: favorite,
                timestamp: timestamp,
                scrollSpeed: scrollSpeed,
                scrollMeasures: scrollMeasures,
                raga: raga,
                tala: tala,
                tradition: tradition,
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
                Value<double> scrollSpeed = const Value.absent(),
                Value<int> scrollMeasures = const Value.absent(),
                Value<String> raga = const Value.absent(),
                Value<String> tala = const Value.absent(),
                Value<String> tradition = const Value.absent(),
              }) => SongNotesCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                lyrics: lyrics,
                key: key,
                bpm: bpm,
                favorite: favorite,
                timestamp: timestamp,
                scrollSpeed: scrollSpeed,
                scrollMeasures: scrollMeasures,
                raga: raga,
                tala: tala,
                tradition: tradition,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SongNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({setlistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (setlistItemsRefs) db.setlistItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setlistItemsRefs)
                    await $_getPrefetchedData<
                      SongNoteRow,
                      $SongNotesTable,
                      SetlistItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$SongNotesTableReferences
                          ._setlistItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SongNotesTableReferences(
                            db,
                            table,
                            p0,
                          ).setlistItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.songId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (SongNoteRow, $$SongNotesTableReferences),
      SongNoteRow,
      PrefetchHooks Function({bool setlistItemsRefs})
    >;
typedef $$SetlistsTableCreateCompanionBuilder =
    SetlistsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> description,
      required int createdAt,
      required int updatedAt,
    });
typedef $$SetlistsTableUpdateCompanionBuilder =
    SetlistsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$SetlistsTableReferences
    extends BaseReferences<_$AppDatabase, $SetlistsTable, SetlistRow> {
  $$SetlistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SetlistItemsTable, List<SetlistItemRow>>
  _setlistItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setlistItems,
    aliasName: 'setlists__id__setlist_items__setlist_id',
  );

  $$SetlistItemsTableProcessedTableManager get setlistItemsRefs {
    final manager = $$SetlistItemsTableTableManager(
      $_db,
      $_db.setlistItems,
    ).filter((f) => f.setlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setlistItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SetlistsTableFilterComposer
    extends Composer<_$AppDatabase, $SetlistsTable> {
  $$SetlistsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> setlistItemsRefs(
    Expression<bool> Function($$SetlistItemsTableFilterComposer f) f,
  ) {
    final $$SetlistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setlistItems,
      getReferencedColumn: (t) => t.setlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetlistItemsTableFilterComposer(
            $db: $db,
            $table: $db.setlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SetlistsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetlistsTable> {
  $$SetlistsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SetlistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetlistsTable> {
  $$SetlistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> setlistItemsRefs<T extends Object>(
    Expression<T> Function($$SetlistItemsTableAnnotationComposer a) f,
  ) {
    final $$SetlistItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setlistItems,
      getReferencedColumn: (t) => t.setlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetlistItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.setlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SetlistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetlistsTable,
          SetlistRow,
          $$SetlistsTableFilterComposer,
          $$SetlistsTableOrderingComposer,
          $$SetlistsTableAnnotationComposer,
          $$SetlistsTableCreateCompanionBuilder,
          $$SetlistsTableUpdateCompanionBuilder,
          (SetlistRow, $$SetlistsTableReferences),
          SetlistRow,
          PrefetchHooks Function({bool setlistItemsRefs})
        > {
  $$SetlistsTableTableManager(_$AppDatabase db, $SetlistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetlistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetlistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetlistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => SetlistsCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => SetlistsCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SetlistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({setlistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (setlistItemsRefs) db.setlistItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setlistItemsRefs)
                    await $_getPrefetchedData<
                      SetlistRow,
                      $SetlistsTable,
                      SetlistItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$SetlistsTableReferences
                          ._setlistItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SetlistsTableReferences(
                        db,
                        table,
                        p0,
                      ).setlistItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.setlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SetlistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetlistsTable,
      SetlistRow,
      $$SetlistsTableFilterComposer,
      $$SetlistsTableOrderingComposer,
      $$SetlistsTableAnnotationComposer,
      $$SetlistsTableCreateCompanionBuilder,
      $$SetlistsTableUpdateCompanionBuilder,
      (SetlistRow, $$SetlistsTableReferences),
      SetlistRow,
      PrefetchHooks Function({bool setlistItemsRefs})
    >;
typedef $$SetlistItemsTableCreateCompanionBuilder =
    SetlistItemsCompanion Function({
      Value<int> id,
      required int setlistId,
      required int songId,
      required int sortOrder,
    });
typedef $$SetlistItemsTableUpdateCompanionBuilder =
    SetlistItemsCompanion Function({
      Value<int> id,
      Value<int> setlistId,
      Value<int> songId,
      Value<int> sortOrder,
    });

final class $$SetlistItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SetlistItemsTable, SetlistItemRow> {
  $$SetlistItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SetlistsTable _setlistIdTable(_$AppDatabase db) =>
      db.setlists.createAlias('setlist_items__setlist_id__setlists__id');

  $$SetlistsTableProcessedTableManager get setlistId {
    final $_column = $_itemColumn<int>('setlist_id')!;

    final manager = $$SetlistsTableTableManager(
      $_db,
      $_db.setlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SongNotesTable _songIdTable(_$AppDatabase db) =>
      db.songNotes.createAlias('setlist_items__song_id__song_notes__id');

  $$SongNotesTableProcessedTableManager get songId {
    final $_column = $_itemColumn<int>('song_id')!;

    final manager = $$SongNotesTableTableManager(
      $_db,
      $_db.songNotes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SetlistItemsTable> {
  $$SetlistItemsTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$SetlistsTableFilterComposer get setlistId {
    final $$SetlistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setlistId,
      referencedTable: $db.setlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetlistsTableFilterComposer(
            $db: $db,
            $table: $db.setlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongNotesTableFilterComposer get songId {
    final $$SongNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songNotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongNotesTableFilterComposer(
            $db: $db,
            $table: $db.songNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetlistItemsTable> {
  $$SetlistItemsTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$SetlistsTableOrderingComposer get setlistId {
    final $$SetlistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setlistId,
      referencedTable: $db.setlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetlistsTableOrderingComposer(
            $db: $db,
            $table: $db.setlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongNotesTableOrderingComposer get songId {
    final $$SongNotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songNotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongNotesTableOrderingComposer(
            $db: $db,
            $table: $db.songNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetlistItemsTable> {
  $$SetlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$SetlistsTableAnnotationComposer get setlistId {
    final $$SetlistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setlistId,
      referencedTable: $db.setlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetlistsTableAnnotationComposer(
            $db: $db,
            $table: $db.setlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongNotesTableAnnotationComposer get songId {
    final $$SongNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songNotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.songNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetlistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetlistItemsTable,
          SetlistItemRow,
          $$SetlistItemsTableFilterComposer,
          $$SetlistItemsTableOrderingComposer,
          $$SetlistItemsTableAnnotationComposer,
          $$SetlistItemsTableCreateCompanionBuilder,
          $$SetlistItemsTableUpdateCompanionBuilder,
          (SetlistItemRow, $$SetlistItemsTableReferences),
          SetlistItemRow,
          PrefetchHooks Function({bool setlistId, bool songId})
        > {
  $$SetlistItemsTableTableManager(_$AppDatabase db, $SetlistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> setlistId = const Value.absent(),
                Value<int> songId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SetlistItemsCompanion(
                id: id,
                setlistId: setlistId,
                songId: songId,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int setlistId,
                required int songId,
                required int sortOrder,
              }) => SetlistItemsCompanion.insert(
                id: id,
                setlistId: setlistId,
                songId: songId,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SetlistItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({setlistId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (setlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.setlistId,
                                referencedTable: $$SetlistItemsTableReferences
                                    ._setlistIdTable(db),
                                referencedColumn: $$SetlistItemsTableReferences
                                    ._setlistIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$SetlistItemsTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$SetlistItemsTableReferences
                                    ._songIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetlistItemsTable,
      SetlistItemRow,
      $$SetlistItemsTableFilterComposer,
      $$SetlistItemsTableOrderingComposer,
      $$SetlistItemsTableAnnotationComposer,
      $$SetlistItemsTableCreateCompanionBuilder,
      $$SetlistItemsTableUpdateCompanionBuilder,
      (SetlistItemRow, $$SetlistItemsTableReferences),
      SetlistItemRow,
      PrefetchHooks Function({bool setlistId, bool songId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongNotesTableTableManager get songNotes =>
      $$SongNotesTableTableManager(_db, _db.songNotes);
  $$SetlistsTableTableManager get setlists =>
      $$SetlistsTableTableManager(_db, _db.setlists);
  $$SetlistItemsTableTableManager get setlistItems =>
      $$SetlistItemsTableTableManager(_db, _db.setlistItems);
}
