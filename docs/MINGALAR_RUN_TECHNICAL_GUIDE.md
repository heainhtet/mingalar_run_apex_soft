# Mingalar Run

Mingalar Run is an offline-first Flutter running app. The main feature is a
user-started run session that reports elapsed time, steps, distance, pace,
calories and the current activity stage. A run can be paused, resumed and
ended. Completed runs feed the calendar, history and profile summary.

The app also includes one-time onboarding, local profile editing, profile QR
sharing and scanning, challenges, events and local account deletion. There is
no registration flow or backend in this version.

## How run tracking works

Three phone data sources are combined:

```text
pedometer ─────────────── steps and pedestrian status ─┐
geolocator ────────────── GPS position and speed ──────┼─> RunSensorFrame
                                                                |
                                                                 v
                                                        RunSessionNotifier
                                                        UI + Hive storage
```

`RunSensorFrame` is the boundary between plugins and the rest of the feature.
The session provider only receives normalized Dart values, so it does not need
to know which plugin produced them.

### Steps

`pedometer` is the primary source because it uses the phone's native step
counter. The first value received is used as a baseline—the native count is
usually a total since boot, not since the user pressed Start. Only positive,
reasonable changes after that baseline are added to the run.

Some phones send several steps in one update. The stored count still comes
from the native sensor, while the UI animates to the new value. The app cannot
force the operating system to emit one event for every individual step.

Step count and pedestrian status remain separate signals. A step delta cannot
change `stopped` to `walking`; explicit stopped status rejects that delta. This
prevents phone shaking from becoming a run. If the native motion sensor is not
available, the app reports motion data as unavailable instead of estimating
steps from raw acceleration.

### Distance and pace

`geolocator` supplies outdoor position and speed. A GPS point is accepted only
when its values are valid and horizontal accuracy is 30 m or better.
`GpsDistanceAccumulator` rejects stationary drift, tiny changes inside the GPS
noise floor, impossible jumps and stopped motion. Accepted coordinates are
measured with the Haversine formula.

Indoor movement still needs useful distance, so step distance is estimated as:

```text
steps × 0.75 m
```

The session uses the larger of filtered GPS distance and step distance. The
two values are not added because they describe the same movement. Pace is
moving time divided by distance.

### Activity stage

The stage classifier uses only native pedestrian evidence and cadence:

1. native status must be `walking` and the active segment must contain an
   accepted native step;
2. cadence from 160 steps/min is running;
3. cadence from 130 steps/min is jogging;
4. lower cadence with walking status is walking;
5. stopped or unknown status is stopped.

After three seconds without native walking evidence or an accepted step, the
stage becomes stopped. Elapsed session time continues, but moving time,
calories and pace progression stop.

## Metric definitions

| Metric | Source or calculation |
|---|---|
| Elapsed time | Active time between start/resume and pause/end |
| Moving time | Time classified as walking, jogging or running |
| Steps | Native pedometer, or accelerometer fallback |
| Distance | Larger of filtered GPS distance and estimated step distance |
| Pace | Moving time ÷ distance |
| Calories | MET × 3.5 × weight / 200 × moving minutes |

The current calorie estimate uses a 70 kg default. MET values are 3.5 for
walking, 7 for jogging and 9.8 for running. Weight and stride length should
become profile settings before treating calories or indoor distance as
personalized measurements.

## Session lifecycle

Starting a run checks location services, requests location and motion access,
then starts GPS and the native pedometer. A one-second timer updates elapsed
values.

Pause stops the sensor subscriptions and saves the current state. Resume starts
new subscriptions and a new native-step baseline without losing earlier data.
Ending saves a run only when it lasts at least ten seconds and contains either
ten steps or 0.01 km. This keeps accidental taps out of history.

Hive stores a recovery snapshot at start, pause and failure boundaries, and at
most once every five seconds while running. An interrupted session is restored
as paused on the next launch.

## Background behavior

On Android, Geolocator owns a foreground location service with an ongoing
notification and wake lock. On iOS, location background mode is enabled for an
explicitly started run. Tracking may continue while the phone is locked or
another app is open.

Force-stop, process termination, reboot and aggressive vendor battery rules can
still stop Dart execution. The last Hive recovery snapshot remains, but sensor
events after process termination cannot be reconstructed. This app tracks an
active run; it is not a 24-hour passive health service.

## Architecture and storage

The run feature uses a small layered structure:

```text
presentation  pages, widgets, Riverpod state
domain        entities, calculations, service/repository contracts
data          plugin services, Hive models and repositories
```

Riverpod owns feature state and dependency injection. Widgets render state and
send actions to notifiers; the feature does not use `setState`. Hive CE stores
onboarding state, one local profile, run history and one recoverable session.
Coordinates are used to calculate distance but are not stored or logged.

## Main packages

| Package | Why it is used |
|---|---|
| flutter_riverpod | Reactive state and dependency injection |
| geolocator | GPS, location permission and Android foreground tracking |
| pedometer | Native steps and pedestrian status |
| hive_ce | Offline profile, history and session recovery |
| auto_route | Typed navigation |
| easy_localization / intl | Strings and date formatting |
| qr_flutter / mobile_scanner | Profile QR creation and scanning |
| share_plus | Native run-summary sharing |
| logger | Lifecycle, sensor-data and error logs |

The remaining UI packages support SVG assets, spacing, navigation styling,
flushbars, launcher icons and the native splash screen.

## Files to read for the tracking feature

Start with these files:

1. `domain/entities/run_sensor_frame.dart` — normalized sensor data.
2. `data/services/geolocator_run_sensor_service.dart` — plugin streams,
   permissions, cadence and inactivity.
3. `presentation/providers/run_session_provider.dart` — session lifecycle and
   reactive metrics.
4. `domain/services/gps_distance_accumulator.dart` — GPS filtering.
5. `domain/services/run_metrics.dart` — distance, pace and calories.
6. `data/repositories/hive_run_session_repository.dart` — recovery storage.

## Verification

The automated tests cover stationary behavior, GPS drift and jumps, native
step/status separation, pause/resume, calories, pace, recovery, Hive
persistence and history aggregation.

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --no-codesign
```

Sensor accuracy still needs physical-device testing. The practical test set is:

- leave the phone on a desk and confirm every movement metric stays at zero;
- walk a known number of steps indoors, including back-and-forth movement;
- run a measured outdoor route and compare distance and pace;
- pause and move, then confirm paused movement is excluded;
- lock the phone and switch apps during a run;
- test denied permissions, disabled location and session recovery;
- repeat on several Android vendors and at least one physical iPhone.

Mingalar Run provides fitness estimates, not medical or race-certified
measurements. Device sensors, carrying position, GPS conditions and operating
system batching all affect the result.
