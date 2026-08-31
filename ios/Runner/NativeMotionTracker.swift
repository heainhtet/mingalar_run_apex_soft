import CoreMotion
import Flutter
import Foundation

/// Bridges Core Motion's pedometer and activity APIs into the same event
/// contract used by Android. Core Motion owns the hardware filtering; Flutter
/// only receives normalized step totals, cadence, and confidence hints.
final class NativeMotionTracker: NSObject, FlutterStreamHandler {
  private static let channelName = "mingalar_run/native_motion"

  private let pedometer = CMPedometer()
  private let activityManager = CMMotionActivityManager()
  private var eventSink: FlutterEventSink?
  private var isTracking = false

  func register(with messenger: FlutterBinaryMessenger) {
    FlutterEventChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    ).setStreamHandler(self)
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    startTracking()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopTracking()
    eventSink = nil
    return nil
  }

  private func startTracking() {
    guard !isTracking else { return }
    isTracking = true

    guard CMPedometer.isStepCountingAvailable() else {
      emit([
        "type": "availability",
        "isAvailable": false,
        "timestampMs": timestampMilliseconds,
      ])
      return
    }

    emit([
      "type": "availability",
      "isAvailable": true,
      "timestampMs": timestampMilliseconds,
    ])
    pedometer.startUpdates(from: Date()) { [weak self] data, error in
      guard let self, let data, error == nil else { return }
      DispatchQueue.main.async {
        self.emit([
          "type": "step_counter",
          "steps": data.numberOfSteps.intValue,
          "isSessionTotal": true,
          "timestampMs": self.timestampMilliseconds,
        ])
        if let cadence = data.currentCadence?.doubleValue, cadence.isFinite {
          self.emit([
            "type": "cadence",
            "cadenceStepsPerMinute": cadence * 60,
            "timestampMs": self.timestampMilliseconds,
          ])
        }
      }
    }

    guard CMMotionActivityManager.isActivityAvailable() else { return }
    activityManager.startActivityUpdates(to: .main) { [weak self] activity in
      guard let self, let activity else { return }
      self.emit([
        "type": "activity",
        "activity": activity.motionLabel,
        "confidence": activity.confidencePercent,
        "timestampMs": self.timestampMilliseconds,
      ])
    }
  }

  private func stopTracking() {
    guard isTracking else { return }
    pedometer.stopUpdates()
    activityManager.stopActivityUpdates()
    isTracking = false
  }

  private func emit(_ event: [String: Any]) {
    eventSink?(event)
  }

  private var timestampMilliseconds: Int64 {
    Int64(Date().timeIntervalSince1970 * 1_000)
  }
}

private extension CMMotionActivity {
  var motionLabel: String {
    if running { return "running" }
    if walking { return "walking" }
    if stationary { return "still" }
    return "unknown"
  }

  var confidencePercent: Int {
    switch confidence {
    case .high:
      return 100
    case .medium:
      return 70
    case .low:
      return 40
    @unknown default:
      return 0
    }
  }
}
