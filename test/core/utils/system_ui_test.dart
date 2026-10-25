import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/core/utils/system_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('enterImmersive hides the bars in sticky immersive mode', () async {
    await SystemUi.enterImmersive();

    final call = calls.singleWhere(
      (c) => c.method == 'SystemChrome.setEnabledSystemUIMode',
    );
    expect(call.arguments, 'SystemUiMode.immersiveSticky');
  });

  test('exitImmersive puts the bars back edge to edge', () async {
    await SystemUi.exitImmersive();

    final call = calls.singleWhere(
      (c) => c.method == 'SystemChrome.setEnabledSystemUIMode',
    );
    expect(call.arguments, 'SystemUiMode.edgeToEdge');
  });
}
