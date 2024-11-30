import 'dart:convert';
import 'package:camera_app/color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FetchBlogsScreen(),
    );
  }
}

class FetchBlogsScreen extends StatefulWidget {
  @override
  _FetchBlogsScreenState createState() => _FetchBlogsScreenState();
}

class _FetchBlogsScreenState extends State<FetchBlogsScreen> {
  List blogs = [];
  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  // Fetch blogs from the API
  Future<void> fetchBlogs() async {
    final response =
        await http.get(Uri.parse('http://192.168.47.228:7476/user/api/posts'));
    if (response.statusCode == 200) {
      setState(() {
        blogs = json.decode(response.body);
      });
    }
  }

  // Format the createdAt field
  String formatCreatedAt(String createdAt) {
    final dateTime = DateTime.parse(createdAt);
    return timeago.format(dateTime, locale: 'en');
  }

// Add a new comment
  Future<void> addComment(int blogId, String comment) async {
    final response = await http.post(
      Uri.parse('http://172.26.160.1:7476/user/posts/$blogId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'content': comment,
        'author': 'Author Name', // Replace with the actual author name
      }),
    );
    if (response.statusCode == 200) {
      fetchBlogs(); // Refresh blogs after adding a comment
    }
  }

  // Add a new comment
  // Toggle like on a blog
  Future<void> toggleLike(int blogId) async {
    final response = await http.post(
      Uri.parse('http://172.26.160.1:7476/user/posts/$blogId/like'),
    );
    if (response.statusCode == 200) {
      fetchBlogs(); // Refresh blogs after liking
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Posts',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: CustomColors.testColor1,
      ),
      body: blogs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];
                return BlogCard(
                  blog: blog,
                  // onAddComment: (comment) => addComment(blog['id'], comment),
                  onToggleLike: () => toggleLike(blog['id']),
                );
              },
            ),
    );
  }
}

class BlogCard extends StatefulWidget {
  final Map blog;
  final VoidCallback onToggleLike;

  BlogCard({
    required this.blog,
    required this.onToggleLike,
  });

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool showComments = false;
  TextEditingController commentController = TextEditingController();
  List comments = [];
  bool isLoadingComments = false;

  Future<void> fetchComments(int blogId) async {
    setState(() {
      isLoadingComments = true;
    });
    final response = await http.get(
      Uri.parse('http://172.26.160.1:7476/user/posts/$blogId/comments'),
    );
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          comments = json.decode(response.body);
          isLoadingComments = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingComments = false;
        });
      }
    }
  }

  Map<String, dynamic> userDetails = {};

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userDetails = {
        'email': prefs.getString('email') ?? 'N/A',
        'firstName': prefs.getString('first_name') ?? 'N/A',
        'lastName': prefs.getString('last_name') ?? 'N/A',
      };
    });
  }

  Future<void> addComment(int blogId, String comment) async {
    final response = await http.post(
      Uri.parse('http://192.168.8.228:7476/user/posts/$blogId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'content': comment,
        'author': '${userDetails['firstName']} ${userDetails['lastName']}',
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        comments.add({
          'content': comment,
          'author': '${userDetails['firstName']} ${userDetails['lastName']}',
        });
      });
    }
  }

  void initState() {
    super.initState();
    _loadUserDetails();
    fetchComments(widget.blog['id']);
  }

  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              blog['title'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CustomColors.testColor1,
              ),
            ),
            SizedBox(height: 8),
            // Author and Time Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Author: ${blog['author']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      timeago.format(DateTime.parse(blog['createdAt']),
                          locale: 'en'),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            // Content
            Text(
              blog['content'],
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 12),
            Divider(),
            // Actions (Like and Comment)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onToggleLike,
                  child: Row(
                    children: [
                      Icon(
                        (blog['isLiked'] ?? false)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: (blog['isLiked'] ?? false)
                            ? CustomColors.testColor1
                            : Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Like (${blog['likes'] ?? 0})',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showComments = !showComments;
                    });
                    if (showComments) {
                      fetchComments(blog['id']);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.comment, color: Colors.grey, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Comments (${comments.length})',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showComments)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  if (isLoadingComments)
                    Center(child: CircularProgressIndicator()),
                  if (!isLoadingComments && comments.isEmpty)
                    Text('No comments yet.',
                        style: TextStyle(color: Colors.grey)),
                  if (!isLoadingComments)
                    ...comments.map<Widget>((comment) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Comment Avatar
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue,
                                      CustomColors.testColor1
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    comment['author'][0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['author'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    comment['content'],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  // Add Comment Input
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: CustomColors.testColor1),
                        onPressed: () {
                          final comment = commentController.text.trim();
                          if (comment.isNotEmpty) {
                            addComment(blog['id'], comment);
                            commentController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(BlogApp());
}
