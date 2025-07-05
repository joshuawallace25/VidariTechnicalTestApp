import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<String> users = ['Alice', 'Bob', 'Charlie', 'Diana'];
  String selectedUser;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => searchUsers(value),
              decoration: InputDecoration(
                hintText: 'Search users...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          // Selected user display
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selected: ${selectedUser.toUpperCase()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          // User list
          ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(users[index]),
                onTap: () {
                  setState(() {
                    selectedUser = users[index];
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    users.removeAt(index);
                    setState(() {});
                  },
                ),
              );
            },
          ),
          
          // Add user button
          FloatingActionButton(
            onPressed: () => addUser(),
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
  
  void searchUsers(String query) {
    if (query.isEmpty) {
      users = ['Alice', 'Bob', 'Charlie', 'Diana'];
    } else {
      users = users.where((user) => 
        user.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    setState(() {});
  }
  
  void addUser() {
    users.add('New User ${users.length + 1}');
    setState(() {});
  }
}