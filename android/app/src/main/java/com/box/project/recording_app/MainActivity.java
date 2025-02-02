package com.box.project.polio;

import android.Manifest;
import android.content.ContentValues;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.provider.MediaStore;
import android.telephony.SmsManager;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import android.net.Uri;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

public class MainActivity extends FlutterActivity {
  private static final String SMS_CHANNEL = "com.example.sms_sender/sms";
  private static final String GALLERY_CHANNEL = "gallery_saver";
  private static final int MY_PERMISSIONS_REQUEST_SEND_SMS = 0;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), SMS_CHANNEL)
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

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), GALLERY_CHANNEL)
        .setMethodCallHandler(
            (call, result) -> {
              if (call.method.equals("saveImage")) {
                String filePath = call.argument("filePath");
                saveImageToGallery(filePath, result);
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
private void saveImageToGallery(String filePath, MethodChannel.Result result) {
    try {
        Bitmap bitmap = BitmapFactory.decodeFile(filePath);
        if (bitmap == null) {
            result.error("UNAVAILABLE", "Failed to decode image", null);
            return;
        }

        ContentValues values = new ContentValues();
        values.put(MediaStore.Images.Media.DISPLAY_NAME, "qr_code_" + System.currentTimeMillis() + ".png");
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/png");
        values.put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/QR_Codes/");
        values.put(MediaStore.Images.Media.IS_PENDING, 1);

        Uri uri = getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
        if (uri == null) {
            result.error("UNAVAILABLE", "Failed to insert image into MediaStore", null);
            return;
        }

        try (OutputStream out = getContentResolver().openOutputStream(uri)) {
            if (out != null) {
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
                out.flush();
            } else {
                result.error("UNAVAILABLE", "Failed to open output stream", null);
                return;
            }
        }

        // Mark file as finished
        values.clear();
        values.put(MediaStore.Images.Media.IS_PENDING, 0);
        getContentResolver().update(uri, values, null, null);

        result.success("Image saved successfully at: " + uri.toString());
    } catch (Exception e) {
        result.error("UNAVAILABLE", "Failed to save image: " + e.getMessage(), null);
    }
}

}
