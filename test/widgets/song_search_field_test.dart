import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/providers/song_list_provider.dart';
import 'package:lyricchord/widgets/song_search_field.dart';

import '../helpers/localized_app.dart';
import '../helpers/tooltip_expectations.dart';

void main() {
  Future<ProviderContainer> pump(WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const Scaffold(body: SongSearchField())),
      ),
    );
    return container;
  }

  testWidgets('shows the hint and no clear button while empty', (tester) async {
    await pump(tester);

    expect(find.text('Search songs, artists, lyrics'), findsOneWidget);
    expect(find.byTooltip('Clear search'), findsNothing);
  });

  testWidgets('typing updates the search query', (tester) async {
    final container = await pump(tester);

    await tester.enterText(find.byType(TextField), 'grace');
    await tester.pump();

    expect(container.read(searchQueryProvider), 'grace');
    expect(find.byTooltip('Clear search'), findsOneWidget);
    expectAllIconButtonsHaveTooltips(tester);
  });

  testWidgets('the clear button empties the box and the query', (tester) async {
    final container = await pump(tester);

    await tester.enterText(find.byType(TextField), 'bells');
    await tester.pump();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(container.read(searchQueryProvider), '');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(find.byTooltip('Clear search'), findsNothing);
  });
}
