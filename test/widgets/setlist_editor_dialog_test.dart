import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/widgets/setlist_editor_dialog.dart';

import '../helpers/localized_app.dart';

void main() {
  /// Opens the dialog from a button and returns a holder for its result.
  Future<List<Map<String, String>?>> openDialog(
    WidgetTester tester, {
    Setlist? setlist,
  }) async {
    final results = <Map<String, String>?>[];
    await tester.pumpWidget(
      localizedApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(
                await SetlistEditorDialog.show(context, setlist: setlist),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('a new setlist shows "New Setlist" and a Create button', (
    tester,
  ) async {
    await openDialog(tester);

    expect(find.text('New Setlist'), findsOne);
    expect(find.text('Setlist Name'), findsOne);
    expect(find.text('Details (optional)'), findsOne);
    expect(find.text('Create'), findsOne);
    expect(find.text('Cancel'), findsOne);
  });

  testWidgets('an existing setlist shows "Edit Setlist" and a Save button', (
    tester,
  ) async {
    await openDialog(
      tester,
      setlist: const Setlist(
        id: 1,
        name: 'Sunday Gig',
        description: 'Church hall',
        createdAt: 0,
        updatedAt: 0,
      ),
    );

    expect(find.text('Edit Setlist'), findsOne);
    expect(find.text('Save'), findsOne);
    expect(find.text('Sunday Gig'), findsOne);
  });

  testWidgets('an empty name is refused with a message', (tester) async {
    final results = await openDialog(tester);

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a setlist name'), findsOne);
    expect(results, isEmpty);
  });

  testWidgets('a name and description are returned trimmed', (tester) async {
    final results = await openDialog(tester);

    await tester.enterText(find.byType(TextFormField).first, '  Practice ');
    await tester.enterText(find.byType(TextFormField).last, ' Notes ');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(results.single, {'name': 'Practice', 'description': 'Notes'});
  });
}
