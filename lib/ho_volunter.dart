import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:camera_app/color.dart';
import 'package:video_player/video_player.dart';

class DemographiVolPage extends StatefulWidget {
  const DemographiVolPage({super.key});

  @override
  _DemographiVolPageState createState() => _DemographiVolPageState();
}

class _DemographiVolPageState extends State<DemographiVolPage>
    with SingleTickerProviderStateMixin {
  Future<List<Map<String, dynamic>>>? _futureVols;
  late TabController _tabController;
  int unseenCount = 0;
  int seenCount = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      languge = userDetails['selectedLanguage'];
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
      final vols = data.map((item) => item as Map<String, dynamic>).toList();

      // Count unseen and seen records
      unseenCount = vols.where((vol) => vol['status'] == 'unseen').length;
      seenCount = vols.where((vol) => vol['status'] != 'unseen').length;

      // Update state to refresh TabBar titles
      setState(() {});

      return vols;
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
      backgroundColor: Color.fromARGB(251, 232, 229, 229),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        title: Text(
          userDetails['selectedLanguage'] == 'Amharic'
              ? 'የበጎ ፍቃደኛ መረጃዎች'
              : userDetails['selectedLanguage'] == 'AfanOromo'
                  ? "Galmee Hawaasummaa "
                  : 'Demographic Records',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CustomColors.testColor1,
        bottom: TabBar(
          labelColor: Colors.white, // Set active tab text color
          unselectedLabelColor: Colors.white54, controller: _tabController,
          tabs: [
            Tab(
              text: userDetails['selectedLanguage'] == 'Amharic'
                  ? 'ሁሉንም አሳይ (${unseenCount + seenCount})'
                  : userDetails['selectedLanguage'] == 'AfanOromo'
                      ? 'Hunda (${unseenCount + seenCount})'
                      : "All",
            ),
            Tab(
              // Remove the 'text' property
              child: Text(
                userDetails['selectedLanguage'] == 'Amharic'
                    ? 'ያልታዩትን አሳይ ($unseenCount)'
                    : userDetails['selectedLanguage'] == 'AfanOromo'
                        ? "haaraa ($unseenCount)"
                        : 'Unseen ($unseenCount)',
                style: TextStyle(
                  color: unseenCount > 0 ? Colors.yellow : Colors.white54,
                ),
              ),
            ),
            Tab(
                text: userDetails['selectedLanguage'] == 'Amharic'
                    ? 'የታዩትን አሳይ ($seenCount)'
                    : userDetails['selectedLanguage'] == 'AfanOromo'
                        ? "Ilaalameera ($seenCount)"
                        : 'Seen ($seenCount)'),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
            return TabBarView(
              controller: _tabController,
              children: [
                _buildListView(vols),
                _buildListView(
                    vols.where((vol) => vol['status'] == 'unseen').toList()),
                _buildListView(
                    vols.where((vol) => vol['status'] != 'unseen').toList()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> vols) {
    return Container(
      child: ListView.builder(
        itemCount: vols.length,
        itemBuilder: (context, index) {
          final vol = vols[index];
          return GestureDetector(
            onTap: () {
              navigateToDetailPage(vol);
              updateMessageStatus(vol['id']);
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(255, 228, 222, 222),
                    width: 1.0), // Grey border
                color: Colors.white, // Card background color
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Flexible column to avoid unbounded width error
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vol['first_name']} ${vol['last_name']}',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(),
                        const SizedBox(height: 12.0),
                        _buildInfoRow(Icons.phone, 'Phone: ${vol['phonNo']}'),
                        _buildInfoRow(
                            Icons.location_on, 'Region: ${vol['region']}'),
                        _buildInfoRow(Icons.map, 'Zone: ${vol['zone']}'),
                        _buildInfoRow(
                            Icons.location_city, 'Woreda: ${vol['woreda']}'),
                        _buildInfoRow(Icons.person, 'Gender: ${vol['gender']}'),
                      ],
                    ),
                  ),
                  // Arrow forward icon
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.grey,
                    size: 24.0,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black54, // Label color
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
    print(vol);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // Set icon color here

          title: Text(
            "${vol['first_name']} ${vol['last_name']}",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous page
            },
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColors.testColor1, Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(4),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CustomColors.testColor1, Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volunteer Info',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(
                          // Allow the text to take available horizontal space
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align text to the start
                            children: [
                              Text(
                                'Address: ${vol['woreda']}, ${vol['zone']}, ${vol['region']}',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),
                                maxLines: 2, // Optional: limit to 2 lines
                                overflow: TextOverflow
                                    .visible, // Ensure overflow is handled by wrapping
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          'Phone: ${vol['phoneNo']}',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          'First Name: ${vol['first_name']}',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          'Last Name: ${vol['last_name']}',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Details Section

              const SizedBox(height: 24),

              // Image Section
              Text(
                languge == 'Amharic'
                    ? 'የበጎ ፍቃደኛ መረጃዎች'
                    : 'Demographic Image Records',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Divider(),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenImage(imageUrl: vol['image_url']),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    vol['image_url'],
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Video Section
              Text(
                languge == 'Amharic'
                    ? 'የበጎ ፍቃደኛ መረጃዎች'
                    : 'Demographic Recorded Videos',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Divider(),

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

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Start playing the video automatically
      });

    // Set up a timer to update the UI periodically
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Refresh the UI every second
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to full screen on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenVideoScreen(
              videoUrl: widget.videoUrl,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _controller.value.isInitialized
              ? Container(
                  width: 404, // Set desired width
                  height: 350, // Set desired height
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12), // Circular border radius
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
          SizedBox(height: 12), // Adds some space between video and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.blueAccent, // More vibrant color for buttons
                  size: 36, // Larger icons for better visibility
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
            ],
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoScreen extends StatefulWidget {
  final String videoUrl;

  FullScreenVideoScreen({required this.videoUrl});

  @override
  _FullScreenVideoScreenState createState() => _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Start playing the video automatically
      });

    // Set up a timer to update the UI periodically
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Refresh the UI every second
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const Center(child: CircularProgressIndicator()),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Text(
                      '${_controller.value.position.inSeconds} / ${_controller.value.duration.inSeconds} sec',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          LinearProgressIndicator(
            value: _controller.value.isInitialized
                ? _controller.value.position.inSeconds /
                    _controller.value.duration.inSeconds
                : 0,
            backgroundColor: Colors.white30,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pop(); // Close the full-screen view when tapped
          },
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain, // Fit the image within the screen
          ),
        ),
      ),
    );
  }
}
