import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:convert';

void main() => runApp(Imagemodel());

class Imagemodel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageUploadPage(),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  String? _filePath;
  String? _fileName;
  bool _isLoading = false;
  String? _errorMessage;
  String? _apiResponse;

  Future<void> uploadImage(String imagePath) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _apiResponse = null;
    });

    final String url =
        'https://polio-image-classification-api.vercel.app/polio_classification';

    File imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: The file '$imagePath' does not exist.";
      });
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['accept'] = 'application/json';
      request.files.add(
        await http.MultipartFile.fromPath(
          'input_image',
          "https://testgithub.polioantenna.org/uploads/1725526668101-555261940.png",
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response =
          await request.send().timeout(Duration(seconds: 60)); // Added timeout

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var decodedResponse = json.decode(responseData.body);

        setState(() {
          _isLoading = false;
          _apiResponse = decodedResponse
              .toString(); // Store the string representation of the response
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Error: ${response.statusCode} ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred: $e";
      });
    }
  }

  Future<void> selectImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) {
      return;
    }

    setState(() {
      _filePath = result.files.single.path;
      _fileName = result.files.single.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          // Added stack to overlay progress indicator
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Select an image to upload',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : selectImage, // Disable button while loading
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                if (_filePath != null) ...[
                  Text(
                    'Selected File: $_fileName',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Disable button while loading
                            if (_filePath != null) {
                              uploadImage(_filePath!);
                            }
                          },
                    child: Text('Submit'),
                  ),
                ],
                if (_errorMessage != null) ...[
                  SizedBox(height: 20),
                  Text(
                    'Error: $_errorMessage',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
                if (_apiResponse != null) ...[
                  SizedBox(height: 20),
                  Text(
                    'API Response: $_apiResponse',
                    style: TextStyle(color: Colors.green),
                  )
                ]
              ],
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
