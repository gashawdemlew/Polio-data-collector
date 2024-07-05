import 'package:camera_app/controler/video_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';

void main() {
  runApp(JHJ());
}

class DataEntry {
  final String id;
  final String eid;
  final String rid;
  final String oid;
  final String oname;
  final String tenderno;
  final String tendername;
  final String priority;
  final String link;
  final String file;
  final String status;
  final int v;

  DataEntry({
    required this.id,
    required this.eid,
    required this.rid,
    required this.oid,
    required this.oname,
    required this.tenderno,
    required this.tendername,
    required this.priority,
    required this.link,
    required this.file,
    required this.status,
    required this.v,
  });

  factory DataEntry.fromJson(Map<String, dynamic> json) {
    return DataEntry(
      id: json['_id'],
      eid: json['eid'],
      rid: json['rid'],
      oid: json['oid'],
      oname: json['oname'],
      tenderno: json['tenderno'],
      tendername: json['tendername'],
      priority: json['priority'],
      link: json['link'],
      file: json['file'],
      status: json['status'],
      v: json['__v'],
    );
  }
}

class JHJ extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<JHJ> {
  List<DataEntry> _dataEntries = [];
  bool _isLoading = true;

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('http://beta-plc.com:8005/findrequest/O-0002'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        _dataEntries =
            responseData.map((data) => DataEntry.fromJson(data)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('API Data'),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _dataEntries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_dataEntries[index].oname),
                    subtitle: _dataEntries[index]
                            .file
                            .toLowerCase()
                            .endsWith('.mp4')
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    // builder: (context) =>

                                    // VideoPlayerWidget(
                                    //   videoUrl:
                                    //       "http://beta-plc.com:8005/findoid/${_dataEntries[index].id}",
                                    // ),

                                    builder: (context) => VideoPlayerScreen(
                                          videoUrl:
                                              "http://beta-plc.com:8005/findoid/${_dataEntries[index].id}",
                                        )),
                              );
                            },
                            child: Icon(Icons.play_arrow),
                          )
                        : Image.network(
                            "http://beta-plc.com:8005/findoid/${_dataEntries[index].id}"),
                  );
                },
              ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
