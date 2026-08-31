# Mingalar Run

Mingalar Run is an offline-first Flutter running tracker. It records an
explicitly started session using device motion and location signals, then
stores the result locally for calendar, history, profile, and summary views.

## Development

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Run on physical Android and iOS devices when validating sensors. Simulators
cannot establish step-count or background-location accuracy.

See [Mingalar Run technical guide](docs/MINGALAR_RUN_TECHNICAL_GUIDE.md) for
the product scope, architecture, data sources, calculations, packages,
permissions, background behavior, testing strategy, and maintenance guide.
