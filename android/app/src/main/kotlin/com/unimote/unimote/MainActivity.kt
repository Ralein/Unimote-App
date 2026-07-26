package com.unimote.unimote

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "unimote/ir")
            .setMethodCallHandler(IrMethodChannel(applicationContext))

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "unimote/bluetooth")
            .setMethodCallHandler(BluetoothMethodChannel(applicationContext))
    }
}
