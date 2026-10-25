import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/services/data_purge_service.dart';

void main() {
  late Directory docs;
  late Directory temp;
  late SharedPreferences prefs;

  setUp(() async {
    docs = await Directory.systemTemp.createTemp('purge_docs_');
    temp = await Directory.systemTemp.createTemp('purge_tmp_');
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark', 'x': 1});
    prefs = await SharedPreferences.getInstance();

    for (final suffix in ['', '-wal', '-shm']) {
      File(
        p.join(docs.path, AppConstants.databaseName + suffix),
      ).writeAsStringSync('data');
    }
    File(p.join(docs.path, 'unrelated.txt')).writeAsStringSync('keep');
    File(p.join(temp.path, 'drone.wav')).writeAsStringSync('audio');
    Directory(p.join(temp.path, 'sub')).createSync();
    File(p.join(temp.path, 'sub', 'export.pdf')).writeAsStringSync('pdf');
  });

  tearDown(() async {
    if (docs.existsSync()) await docs.delete(recursive: true);
    if (temp.existsSync()) await temp.delete(recursive: true);
  });

  DataPurgeService service({Future<void> Function()? close}) =>
      DataPurgeService(
        closeDatabase: close ?? () async {},
        preferences: prefs,
        documentsDirectory: () async => docs,
        temporaryDirectory: () async => temp,
      );

  test(
    'closes the database, then removes it, the settings and temp files',
    () async {
      var closed = false;
      await service(close: () async => closed = true).deleteAllData();

      expect(closed, isTrue);
      for (final suffix in ['', '-wal', '-shm']) {
        expect(
          File(
            p.join(docs.path, AppConstants.databaseName + suffix),
          ).existsSync(),
          isFalse,
        );
      }
      expect(prefs.getKeys(), isEmpty);
      expect(temp.listSync(), isEmpty);
    },
  );

  test('leaves files that are not the app database alone', () async {
    await service().deleteAllData();

    expect(File(p.join(docs.path, 'unrelated.txt')).existsSync(), isTrue);
  });

  test(
    'a failing step does not stop the others, then reports the failure',
    () async {
      final purge = service(close: () async => throw StateError('busy'));

      await expectLater(
        purge.deleteAllData(),
        throwsA(
          isA<StorageException>().having(
            (e) => e.kind,
            'kind',
            StorageFailure.deleteAllData,
          ),
        ),
      );
      expect(prefs.getKeys(), isEmpty);
      expect(temp.listSync(), isEmpty);
      expect(
        File(p.join(docs.path, AppConstants.databaseName)).existsSync(),
        isFalse,
      );
    },
  );

  test('works when there is nothing to delete', () async {
    await service().deleteAllData();
    await service().deleteAllData();
  });
}
