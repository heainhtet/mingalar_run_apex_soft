# Mingalar Run Technical Guide

Mingalar Run is an offline-first Flutter running app. A user starts a session,
sees live activity data, and keeps completed runs on the device for history,
calendar, and profile views.

## What the app includes

- Onboarding and a fixed dashboard header
- Personal, fun, and challenge run tabs
- Live run controls: start, pause, resume, and end
- Calendar, recent history, run detail, and native sharing
- Profile editing, avatar storage, QR sharing and scanning
- Events, featured challenges, notifications, dark mode, and English/Burmese
  localization
- Local account deletion

There is no backend or registration service in this version. Profile, settings,
and run data remain on the device.

## Run data flow

```text
phone motion and location
          |
          v
GeolocatorRunSensorService
          |
          v
RunSensorFrame
          |
          v
RunSessionNotifier
          |
          +--> live UI
          +--> Hive recovery and completed-run history
```

### iOS

`cm_pedometer` uses Core Motion for the active session. It provides steps,
pedestrian status, distance, pace, and cadence when the device supports those
measurements. iOS distance and pace are kept as native values.

### Android

`pedometer` provides the hardware step counter and pedestrian status.
`geolocator` provides outdoor positions for distance and pace. GPS points are
accepted only when accuracy, movement status, distance, and speed checks pass.
This avoids adding distance while the phone is still or receiving GPS drift.

### Metrics

The current stage is derived from pedestrian status and cadence: walking,
jogging, running, or stopped. Moving time and calorie estimates progress only
while the stage is moving. Android pace is calculated from accepted GPS distance
and moving time; iOS uses the native pedometer pace when available.

## Session and storage behavior

- Starting a run checks the required platform permissions.
- Pausing stops sensor streams; resuming creates a fresh step baseline.
- Very short, empty sessions are not added to history.
- An active-session snapshot is saved to Hive regularly and at pause/failure
  boundaries. After an interruption, the session is restored as paused.
- Completed runs update calendar, history, profile summary, and rank data.

Android configures an ongoing foreground notification during active GPS
tracking. Physical-device testing is required for background behavior because
manufacturer battery settings can differ.

## Main technology choices

| Technology | Use in Mingalar Run |
| --- | --- |
| Flutter and Dart | Cross-platform UI and application logic |
| Riverpod | Reactive state and dependency injection |
| Hive CE | Offline settings, profile, completed runs, and recovery state |
| `cm_pedometer` | iOS Core Motion run measurements |
| `pedometer` | Android native steps and pedestrian status |
| `geolocator` | Android GPS distance, location permissions, foreground tracking |
| AutoRoute | Typed navigation |
| Easy Localization | English and Burmese UI strings |
| QR Flutter and Mobile Scanner | Profile QR creation and scanning |
| Share Plus | Native run-summary sharing |

Supporting packages provide SVG rendering, image selection, launch assets,
spacing, themed messages, and app logging.

## Key files

| Area | File |
| --- | --- |
| Platform sensor integration | `lib/features/run/data/services/geolocator_run_sensor_service.dart` |
| Live session state | `lib/features/run/presentation/providers/run_session_provider.dart` |
| GPS validation | `lib/features/run/domain/services/gps_distance_accumulator.dart` |
| Metric calculations | `lib/features/run/domain/services/run_metrics.dart` |
| Local database setup | `lib/core/database/hive_database.dart` |
| Theme and language settings | `lib/core/settings/app_settings.dart` |

## Verification

```bash
flutter pub get
flutter analyze
flutter test
```

Use physical devices to verify motion and GPS:

- Leave the phone still: steps, distance, moving time, and calories should not
  increase.
- Walk naturally: steps and status should update.
- Stop: status should return to stopped and moving metrics should stop.
- Run outdoors: confirm GPS distance and pace.
- Pause, lock the device, switch apps, and verify recovery after interruption.

Sensor values are fitness estimates. Accuracy depends on device hardware,
carrying position, GPS conditions, and operating-system behavior.
