/// How a pitch should be named for the musician reading it.
///
/// The same sound has three names. A Western player calls it `G`. A Carnatic
/// singer calls it `5 kattai`. A Hindustani singer calls it `safed 5`. None is
/// more correct than another — each belongs to a different tradition, and
/// showing the wrong one makes the app feel foreign to the person holding it.
///
/// Lives in `models/` because both the settings model and the naming service
/// need it, and a model must never depend upward on a service.
enum PitchTradition {
  western,
  carnatic,
  hindustani;

  /// The name shown in Settings.
  String get displayName => switch (this) {
    PitchTradition.western => 'Western',
    PitchTradition.carnatic => 'Carnatic',
    PitchTradition.hindustani => 'Hindustani',
  };

  /// Stored in `shared_preferences`. Kept separate from [name] so renaming an
  /// enum value can never silently change what a saved setting means.
  String get storageKey => switch (this) {
    PitchTradition.western => 'western',
    PitchTradition.carnatic => 'carnatic',
    PitchTradition.hindustani => 'hindustani',
  };

  /// Reads a saved [storageKey] back, falling back to [fallback] for anything
  /// unrecognised — a hand-edited or older preference must never crash startup.
  static PitchTradition fromStorage(
    String? value, {
    PitchTradition fallback = PitchTradition.carnatic,
  }) {
    for (final tradition in PitchTradition.values) {
      if (tradition.storageKey == value) return tradition;
    }
    return fallback;
  }
}
