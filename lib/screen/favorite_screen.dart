import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_udacoding_week3/screen/detail_screnn.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteScreen extends StatefulWidget {
  final String uid;
  FavoriteScreen({this.uid});
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _FavoriteScreenState extends State<FavoriteScreen> {
  CollectionReference feed = firestore.collection("feed");
  CollectionReference users = firestore.collection("users");
  CollectionReference favorite = firestore.collection("favorite");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Favorite", style: GoogleFonts.pacifico(fontSize: 25)),
      ),
      body: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: favorite.snapshots(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  EasyLoading.dismiss();
                  return ListView(
                    children: snapshot.data.docs.map((e) {
                      return itemCard(
                          e.data()['uid'],
                          e.data()['imageUrl'],
                          e.data()['title'],
                          e.data()['FeedId'],
                          e.data()['desc']);
                    }).toList(),
                  );
                } else {
                  EasyLoading.show(status: 'loading...');
                  return Container();
                }
              })),
    );
  }

  Widget itemCard(String uId, String imageUrl, String title, String feedDocId,
      String desc) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DetailScreen(
                    docId: feedDocId,
                  ))),
      child: Card(
        elevation: 3,
        child: Container(
          //width: 100.0.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: 100,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        child: Text(
                          desc,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
