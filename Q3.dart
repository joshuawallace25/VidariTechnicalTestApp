import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // Bug 1: Null Safety Issue with selectedUser
  // Issue: selectedUser is declared as non-nullable String but not initialized, causing null reference errors when toUpperCase() is called.
  // Impact: App crashes with 'NoSuchMethodError: The method 'toUpperCase' was called on null' when rendering the Text widget.
  // Fix: I made the selectedUser nullable (String?) and handle null case in the UI with a fallback value.
  List<String> allUsers = ['Alice', 'Bob', 'Charlie', 'Diana'];
  List<String> filteredUsers = ['Alice', 'Bob', 'Charlie', 'Diana'];
  String? selectedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: searchUsers,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
             
              'Selected: ${selectedUser?.toUpperCase() ?? "None"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Bug 2: ListView Layout Issue in Column
          // Issue: ListView.builder inside Column without constrained height causes layout error.
          // Impact: App throws 'Vertical viewport was given unbounded height' error, failing to render the list.
          // Fix:I Wrap ListView.builder in Expanded to constrain its height to available space.
          // Bug 6: Search State Inconsistency (Empty State Handling)
          // Issue: No explicit handling for empty search results, leaving UI sparse.
          // Impact: User sees empty list without feedback when no users match search query.
          // Fix:I Added conditional check to display 'No users found' when filteredUsers is empty.
          filteredUsers.isEmpty
              ? const Center(child: Text('No users found'))
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      // Bug 8: Missing Key for ListView Items
                      // Issue: ListTile lacks unique key, causing potential rendering issues during list updates.
                      // Impact: Incorrect rendering or animation glitches when items are added/removed.
                      // Fix:I Added ValueKey based on user name to ensure proper widget diffing.
                      return ListTile(
                        key: ValueKey(filteredUsers[index]),
                        title: Text(filteredUsers[index]),
                        onTap: () {
                          setState(() {
                            selectedUser = filteredUsers[index];
                          });
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Bug 5: Selected User Persists After Deletion
                            // Issue: Deleting a selected user doesn't clear selectedUser, showing invalid state.
                            // Impact: UI displays deleted user as selected, confusing the user.
                            // Fix: now the system Check if deleted user is selected and clear selectedUser if needed.
                            setState(() {
                              final deletedUser = filteredUsers[index];
                              allUsers.remove(deletedUser);
                              filteredUsers.removeAt(index);
                              if (selectedUser == deletedUser) {
                                selectedUser = null;
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      // Bug 3: FloatingActionButton Placement
      // Issue: FloatingActionButton is incorrectly placed in Column, not following Material Design guidelines.
      // Impact: Button appears in list content, potentially obscured or misaligned, leading to poor UX.
      // Fix:I Move the FloatingActionButton to Scaffold's floatingActionButton property.
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Bug 4: Search Functionality Overwrites Original Data
  // Issue: searchUsers modifies users list directly, losing added users when search is cleared.
  // Impact: Added users are lost after search, causing data loss and inconsistent behavior.
  // Fix: I Use separate allUsers and filteredUsers lists to preserve original data.
  // Bug 6 (cont.): Search State Inconsistency
  // Issue: Rapid typing in search could lead to inconsistent UI updates due to frequent setState.
  // Impact: UI may not reflect latest search state accurately.
  // Fix: While a debouncer could optimize, separate lists and efficient setState suffice for simplicity.
  void searchUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(allUsers);
      } else {
        filteredUsers = allUsers
            .where((user) => user.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Bug 7: Unnecessary setState Calls
  // Issue: Redundant setState calls in addUser and searchUsers increase rebuilds and reduce clarity.
  // Impact: Slightly less efficient code, harder to maintain.
  // Fix:I Consolidate state updates in a single setState call.
  void addUser() {
    setState(() {
      allUsers.add('New User ${allUsers.length + 1}');
      filteredUsers = List.from(allUsers);
    });
  }
}