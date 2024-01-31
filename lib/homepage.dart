import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mahesh_apidata/favorites_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String avatar;
  bool isFavorite;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatar,
    this.isFavorite = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List<User> _users = [];
  List<User> _favorites = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _loadFavorites();
  }

  Future<void> _fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://reqres.in/api/users?page=2'));

    if (response.statusCode == 200) {
      final List<dynamic> usersData = jsonDecode(response.body)['data'];
      setState(() {
        _users = usersData.map((userData) => User.fromJson(userData)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteIds = prefs.getStringList('favorites');

    if (favoriteIds != null) {
      setState(() {
        _favorites = _users
            .where((user) => favoriteIds.contains(user.id.toString()))
            .toList();
      });
    }
  }

  Future<void> _toggleFavorite(User user) async {
    setState(() {
      user.isFavorite = !user.isFavorite;

      if (user.isFavorite) {
        _favorites.add(user);
      } else {
        _favorites.remove(user);
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds =
        _favorites.map((user) => user.id.toString()).toList();
    prefs.setStringList('favorites', favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: _buildUserList(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Navigate to home
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CartPage(favorites: _favorites)),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        return _buildUserItem(_users[index]);
      },
    );
  }

  Widget _buildUserItem(User user) {
    return GestureDetector(
      onTap: () {
        _toggleFavorite(user);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
            ),
            SizedBox(width: 16),
            Text('${user.firstName} ${user.lastName}'),
            Spacer(),
            Icon(
              user.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
