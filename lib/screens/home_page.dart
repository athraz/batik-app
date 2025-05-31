import 'package:batik_app/models/post.dart';
import 'package:batik_app/services/post_service.dart';
import 'package:batik_app/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final PostService postService = PostService();

  @override
  Widget build(BuildContext context) {
    final List<VoidCallback> actions = [
      () {
        // TODO: refresh
      },
      () {
        Navigator.pushNamed(context, 'post/create');
      },
      () {
        Navigator.pushNamed(context, 'profile');
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BerbagiBatik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: postService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No post"));
          }

          List<Map<String, dynamic>> postList = snapshot.data!;

          return ListView.builder(
            itemCount: postList.length,
            itemBuilder: (context, index) {
              final postData = postList[index];

              Post post = Post(
                id: postData['postId'],
                caption: postData['caption'],
                userId: postData['userId'],
                createdAt: (postData['createdAt'] as Timestamp).toDate(),
                images: postData['images'],
              );

              return PostCard(
                post: post,
                index: index.toString(),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index < actions.length) {
            actions[index]();
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 32), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 32), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle, size: 32), label: 'Profile'),
        ],
      ),
    );
  }
}
