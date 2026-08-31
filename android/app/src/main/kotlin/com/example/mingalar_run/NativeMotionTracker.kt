package com.example.mingalar_run

import android.Manifest
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.google.android.gms.location.ActivityRecognition
import com.google.android.gms.location.ActivityRecognitionResult
import com.google.android.gms.location.DetectedActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import java.lang.ref.WeakReference

/**
 * Streams the platform's purpose-built motion signals to Flutter.
 *
 * Step totals and step timing are separate Android sensors. The optional
 * Activity Recognition result is only a confidence hint; it never creates a
 * step or a distance measurement.
 */
class NativeMotionTracker(
    private val applicationContext: Context,
) : EventChannel.StreamHandler, SensorEventListener {
    companion object {
        private const val channelName = "mingalar_run/native_motion"
        private const val activityAction = "com.example.mingalar_run.NATIVE_MOTION_ACTIVITY"
        private const val activityRequestCode = 401

        @Volatile
        private var activeTracker: WeakReference<NativeMotionTracker>? = null

        internal fun publishActivity(label: String, confidence: Int) {
            activeTracker?.get()?.dispatch(
                mapOf(
                    "type" to "activity",
                    "activity" to label,
                    "confidence" to confidence,
                    "timestampMs" to System.currentTimeMillis(),
                ),
            )
        }
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val sensorManager =
        applicationContext.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val stepCounter = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    private val stepDetector = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
    private val activityClient = ActivityRecognition.getClient(applicationContext)
    private val activityPendingIntent by lazy {
        val intent = Intent(applicationContext, NativeMotionActivityReceiver::class.java)
            .setAction(activityAction)
        PendingIntent.getBroadcast(
            applicationContext,
            activityRequestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private var eventSink: EventChannel.EventSink? = null
    private var activityUpdatesStarted = false

    fun register(messenger: BinaryMessenger) {
        EventChannel(messenger, channelName).setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        activeTracker = WeakReference(this)
        startSensors()
        startActivityRecognition()
    }

    override fun onCancel(arguments: Any?) {
        stopSensors()
        stopActivityRecognition()
        eventSink = null
        if (activeTracker?.get() === this) {
            activeTracker = null
        }
    }

    override fun onSensorChanged(event: SensorEvent) {
        when (event.sensor.type) {
            Sensor.TYPE_STEP_COUNTER -> dispatch(
                mapOf(
                    "type" to "step_counter",
                    "steps" to event.values.firstOrNull()?.toInt().orZero(),
                    "isSessionTotal" to false,
                    "timestampMs" to System.currentTimeMillis(),
                ),
            )

            Sensor.TYPE_STEP_DETECTOR -> dispatch(
                mapOf(
                    "type" to "step_detector",
                    "timestampMs" to System.currentTimeMillis(),
                ),
            )
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun startSensors() {
        val hasCounter = stepCounter != null
        val hasDetector = stepDetector != null
        dispatch(
            mapOf(
                "type" to "availability",
                "isAvailable" to (hasCounter || hasDetector),
                "timestampMs" to System.currentTimeMillis(),
            ),
        )
        stepCounter?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
        stepDetector?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    private fun stopSensors() {
        sensorManager.unregisterListener(this)
    }

    private fun startActivityRecognition() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            applicationContext.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) !=
                PackageManager.PERMISSION_GRANTED
        ) {
            dispatch(
                mapOf(
                    "type" to "availability",
                    "isAvailable" to false,
                    "timestampMs" to System.currentTimeMillis(),
                ),
            )
            return
        }
        activityClient.requestActivityUpdates(2_000, activityPendingIntent)
            .addOnSuccessListener { activityUpdatesStarted = true }
            .addOnFailureListener {
                // Step hardware remains usable without Google Play activity
                // recognition, so this is deliberately non-fatal.
                dispatch(
                    mapOf(
                        "type" to "activity",
                        "activity" to "unknown",
                        "confidence" to 0,
                        "timestampMs" to System.currentTimeMillis(),
                    ),
                )
            }
    }

    private fun stopActivityRecognition() {
        if (!activityUpdatesStarted) return
        activityClient.removeActivityUpdates(activityPendingIntent)
        activityUpdatesStarted = false
    }

    private fun dispatch(event: Map<String, Any>) {
        mainHandler.post { eventSink?.success(event) }
    }
}

class NativeMotionActivityReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!ActivityRecognitionResult.hasResult(intent)) return
        val result = ActivityRecognitionResult.extractResult(intent) ?: return
        val candidate = result.probableActivities
            .mapNotNull { activity -> activity.toMotionActivity() }
            .maxByOrNull { (_, confidence) -> confidence }
            ?: return
        NativeMotionTracker.publishActivity(candidate.first, candidate.second)
    }
}

private fun DetectedActivity.toMotionActivity(): Pair<String, Int>? = when (type) {
    DetectedActivity.STILL -> "still" to confidence
    DetectedActivity.WALKING, DetectedActivity.ON_FOOT -> "walking" to confidence
    DetectedActivity.RUNNING -> "running" to confidence
    else -> null
}

private fun Int?.orZero(): Int = this ?: 0
