package com.box.project.polio;

import android.Manifest;
import android.content.pm.PackageManager;
import android.telephony.SmsManager;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.example.sms_sender/sms";
  private static final int MY_PERMISSIONS_REQUEST_SEND_SMS = 0;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
            (call, result) -> {
              if (call.method.equals("sendSms")) {
                String phoneNumber = call.argument("phoneNumber");
                String message = call.argument("message");

                if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                    != PackageManager.PERMISSION_GRANTED) {
                  ActivityCompat.requestPermissions(this,
                      new String[]{Manifest.permission.SEND_SMS},
                      MY_PERMISSIONS_REQUEST_SEND_SMS);
                } else {
                  sendSms(phoneNumber, message, result);
                }
              } else {
                result.notImplemented();
              }
            }
        );
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (requestCode == MY_PERMISSIONS_REQUEST_SEND_SMS) {
      if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        // Permission granted
      } else {
        // Permission denied
      }
    }
  }

  private void sendSms(String phoneNumber, String message, MethodChannel.Result result) {
    try {
      SmsManager smsManager = SmsManager.getDefault();
      smsManager.sendTextMessage(phoneNumber, null, message, null, null);
      result.success("SMS Sent");
    } catch (Exception e) {
      result.error("UNAVAILABLE", "SMS sending failed", null);
    }
  }
}
