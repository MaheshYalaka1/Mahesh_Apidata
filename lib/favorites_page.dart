import 'package:flutter/material.dart';
import 'package:mahesh_apidata/homepage.dart';

class CartPage extends StatelessWidget {
  final List<User> favorites;

  CartPage({required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorate list'),
      ),
      body: _buildCartList(),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        return _buildCartListItem(favorites[index]);
      },
    );
  }

  Widget _buildCartListItem(User user) {
    return Container(
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
            Icons.favorite,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
