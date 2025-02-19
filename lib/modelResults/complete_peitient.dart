import 'package:camera_app/FollowUpExaminationForm%20.dart';
import 'package:camera_app/camera_test.dart';
import 'package:camera_app/clinical_history.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/commite/results.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/mo/api.dart';
import 'package:camera_app/modelResults/model_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Complete extends StatefulWidget {
  const Complete({super.key});

  @override
  _DataListPageState createState() => _DataListPageState();
}

class _DataListPageState extends State<Complete>
    with SingleTickerProviderStateMixin {
  List<dynamic> data = [];
  bool isLoading = true;
  Map<String, dynamic> userDetails = {};
  String languge = "ccc";
  LanguageResources? resources;
  String _selectedLanguage = "English";
  LanguageResources? resource12;

  late TabController _tabController;
  List<dynamic> _filteredData = []; // To store filtered data
  String _selectedFilter = 'all'; // Initial filter value

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadLanguage45();
    _loadLanguage().then((_) {
      setState(() {
        _selectedLanguage = languge;
        resources = LanguageResources(languge);
      });
    });
    _tabController =
        TabController(length: 3, vsync: this); // Initialize TabController
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedFilter = 'all';
          break;
        case 1:
          _selectedFilter = 'recieved';
          break;
        case 2:
          _selectedFilter = 'not_recieved';
          break;
      }
      _filterData();
    });
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'none';
    if (mounted) {
      setState(() {
        languge = storedLanguage;
      });
    }
  }

  Future<void> _loadLanguage45() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      resources = LanguageResources(languge);
      resource12 = resources;
    });
  }

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
      };
    });

    fetchData(userDetails['id']);
  }

  Future<void> fetchData(int userId) async {
    String url = '${baseUrl}clinic/getDataByUserIdCompleted/$userId';
    print("Fetching data from: $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        data = json.decode(response.body);
        _filterData(); // Filter data initially
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _filterData() {
    if (_selectedFilter == 'all') {
      _filteredData = data;
    } else {
      _filteredData = data.where((item) {
        if (item['lab_stool'] == null) {
          return false; // Skip items where lab_stool is null
        }
        return item['lab_stool'].toLowerCase() == _selectedFilter;
      }).toList();
    }
  }

  Future<void> _deleteDataById(int id) async {
    String url = '${baseUrl}clinic/deleteDataById/$id';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        data.removeWhere((item) => item['id'] == id);
        _filterData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully')),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Complete(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete record')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(int patientId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              const SizedBox(width: 10),
              const Text(
                'Delete Confirmation',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this record? This action cannot be undone.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteDataById(patientId); // Delete the record
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(251, 232, 229, 229),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0), // Increased appbar height
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            languge == "Amharic"
                ? 'ያለቁ የታካሚ መዝገቦች'
                : languge == "AfanOromo"
                    ? "Galmee xumurame"
                    : 'Completed Patient',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
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
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  text: languge == "Amharic"
                      ? 'ሁሉም'
                      : languge == "AfanOromo"
                          ? "Hunda"
                          : 'All'),
              Tab(
                  text: languge == "Amharic"
                      ? 'የደረሰ'
                      : languge == "AfanOromo"
                          ? "Argame"
                          : 'Received'),
              Tab(
                  text: languge == "Amharic"
                      ? 'ያልደረሰ'
                      : languge == "AfanOromo"
                          ? "Hin arganne"
                          : 'Not Received'),
            ],
            indicatorColor: Colors.white, // Make indicator white
            labelColor: Colors.white, // Make label text white
            unselectedLabelColor:
                Colors.white70, // Make unselected labels a bit transparent
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDataList(_filteredData),
                _buildDataList(_filteredData),
                _buildDataList(_filteredData),
              ],
            ),
    );
  }

  Widget _buildDataList(List<dynamic> currentData) {
    return ListView.builder(
      itemCount: currentData.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentData[index]['first_name']} ${currentData[index]['last_name']}',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Divider(),
                      const SizedBox(height: 12.0),
                      _buildInfoRow(Icons.phone,
                          'Phone: ${currentData[index]['phoneNo'] ?? 'N/A'}'),
                      _buildInfoRow(Icons.location_on,
                          'Region: ${currentData[index]['region'] ?? 'N/A'}'),
                      _buildInfoRow(Icons.map,
                          'Zone: ${currentData[index]['zone'] ?? 'N/A'}'),
                      _buildInfoRow(Icons.location_city,
                          'Woreda: ${currentData[index]['woreda'] ?? 'N/A'}'),
                      _buildInfoRow(Icons.person,
                          'Gender: ${currentData[index]['gender'] ?? 'N/A'}'),
                      ElevatedButton(
                        onPressed: () {
                          // Add your desired functionality here
                          String progressNo =
                              currentData[index]['progressNo'] ?? "";

                          // Navigation logic
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EpidDataPage(
                                type: "health",
                                epidNumber: currentData[index]['epid_number'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors
                              .testColor1, // Button background color
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5), // Rounded corners
                          ),
                        ),
                        child: Text(
                          "View Detail ",
                          style: const TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16, // Font size
                            fontWeight: FontWeight.bold, // Font weight
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Add trailing icon for delete
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                        currentData[index]['petient_id']);
                  },
                ),
              ],
            ),
          ),
        );
      },
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
