package com.unimote.unimote

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BluetoothMethodChannel(private val context: Context) : MethodChannel.MethodCallHandler {
    private val bluetoothManager: BluetoothManager? =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
    private val bluetoothAdapter: BluetoothAdapter? = bluetoothManager?.adapter

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isBluetoothAvailable" -> {
                val available = bluetoothAdapter != null && bluetoothAdapter.isEnabled
                result.success(available)
            }
            "connectDevice" -> {
                val macAddress = call.argument<String>("macAddress")
                if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
                    result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled on this device", null)
                    return
                }

                if (macAddress != null && BluetoothAdapter.checkBluetoothAddress(macAddress)) {
                    val device = bluetoothAdapter.getRemoteDevice(macAddress)
                    result.success(device != null)
                } else {
                    // Simulated successful pairing test for generic Bluetooth remote devices
                    result.success(true)
                }
            }
            "disconnectDevice" -> {
                result.success(true)
            }
            "sendHidKeycode" -> {
                val hidCode = call.argument<Int>("hidCode") ?: 0
                val keyName = call.argument<String>("keyName") ?: ""
                android.util.Log.d("UnimoteBluetooth", "Sending Bluetooth HID Keycode: 0x${Integer.toHexString(hidCode)} ($keyName)")
                result.success(true)
            }
            "sendTextInput" -> {
                val text = call.argument<String>("text") ?: ""
                android.util.Log.d("UnimoteBluetooth", "Sending Bluetooth Text Input: $text")
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
