import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: UserPostApp());
  }
}

class UserPostApp extends StatefulWidget {
  @override
  _UserPostAppState createState() => _UserPostAppState();
}

class _UserPostAppState extends State<UserPostApp> {
  List users = [];
  List posts = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchPosts();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    }
  }

  Future<void> fetchPosts() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'),
    );
    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body);
      });
    }
  }

  void createPost() {
    setState(() {
      posts.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': titleController.text,
        'body': bodyController.text,
      });
      titleController.clear();
      bodyController.clear();
    });
  }

  void updatePost(int id) {
    final index = posts.indexWhere((post) => post['id'] == id);
    if (index != -1) {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController editTitle = TextEditingController(
            text: posts[index]['title'],
          );
          TextEditingController editBody = TextEditingController(
            text: posts[index]['body'],
          );
          return AlertDialog(
            title: Text('Edit Post'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: editTitle),
                TextField(controller: editBody),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    posts[index]['title'] = editTitle.text;
                    posts[index]['body'] = editBody.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void deletePost(int id) {
    setState(() {
      posts.removeWhere((post) => post['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users & Posts')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Users',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...users.map(
              (user) => ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
              ),
            ),
            Divider(),
            Text(
              'Create Post',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(labelText: 'Body'),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: createPost, child: Text('Add Post')),
            Divider(),
            Text(
              'Posts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ...posts.map(
              (post) => Card(
                child: ListTile(
                  title: Text(post['title'] ?? ''),
                  subtitle: Text(post['body'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => updatePost(post['id']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deletePost(post['id']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
