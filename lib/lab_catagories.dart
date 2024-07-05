import 'package:camera_app/Laboratory%20Information_Final%20classification%20%20.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(labCatagory());
}

class labCatagory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stool Categories',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stool Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CategoryCard(
              title: 'Stool 1',
              color: Colors.blue,
            onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LaboratoryFinalClassificationForm()),
                );
              },
            ),
            CategoryCard(
              title: 'Stool 2',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LaboratoryFinalClassificationForm()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  CategoryCard({
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Stool1Page extends StatefulWidget {
  @override
  _Stool1PageState createState() => _Stool1PageState();
}

class _Stool1PageState extends State<Stool1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stool 1 Details'),
      ),
      body: Center(
        child: Text(
          'Details for Stool 1',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class Stool2Page extends StatefulWidget {
  @override
  _Stool2PageState createState() => _Stool2PageState();
}

class _Stool2PageState extends State<Stool2Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stool 2 Details'),
      ),
      body: Center(
        child: Text(
          'Details for Stool 2',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
