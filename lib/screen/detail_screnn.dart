import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_udacoding_week3/models/model_feed.dart';
import 'package:flutter_udacoding_week3/screen/edit_post.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatefulWidget {
  final String docId;
  final String uid;
  DetailScreen({this.docId, this.uid});
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _DetailScreenState extends State<DetailScreen> {
  CollectionReference users = firestore.collection("users");
  CollectionReference feed = firestore.collection("feed");
  CollectionReference favorite = firestore.collection("favorite");

  String _selectedItem = 'Edit';
  List _options = ['Edit', 'Delete'];

  _showDialogDelete(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              "Delete Post",
              textAlign: TextAlign.center,
            ),
            titleTextStyle: TextStyle(
              fontSize: 25.0,
              color: Colors.black,
            ),
            content: Container(
                height: 35,
                child: Center(
                  child: Text(
                    "Yakin ingin menghapus ??",
                    style: TextStyle(fontSize: 25),
                  ),
                )),
            actions: <Widget>[
              FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              FlatButton(
                  child: const Text('DELETE'),
                  onPressed: () {
                    EasyLoading.show(status: 'loading...');
                    feed.doc(widget.docId).delete().then((value) {
                      EasyLoading.dismiss();
                      int count = 2;
                      Navigator.of(context).popUntil((_) => count-- <= 0);
                    });
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print('detail doc: ' + widget.docId);
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Recipe", style: GoogleFonts.pacifico(fontSize: 25)),
        actions: [
          widget.uid != null
              ? PopupMenuButton(
                  itemBuilder: (BuildContext bc) {
                    return _options
                        .map((day) => PopupMenuItem(
                              child: Text(day),
                              value: day,
                            ))
                        .toList();
                  },
                  onSelected: (value) {
                    if (value == 'Edit')
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditPostScreen(
                                    docFeedId: widget.docId,
                                  )));
                    else
                      _showDialogDelete(context);
                  },
                )
              : Container(),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: feed.doc(widget.docId).snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              EasyLoading.dismiss();
              ModelFeed feed = ModelFeed.fromMap(snapshot.data.data());
              /* List<String> docId =
                      snapshot.data.docs.map((e) => e.id).toList();
                  print(feed[0].title); */
              return ListView.builder(
                  itemCount: 1,
                  itemBuilder: (_, i) {
                    return StreamBuilder<DocumentSnapshot>(
                        stream: users.doc(feed.uid).snapshots(),
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            EasyLoading.dismiss();
                            return itemCard(
                                snapshot.data.data()['username'],
                                feed.uid,
                                snapshot.data.data()['uavatarUrl'],
                                feed.imageUrl,
                                feed.title,
                                feed.desc,
                                feed.date,
                                widget.docId,
                                feed.favorite);
                          } else {
                            return Container();
                          }
                        });
                  });
            } else {
              EasyLoading.show(status: 'loading...');
              return Container();
            }
          }),
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
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('by: ' + uName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 17)),
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text(date,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 17)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(desc,
                  // overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
