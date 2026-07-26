import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricchord/models/setlist.dart';
import 'package:lyricchord/providers/database_provider.dart';

/// Stream of all setlists.
final setlistsStreamProvider = StreamProvider<List<Setlist>>((ref) {
  return ref.watch(setlistRepositoryProvider).watchAllSetlists();
});

/// Stream of a single setlist by id.
final setlistByIdProvider = StreamProvider.family<Setlist?, int>((ref, id) {
  return ref.watch(setlistRepositoryProvider).watchSetlistById(id);
});

/// Holds the active setlist ID when performing a setlist in performance mode.
class ActiveSetlistIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setActiveSetlist(int? id) => state = id;
}

final activeSetlistIdProvider = NotifierProvider<ActiveSetlistIdNotifier, int?>(
  ActiveSetlistIdNotifier.new,
);
