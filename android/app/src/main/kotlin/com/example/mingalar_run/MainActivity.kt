package com.example.mingalar_run

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var nativeMotionTracker: NativeMotionTracker? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        nativeMotionTracker = NativeMotionTracker(applicationContext).also {
            it.register(flutterEngine.dartExecutor.binaryMessenger)
        }
    }
}
