import 'package:camera_app/blog/fetch_blogs.dart';
import 'package:camera_app/color.dart';
import 'package:camera_app/polioDashboard.dart';
import 'package:camera_app/profile.dart';
import 'package:camera_app/protected/AuthGuard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: PolioDashboard(),
    );
  }
}

class PolioDashboard extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<PolioDashboard> {
  int _selectedIndex = 0;
  String? _selectedLanguage = 'English'; // Default value

  // List of pages for navigation
  final List<Widget> _pages = [
    PolioDashboard1(),
    FetchBlogsScreen(),
    UserProfile(),
  ];
  void initState() {
    super.initState();
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    if (mounted) {
      setState(() {
        _selectedLanguage = storedLanguage;
      });
    }
  }

  // Update the selected index
  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: CustomColors.testColor1,
          unselectedItemColor: Colors.black,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: _selectedLanguage == "Amharic"
                  ? "ቤት"
                  : _selectedLanguage == "AfanOromo"
                      ? "mana"
                      : "home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: _selectedLanguage == "Amharic"
                  ? "ብሎግ"
                  : _selectedLanguage == "AfanOromo"
                      ? "Biloogii"
                      : "blog",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: _selectedLanguage == "Amharic"
                  ? "መገለጫ"
                  : _selectedLanguage == "AfanOromo"
                      ? "Piroofaayilii"
                      : "Profile",
            ),
          ],
          selectedLabelStyle: GoogleFonts.poppins(
            color: CustomColors.testColor1,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class BlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'Check out the latest blog posts!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'This is your profile page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
