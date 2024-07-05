import 'dart:async';
import 'dart:io';

import 'package:camera_app/controler/upload_file_server.dart';
import 'package:camera_app/main.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final String filePath;
  final File file;

  const VideoPage({
    Key? key,
    required this.filePath,
    required this.file,
  }) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initVideoPlayer;

  //rotate BuilderFuture
  int quarterTurns = 0;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    _initVideoPlayer = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      quarterTurns = 1;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        key: const ValueKey(3),
        children: [
          ///video view
          Positioned(
            top: 90,
            bottom: 90,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: RotatedBox(
                quarterTurns: quarterTurns,
                child: FutureBuilder(
                  future: _initVideoPlayer,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the VideoPlayerController has finished initialization, use
                      // the data it provides to limit the aspect ratio of the video.
                      return AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        // Use the VideoPlayer widget to display the video.
                        child: VideoPlayer(_videoPlayerController),
                      );
                    } else {
                      // If the VideoPlayerController is still initializing, show a
                      // loading spinner.
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ),

          ///top controlls
          Positioned(
              top: 0,
              height: 90,
              child: Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ///Front Camera toggle
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: IconButton(
                        focusColor: Colors.grey,
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SplashScreen()));
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 15,
                            ),
                            ValueListenableBuilder(
                              valueListenable: _videoPlayerController,
                              builder:
                                  (context, VideoPlayerValue value, child) {
                                //Do Something with the value.
                                return Text(
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    "${value.position.inMinutes.toString().padLeft(2, "0")}:${value.position.inSeconds.toString().padLeft(2, "0")} / ${_videoPlayerController.value.duration.inMinutes.toString().padLeft(2, "0")}:${_videoPlayerController.value.duration.inSeconds.toString().padLeft(2, "0")}");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: UpdateFile(file: widget.file),
                    ),
                  ],
                ),
              )),

          ///Bottom Controls
          Positioned(
            bottom: 0,
            height: 90,
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: VideoProgressIndicator(
                      _videoPlayerController,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                          bufferedColor: Colors.grey,
                          playedColor: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: IconButton(
                          focusColor: Colors.grey,
                          onPressed: () {
                            // Wrap the play or pause in a call to `setState`. This ensures the
                            // correct icon is shown.
                            setState(() {
                              // If the video is playing, pause it.
                              if (_videoPlayerController.value.isPlaying) {
                                _videoPlayerController.pause();
                              } else {
                                // If the video is paused, play it.
                                _videoPlayerController.play();
                              }
                            });
                          },
                          // Display the correct icon depending on the state of the player.
                          icon: Icon(
                            _videoPlayerController.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
