import 'package:camera_app/color.dart';
import 'package:camera_app/drawer.dart';
import 'package:camera_app/languge/LanguageResources.dart';
import 'package:camera_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PolioDashboard1 extends StatefulWidget {
  const PolioDashboard1({super.key});

  @override
  _PolioDashboardState createState() => _PolioDashboardState();
}

class _PolioDashboardState extends State<PolioDashboard1> {
  bool _isDisposed = false;

  String userType = '';
  String email = '';
  String _selectedLanguage = "English";
  String languge = "ccc";
  LanguageResources? resources;
  LanguageResources? resource12;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadLanguage45();
    _loadLanguage().then((_) {
      setState(() {
        _selectedLanguage = languge;
        resources = LanguageResources(languge);
      });
    });
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  void dispose() {
    _isDisposed = true;
    super.dispose();
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
    if (!_isDisposed) {
      setState(() {
        resources = LanguageResources(languge);
        resource12 = resources;
      });
    }
  }

  final List<String> imagePaths = [
    // "assets/im/polio1.jpg",
    // "assets/im/polio2.jpg",
    // "assets/im/polio3.jpg",
    // "assets/im/polio4.jpg",
    // "assets/im/polio5.jpg",
  ];

  final List<String> anotherPath = [
    // "assets/im/acute1.jpg",
    // "assets/im/acute2.jpg",
    // "assets/im/acute3.jpg",
  ];

  final List<String> map = [
    "assets/im/yarie.jpg",
  ];

  final String map34 = '''
- The world has made significant progress towards polio eradication, with a 99% reduction in cases since 1988
- Africa was certified free of wild poliovirus in 2020, though vaccine-derived polio cases still occur
- Ethiopia has been polio-free since 2014 but continues to face challenges with imported cases and vaccine-derived poliovirus
  ''';

  final String map34afm = '''
Haala Pooliyoo Addunyaa fi Naannawaa
- Addunyaan gama pooliyoo dhabamsiisuutiin guddina guddaa kan agarsiifte yoo ta’u, bara 1988 irraa eegalee namootni dhukkubichaan qabaman 99% hir’ataniiru
- Afrikaan bara 2020tti vaayirasii pooliyoo bosonaa (wild polio virus) irraa bilisa ta'uun mirkanaa'eera, haa ta'u malee ammallee namoonni pooliyoo talaallii irraa dhufuun qabaman ni jiru
- Itiyoophiyaan bara 2014 irraa eegalee pooliyoo irraa bilisa 
  ''';

  final String map34am = '''
ዓለም አቀፍ እና ክልላዊ የፖሊዮ ሁኔታ
- ከ 1988 ጀምሮ በ99% በቫይረሱ ​​​​መጥፋት ላይ ዓለም ከፍተኛ እድገት አሳይቷል.
- አፍሪካ እ.ኤ.አ. በ 2020 ከዱር ፖሊዮ ቫይረስ ነፃ መሆኗን የተረጋገጠ ቢሆንም በክትባት የተገኘ የፖሊዮ ጉዳዮች አሁንም ቢኖሩም
- ኢትዮጵያ እ.ኤ.አ. ከ2014 ጀምሮ ከፖሊዮ ነፃ ሆናለች ነገርግን ከውጪ በሚገቡ ጉዳዮች እና በክትባት የተገኘ የፖሊዮ ቫይረስ ፈተናዎች እየተጋፈጡ ይገኛሉ።
  ''';

  final String polioOverview = '''

- Polio is a highly contagious viral disease that primarily affects young children
- It can cause lifelong paralysis and, in some cases, lead to death
- Polio is caused by the poliovirus and spreads through contaminated water or food
  ''';
  final String polioOverviewafm = '''
Pooliyoo
- Dhukkuba vaayirasii baay’ee daddarbaa ta’ee fi adda durummaan daa’imman xixiqqoo miidhudha
- Laamsha’uu umrii guutuu fi yeroo tokko tokko du’aaf nama saaxiluu danda’a
- Vaayirasii pooliyoo jedhamuun kan dhufu yoo ta’u, bishaan ykn nyaata faalameen kan babal’atudha

  ''';

  final String polioOverviewam = '''
የፖሊዮ አጠቃላይ እይታ
- ፖሊዮ በጣም ተላላፊ የቫይረስ በሽታ ሲሆን በዋነኛነት ትንንሽ ልጆችን ያጠቃል
- የዕድሜ ልክ ሽባ ሊያመጣ ይችላል, እና በአንዳንድ ሁኔታዎች, ለሞት ሊዳርግ ይችላል
- ፖሊዮ በፖሊዮ ቫይረስ የሚመጣ ሲሆን በተበከለ ውሃ ወይም ምግብ ይተላለፋል
  ''';
  final String WhatisthePolioVirus = '''

⦁	Polio is a highly contagious viral disease that primarily affects young children
⦁	It can cause lifelong paralysis and, in some cases, lead to death
⦁	Polio is caused by the poliovirus and spreads through contaminated water or food

  ''';
  final String AboutPolioAntennaAPP = '''
PolioAntenna is a mobile app that automates acute flaccid paralysis (AFP) surveillance by collecting real-time multimedia data—forms, images, and videos. It offers immediate diagnoses of the polio virus, serving as a vital tool for community volunteers and public health officials. By streamlining data collection, PolioAntenna enhances outbreak monitoring and response, while its user-friendly interface allows volunteers to efficiently input critical information, strengthening public health efforts.
  ''';

  final String AboutRAPPS = '''
RAPPS is a project that is part of a global IDRC-funded initiative on AI for Global Health. It aims to improve polio surveillance sensitivity through responsible AI in a decolonized approach using local capacity and local data focusing on empowering underserved groups. Click/copy the link (https://www.polioantenna.org/) to get more information about the project
  ''';

  final String AFP = '''
- AFP surveillance is a key strategy in the global effort to eradicate polio
- AFP is a sudden onset of weakness or paralysis in any part of the body in a child under 15 years old
- Monitoring AFP cases helps identify potential polio infections and guide public health response
  ''';

  final String AFPafm = '''
(AFP)
- Hordoffiin AFP tattaaffii addunyaa pooliyoo dhabamsiisuuf taasifamu keessatti tooftaa ijoodha
- AFP’n taatee daa’ima waggaa 15 gadi ta’e irratti dadhabbii ykn laamsha’uu akka tasaa kutaa qaama kamiyyuu keessatti uumamudha
- Hordoffiin taatee AFP infekshinii pooliyoo ta’uu danda’an adda baasuu fi tarkaanfiiwwan fayyaa hawaasaa ilaallatan qajeelchuuf gargaara

  ''';
  final String AFPam = '''
አጣዳፊ የፍላሲድ ፓራላይዝስ (ኤኤፍፒ) ክትትል
- የ AFP ክትትል ፖሊዮን ለማጥፋት በሚደረገው ዓለም አቀፍ ጥረት ውስጥ ቁልፍ ስትራቴጂ ነው።
- AFP ከ15 ዓመት በታች በሆነ ህጻን ውስጥ በማንኛውም የሰውነት ክፍል ላይ ድንገተኛ ድክመት ወይም ሽባ ነው።
- የ AFP ጉዳዮችን መከታተል የፖሊዮ ኢንፌክሽኖችን ለመለየት እና የህዝብ ጤና ምላሽን ለመምራት ይረዳል
  ''';

  final double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer45(
        resources1: resource12,
        email: email,
        userType: userType,
        languge: languge,
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // Set icon color here

          title: Text(
            'Welcome, User!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
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
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, size: 26),
              onPressed: () {
                // Implement notification functionality
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.people_alt, size: 26),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfile(),
                  ),
                );
              },
              color: Colors.white,
            ),
            // SizedBox(width: 10), // Add spacing for better alignment
          ],
        ),
      ),
      body: resources == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                color: const Color.fromARGB(251, 232, 229, 229),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          // width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          // BoxShadow(
                          //   color: Colors.grey.withOpacity(0.3),
                          //   spreadRadius: 3,
                          //   blurRadius: 8,
                          //   offset: Offset(0, 3),
                          // ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: CustomColors.testColor1, size: 26),
                              const SizedBox(width: 8),
                              Text(
                                'About RAPPS',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: CustomColors.testColor1,
                            thickness: 2,
                            endIndent: 30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AboutRAPPS,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              height: 1.5, // Improved readability
                              // fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Handle URL tap
                              launchUrlString('https://www.polioantenna.org/');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: CustomColors.testColor1,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.5),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Learn More',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.link,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20.0), // Adjust the radius as needed
                        child: Image.asset(
                          'assets/im/yarie.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          // width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey.withOpacity(0.3),
                        //     spreadRadius: 3,
                        //     blurRadius: 8,
                        //     offset: Offset(0, 3),
                        //   ),
                        // ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: CustomColors.testColor1, size: 26),
                              const SizedBox(width: 8),
                              const Text(
                                'About Polio Antenna APP',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: CustomColors.testColor1,
                            thickness: 2,
                            endIndent: 30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AboutPolioAntennaAPP,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5, // Improved readability
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Handle URL tap
                              launchUrlString('https://www.polioantenna.org/');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: CustomColors.testColor1,
                                borderRadius: BorderRadius.circular(8),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.blue.withOpacity(0.5),
                                //     blurRadius: 5,
                                //     spreadRadius: 2,
                                //   ),
                                // ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Learn More',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.link,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info,
                                  color: CustomColors.testColor1, size: 26),
                              const SizedBox(width: 8),
                              const Text(
                                'What is the Polio Virus???',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: CustomColors.testColor1,
                            thickness: 2,
                            endIndent: 30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            WhatisthePolioVirus,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              height: 1.5, // Improves line spacing
                              // fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Handle URL or interaction
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: CustomColors.testColor1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Learn More',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.link,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_hospital_outlined,
                                  color: CustomColors.testColor1, size: 26),
                              const SizedBox(width: 8),
                              Text(
                                languge == "Amharic"
                                    ? 'AFP ስለላ'
                                    : "AFP Surveillance",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: CustomColors.testColor1,
                            thickness: 2,
                            endIndent: 30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            languge == "Amharic"
                                ? AFPam
                                : languge == "AfanOromo"
                                    ? AFPafm
                                    : AFP,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5, // Improves line spacing
                              // fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Handle additional actions or navigation
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: CustomColors.testColor1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Learn More',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.link,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.language_outlined,
                                  color: CustomColors.testColor1, size: 26),
                              const SizedBox(width: 8),
                              Text(
                                languge == "Amharic"
                                    ? "የፖሊዮ ሁኔታ"
                                    : 'Polio Status',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: CustomColors.testColor1,
                            thickness: 2,
                            endIndent: 30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            languge == "Amharic"
                                ? map34am
                                : languge == "AfanOromo"
                                    ? map34afm
                                    : map34,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                height: 1.5, // Improves line spacing
                                // fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Handle additional actions or navigation
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: CustomColors.testColor1,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Learn More',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.arrow_forward,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }
}
