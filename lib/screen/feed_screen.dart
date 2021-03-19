import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _FeedScreenState extends State<FeedScreen> {
  CollectionReference feed = firestore.collection("feed");
  CollectionReference users = firestore.collection("users");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.pink,
        title: Text(
          "Instagram",
          style: GoogleFonts.pacifico(fontSize: 29),
        ),
        actions: [
          Icon(
            Icons.favorite_border,
            size: 35,
          ),
          SizedBox(
            width: 10,
          ),
          Icon(
            Icons.message_outlined,
            size: 35,
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(
          child: ListView(
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: feed.snapshots(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  EasyLoading.dismiss();
                  return Column(
                    children: snapshot.data.docs
                        .map((e) => itemCard(
                              e.data()['username'],
                              e.data()['uid'],
                              e.data()['uavatarUrl'],
                              e.data()['imageUrl'],
                              e.data()['desc'],
                            ))
                        .toList(),
                  );
                } else {
                  EasyLoading.show(status: 'loading...');
                  return Container();
                }
              })
        ],
      )),
    );
  }

  Widget itemCard(String uName, String uId, String uAvatarUrl, String imageUrl,
      String desc) {
    return Card(
      elevation: 0,
      child: Container(
        //width: 100.0.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 26.1,
                  backgroundColor: Colors.pink,
                  child: CircleAvatar(
                    radius: 25.0,
                    backgroundImage: uAvatarUrl == null
                        ? AssetImage('assets/images/avatar.png')
                        : NetworkImage(uAvatarUrl),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  uName ?? "Anonimous",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 350,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.favorite_border,
                  size: 35,
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.comment_outlined,
                  size: 35,
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.share_outlined,
                  size: 35,
                ),
                SizedBox(
                  width: 10,
                ),
                Spacer(),
                Icon(
                  Icons.bookmark_border_sharp,
                  size: 35,
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            Text(uName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Container(
              child: Text(desc,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
