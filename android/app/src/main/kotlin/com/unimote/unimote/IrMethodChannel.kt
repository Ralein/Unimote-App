package com.unimote.unimote

import android.content.Context
import android.hardware.ConsumerIrManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class IrMethodChannel(private val context: Context) : MethodChannel.MethodCallHandler {
    private val irManager: ConsumerIrManager? =
        context.getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

    override onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasIrEmitter" -> {
                val hasEmitter = irManager?.hasIrEmitter() ?: false
                result.success(hasEmitter)
            }
            "transmit" -> {
                val frequency = call.argument<Int>("frequency") ?: 38000
                val patternList = call.argument<List<Int>>("pattern")
                if (irManager != null && irManager.hasIrEmitter() && patternList != null) {
                    val pattern = patternList.toIntArray()
                    irManager.transmit(frequency, pattern)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            else -> result.notImplemented()
        }
    }
}
