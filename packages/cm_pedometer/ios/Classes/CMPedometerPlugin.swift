import CoreMotion
import Flutter

public final class CMPedometerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    FlutterEventChannel(name: "step_detection", binaryMessenger: messenger)
      .setStreamHandler(PedestrianStatusHandler())
    FlutterEventChannel(name: "step_counter_first", binaryMessenger: messenger)
      .setStreamHandler(PedometerDataHandler())
  }
}

private final class PedestrianStatusHandler: NSObject, FlutterStreamHandler {
  private let pedometer = CMPedometer()
  private var active = false

  func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
    guard CMPedometer.isPedometerEventTrackingAvailable() else {
      eventSink(FlutterError(code: "unavailable", message: "Pedometer event tracking is unavailable.", details: nil))
      return nil
    }
    active = true
    pedometer.startEventUpdates { event, error in
      guard self.active, error == nil, let event else { return }
      DispatchQueue.main.async { eventSink(event.type.rawValue) }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    active = false
    pedometer.stopEventUpdates()
    return nil
  }
}

private final class PedometerDataHandler: NSObject, FlutterStreamHandler {
  private let pedometer = CMPedometer()
  private var active = false

  func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
    guard CMPedometer.isStepCountingAvailable() else {
      eventSink(FlutterError(code: "unavailable", message: "Step counting is unavailable.", details: nil))
      return nil
    }
    let values = arguments as? [String: Any]
    let milliseconds = values?["startDate"] as? NSNumber
    let start = milliseconds.map { Date(timeIntervalSince1970: $0.doubleValue / 1000) } ?? Date()
    active = true
    pedometer.startUpdates(from: start) { data, error in
      guard self.active, error == nil, let data else { return }
      var result: [String: Any] = [
        "numberOfSteps": data.numberOfSteps.intValue,
      ]
      if let distance = data.distance { result["distance"] = distance.doubleValue }
      if let pace = data.averageActivePace { result["averageActivePace"] = pace.doubleValue }
      if let pace = data.currentPace { result["currentPace"] = pace.doubleValue }
      if let cadence = data.currentCadence { result["currentCadence"] = cadence.doubleValue }
      DispatchQueue.main.async { eventSink(result) }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    active = false
    pedometer.stopUpdates()
    return nil
  }
}
