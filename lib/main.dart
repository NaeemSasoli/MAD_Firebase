import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostFeedScreen(),
    );
  }
}

class Post {
  String title;
  String description;
  Uint8List? imageBytes;

  Post({required this.title, required this.description, this.imageBytes});
}

class PostFeedScreen extends StatefulWidget {
  @override
  _PostFeedScreenState createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  List<Post> posts = [];

  void addOrUpdatePost(Post post, [int? index]) {
    setState(() {
      if (index != null) {
        posts[index] = post;
      } else {
        posts.add(post);
      }
    });
  }

  void deletePost(int index) {
    setState(() {
      posts.removeAt(index);
    });
  }

  void showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Post?"),
        content: Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("No")),
          TextButton(
            onPressed: () {
              deletePost(index);
              Navigator.pop(context);
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Social Media Feed")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadPostScreen(),
            ),
          );
          if (result != null) addOrUpdatePost(result);
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text(post.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.imageBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.memory(post.imageBytes!, height: 150),
                    ),
                  Text(post.description),
                ],
              ),
              trailing: Wrap(
                spacing: 12,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UploadPostScreen(
                            existingPost: post,
                            index: index,
                          ),
                        ),
                      );
                      if (result != null) addOrUpdatePost(result, index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => showDeleteDialog(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class UploadPostScreen extends StatefulWidget {
  final Post? existingPost;
  final int? index;

  UploadPostScreen({this.existingPost, this.index});

  @override
  _UploadPostScreenState createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  Uint8List? selectedImageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      titleController.text = widget.existingPost!.title;
      descController.text = widget.existingPost!.description;
      selectedImageBytes = widget.existingPost!.imageBytes;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingPost == null ? "Upload Post" : "Edit Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 10),
              if (selectedImageBytes != null)
                Image.memory(selectedImageBytes!, height: 150),
              ElevatedButton(
                onPressed: pickImage,
                child: Text("Pick Image"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final post = Post(
                    title: titleController.text,
                    description: descController.text,
                    imageBytes: selectedImageBytes,
                  );
                  Navigator.pop(context, post);
                },
                child: Text(widget.existingPost == null ? "Upload" : "Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
