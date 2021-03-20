import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_udacoding_week3/models/model_feed.dart';
import 'package:flutter_udacoding_week3/screen/detail_screnn.dart';
import 'package:flutter_udacoding_week3/screen/favorite_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedScreen extends StatefulWidget {
  final String uid;
  FeedScreen({this.uid});
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _FeedScreenState extends State<FeedScreen> {
  CollectionReference feed = firestore.collection("feed");
  CollectionReference users = firestore.collection("users");
  CollectionReference favorite = firestore.collection("favorite");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.pink,
        title: Text(
          "Recipe App",
          style: GoogleFonts.pacifico(fontSize: 29),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FavoriteScreen(
                            uid: widget.uid,
                          )));
            },
            child: Icon(
              Icons.favorite_border,
              size: 35,
            ),
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
          child: StreamBuilder<QuerySnapshot>(
              stream: feed.snapshots(),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  EasyLoading.dismiss();
                  List<ModelFeed> feed = snapshot.data.docs
                      .map((e) => ModelFeed.fromMap(e.data()))
                      .toList();
                  List<String> docId =
                      snapshot.data.docs.map((e) => e.id).toList();
                  print(feed[0].title);
                  return ListView.builder(
                      itemCount: feed.length,
                      itemBuilder: (_, i) {
                        print('document: ' + docId[i]);
                        return StreamBuilder<DocumentSnapshot>(
                            stream: users.doc(feed[i].uid).snapshots(),
                            builder: (_, snapshot) {
                              if (snapshot.hasData) {
                                EasyLoading.dismiss();
                                return itemCard(
                                    snapshot.data.data()['username'],
                                    feed[i].uid,
                                    snapshot.data.data()['uavatarUrl'],
                                    feed[i].imageUrl,
                                    feed[i].title,
                                    feed[i].desc,
                                    feed[i].date,
                                    docId[i],
                                    feed[i].favorite);
                              } else {
                                return Container();
                              }
                            });
                      });
                } else {
                  EasyLoading.show(status: 'loading...');
                  return Container();
                }
              })),
    );
  }

  Widget itemCard(
      String uName,
      String uId,
      String uAvatarUrl,
      String imageUrl,
      String title,
      String desc,
      String date,
      String docId,
      String favoriteBool) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DetailScreen(
                    docId: docId,
                  ))),
      child: Card(
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
                    backgroundColor: Colors.cyan,
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
                  GestureDetector(
                    onTap: () {
                      EasyLoading.show(status: 'loading...');
                      if (favoriteBool == "true") {
                        favorite.doc(docId).delete().then((result) {
                          feed
                              .doc(docId)
                              .update({'favorite': null}).then((result) {
                            print("sukses!!! favorite delete");
                            EasyLoading.showSuccess("Delete Favorite!!!");
                          }).catchError((error) {
                            var errorCode = error.code;
                            var errorMessage = error.message;
                            // [START_EXCLUDE]
                            if (errorCode == 'auth/weak-password') {
                            } else if (errorMessage ==
                                "The email address is already in use by another account.") {
                              EasyLoading.showError("Terjadi Kesalahan!");
                              //alert(errorMessage);
                            } else {
                              print(error);
                            }
                          });
                        });
                      } else {
                        favorite.doc(docId).set({
                          'FeedId': docId,
                          'uid': uId,
                          'username': uName,
                          'uavatarUrl': uAvatarUrl,
                          'desc': desc,
                          'title': title,
                          'imageUrl': imageUrl,
                        }).then((result) {
                          print("sukses!!!");
                          feed
                              .doc(docId)
                              .update({'favorite': "true"}).then((result) {
                            print("sukses!!! favorite");
                            EasyLoading.showSuccess("Sukses!!!");
                          }).catchError((error) {
                            var errorCode = error.code;
                            var errorMessage = error.message;
                            // [START_EXCLUDE]
                            if (errorCode == 'auth/weak-password') {
                            } else if (errorMessage ==
                                "The email address is already in use by another account.") {
                              EasyLoading.showError("Terjadi Kesalahan!");
                              //alert(errorMessage);
                            } else {
                              print(error);
                            }
                          });
                        });
                      }
                    },
                    child: Icon(
                      favoriteBool == null
                          ? Icons.favorite_border
                          : Icons.favorite,
                      size: 35,
                    ),
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
              Text(title ?? "Blank",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              /* Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('by: ' + uName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                      Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Text(date,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 17)),
                      ),
                    ],
                  ),
                ), */
            ],
          ),
        ),
      ),
    );
  }
}
