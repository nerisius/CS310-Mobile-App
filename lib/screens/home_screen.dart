import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary fake data to simulate feed
    final List<Map<String, String>> posts = [
      {
        'user': 'Zeynep Menekşe',
        'activity': 'finished reading "The Midnight Library"',
      },
      {
        'user': 'Ali Yılmaz',
        'activity': 'shared a quote from "1984"',
      },
      {
        'user': 'Elif Kaya',
        'activity': 'reached page 120 of "Sapiens"',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Later: navigate to Profile
            },
          ),
        ],
      ),

      // Feed List
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(post['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(post['activity']!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.favorite_border, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Icon(Icons.comment_outlined, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),

      // Add Post Floating Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Later: navigate to "Add Post" screen
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
