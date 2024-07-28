import 'dart:async';
import 'dart:io';
import 'package:camera_app/sqflite/connectivity_check.dart';
import 'package:camera_app/sqflite/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class UpdateFile extends StatefulWidget {
  final File file;

  const UpdateFile({Key? key, required this.file}) : super(key: key);

  @override
  _UpdateFileState createState() => _UpdateFileState();
}

class _UpdateFileState extends State<UpdateFile> {
  final TextEditingController _urlController = TextEditingController();
  String _url = "http://beta-plc.com:8005/api/request";
  final TextEditingController oname = TextEditingController();
  late String error;

  Future<bool> uploadFile(BuildContext context, File file, String title) async {
    // if (await hasInternetConnection()) {
    //   // Online: Try to upload
    //   return await _uploadFileToServer(context, file, title);
    // } else {
    // Offline: Save to SQLite
    await DatabaseHelper().insertMedia(title, file.path);
    Fluttertoast.showToast(
      msg: "No internet connection. File saved locally.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return false;
    // }
  }

  Future<bool> _uploadFileToServer(
      BuildContext context, File file, String title) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return const Dialog(
          backgroundColor: Colors.black,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15),
                Text(
                  'Uploading...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['title'] = title;
      var response = await request.send();

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Upload success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return true;
      } else {
        Fluttertoast.showToast(
          msg: "Upload failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    } catch (e) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: "Upload failed: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }

  Future<void> retryPendingUploads(BuildContext context) async {
    List<Map<String, dynamic>> pendingMedia =
        await DatabaseHelper().getPendingMedia();
    for (var media in pendingMedia) {
      File file = File(media['filePath']);
      bool success = await _uploadFileToServer(context, file, media['title']);
      if (success) {
        await DatabaseHelper().updateMediaStatus(media['id']);
      }
    }
  }

  Future<bool> _showDialog() async {
    bool click = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Url Upload',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            cursorColor: Colors.white,
            controller: oname,
            decoration: InputDecoration(
              hintText: "please enter description",
              hintStyle: const TextStyle(color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.focused)) {
                    return Colors.green;
                  }
                  return Colors.white;
                }),
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                if (_urlController.text.trim() != '') {
                  setState(() {
                    _url = _urlController.text.trim();
                  });
                }
                click = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return click;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      focusColor: Colors.grey,
      icon: const Icon(
        Icons.cloud_upload,
        color: Colors.white,
        size: 35,
      ),
      onPressed: () {
        _showDialog().then((done) {
          if (done) {
            uploadFile(context, widget.file, oname.text).then((success) {
              Navigator.of(context).pop();
              if (success) {
                Fluttertoast.showToast(
                  msg: "Upload success",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Upload failed",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            });
          }
        });
      },
    );
  }
}
