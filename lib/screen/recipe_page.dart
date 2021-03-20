import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter_udacoding_week3/screen/add_screen.dart';
import 'package:flutter_udacoding_week3/screen/edit_profile.dart';
import 'package:flutter_udacoding_week3/screen/feed_screen.dart';
import 'package:flutter_udacoding_week3/screen/profile_screen.dart';

class RecipePage extends StatefulWidget {
  final String uid;
  final String username;
  RecipePage({this.uid, this.username});
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            FeedScreen(
              uid: widget.uid,
            ),
            AddScreen(
              uid: widget.uid,
            ),
            ProfileScreen(
              uid: widget.uid,
              username: widget.username,
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            title: Text('Feed'),
            icon: Icon(Icons.home),
          ),
          BottomNavyBarItem(
            title: Text('Add'),
            icon: Icon(Icons.add_box_outlined),
          ),
          BottomNavyBarItem(
            title: Text('Profile'),
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
