import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:lyricchord/data/app_database.dart';

void main() {
  test(
    'checkpointWal runs on a WAL database file and keeps the data',
    () async {
      final dir = await Directory.systemTemp.createTemp('lyricchord_wal_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File(p.join(dir.path, 'songs.sqlite'));

      final db = AppDatabase.forTesting(
        NativeDatabase(file, setup: applyPragmas),
      );
      final before = await db.select(db.songNotes).get();

      await db.checkpointWal();

      expect(await db.select(db.songNotes).get(), hasLength(before.length));
      await db.close();
    },
  );
}
