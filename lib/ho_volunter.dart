import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:camera_app/color.dart';
import 'package:video_player/video_player.dart'; // Assuming this is your custom color file

class DemographiVolPage extends StatefulWidget {
  const DemographiVolPage({super.key});

  @override
  _DemographiVolPageState createState() => _DemographiVolPageState();
}

class _DemographiVolPageState extends State<DemographiVolPage> {
  Future<List<Map<String, dynamic>>>? _futureVols;
  String filter = "all"; // Default filter is "all"

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Map<String, dynamic> userDetails = {};
  String languge = '';

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userDetails = {
        'email': prefs.getString('email') ?? 'N/A',
        'userType': prefs.getString('userType') ?? 'N/A',
        'firstName': prefs.getString('first_name') ?? 'N/A',
        'phoneNo': prefs.getString('phoneNo') ?? 'N/A',
        'zone': prefs.getString('zone') ?? 'N/A',
        'woreda': prefs.getString('woreda') ?? 'N/A',
        'id': prefs.getInt('id') ?? 'N/A',
        'selectedLanguage': prefs.getString('selectedLanguage') ?? 'N/A',
      };
      setState(() {
        languge = userDetails['selectedLanguage'];
      });
      print(userDetails);

      // Fetch data by phone number and assign the future to _futureVols
      _futureVols = fetchDataByPhone(userDetails['phoneNo']);
    });
  }

  Future<List<Map<String, dynamic>>> fetchDataByPhone(String phoneNo) async {
    final response = await http.get(
      Uri.parse(
          'http://testgithub.polioantenna.org/clinic/records?phonNo=$phoneNo'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> updateMessageStatus(int messageId) async {
    final apiUrl =
        'http://testgithub.polioantenna.org/clinic/messages23/$messageId';
    print(apiUrl);
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Message status updated successfully
        print('Message status updated to seen');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message status updated to seen'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Error updating message status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating message status'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while updating the message status'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void navigateToDetailPage(Map<String, dynamic> vol) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
            vol: vol,
            languge: userDetails[
                'selectedLanguage']), // Assuming you have a DetailPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userDetails['selectedLanguage'] == 'Amharic'
              ? 'የበጎ ፍቃደኛ መረጃዎች'
              : 'Demographic Records', // Use an empty string as a fallback
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor:
            CustomColors.testColor1, // Assuming you have custom colors
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filter = "all";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    userDetails['selectedLanguage'] == 'Amharic'
                        ? 'ሁሉንም አሳይ'
                        : "Show All",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filter = "unseen";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    userDetails['selectedLanguage'] == 'Amharic'
                        ? 'ያልታዩትን  አሳይ'
                        : "Unread",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filter = "seen";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    userDetails['selectedLanguage'] == 'Amharic'
                        ? 'የታዩትን  አሳይ'
                        : "seen",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureVols,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                          'No data found for phone number ${userDetails['phoneNo']}'),
                    );
                  } else {
                    final vols = snapshot.data!;
                    final filteredVols = vols.where((vol) {
                      if (filter == "all") return true;
                      if (filter == "unseen") return vol['status'] == "unseen";
                      if (filter == "seen") return vol['status'] != "unseen";
                      return true;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredVols.length,
                      itemBuilder: (context, index) {
                        final vol = filteredVols[index];

                        return GestureDetector(
                          onTap: () {
                            navigateToDetailPage(vol);
                            updateMessageStatus(vol['id']);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16.0),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${vol['first_name']} ${vol['last_name']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          ' Phone: ${vol['phonNo']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          'Region: ${vol['region']}, ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          'zone: ${vol['zone']}, ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          'woreda: ${vol['woreda']} ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          'Gender: ${vol['gender']},',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            navigateToDetailPage(vol);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 7),
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            elevation: 5,
                                          ),
                                          child: Text(
                                            userDetails['selectedLanguage'] ==
                                                    'Amharic'
                                                ? 'ተጨማሪ  አሳይ'
                                                : "View Detail",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> vol;
  final String languge;
  const DetailPage({super.key, required this.vol, required this.languge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${vol['first_name']} ${vol['last_name']}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languge == 'Amharic' ? 'የበጎ ፍቃደኛ መረጃዎች' : 'Demographic Records',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  vol['image_url'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Region: ${vol['region']}\nPhone: ${vol['phonNo']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              VideoPlayerWidget(
                videoUrl: vol['video_url'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const Center(child: CircularProgressIndicator()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  if (_isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.blue),
              onPressed: () {
                setState(() {
                  _controller
                      .setVolume(_controller.value.volume == 0 ? 1.0 : 0);
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
