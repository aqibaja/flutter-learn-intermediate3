import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditPostScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String desc;
  final String docFeedId;

  EditPostScreen({this.imageUrl, this.title, this.desc, this.docFeedId});
  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _EditPostScreenState extends State<EditPostScreen> {
  CollectionReference feed = firestore.collection("feed");
  TextEditingController _textEditingTitle = TextEditingController();
  TextEditingController _textEditingDesc = TextEditingController();
  String date = DateFormat("yyyy-MM-dd").format(DateTime.now());

  final _formKey = GlobalKey<FormState>(); // key vallidation form
  File _image; //variabel untuk menyimpan image sementara
  final picker = ImagePicker(); //objeck picker untuk mengambil image
  String filename;

  //method menyambil image di camera
  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      filename = basename(_image.path);
    } else {
      print('No image selected.');
    }
  }

  //method menyambil image di galery
  Future getImageGalery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      filename = basename(_image.path);
    } else {
      print('No image selected.');
    }
  }

  Future<void> uploadFirebaseWithImage() async {
    print("upload image");
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(filename);
    firebase_storage.UploadTask uploadTask = ref.putFile(_image);

    /* var urlImage = await uploadTask.whenComplete(() => ref.getDownloadURL());
    //String url = ;
    print('image url -> ${urlImage.storage.bucket.}'); */
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then((value) {
      feed.doc(widget.docFeedId).update({
        'title': _textEditingTitle.text,
        'desc': _textEditingDesc.text,
        'date': date,
        'imageUrl': value
      }).then((result) {
        print("sukses!!!");
        EasyLoading.dismiss();
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

  Future<void> uploadFirebase() async {
    feed.doc(widget.docFeedId).update({
      'title': _textEditingTitle.text,
      'desc': _textEditingDesc.text,
      'date': date,
    }).then((result) {
      print("sukses!!!");
      EasyLoading.dismiss();
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
  }

  _showDialogAvatar(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              "Profile Photo",
              textAlign: TextAlign.center,
            ),
            titleTextStyle: TextStyle(
              fontSize: 25.0,
              color: Colors.black,
            ),
            content: Container(
              height: 100,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () => getImageGalery().then((value) {
                            Navigator.pop(context);
                            setState(() {});
                          }),
                      child: Text(
                        "Galery",
                        style: TextStyle(fontSize: 25),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                      onPressed: () => getImageCamera().then((value) {
                            Navigator.pop(context);
                            setState(() {});
                          }),
                      child: Text(
                        "Camera",
                        style: TextStyle(fontSize: 25),
                      ))
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String defaultFontFamily = 'Roboto-Light.ttf';
    double defaultFontSize = 14;
    //double defaultIconSize = 17;

    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              size: 35,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.check_outlined,
                  size: 35,
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    EasyLoading.show(status: 'loading...');
                    _image != null
                        ? uploadFirebaseWithImage().then((value) {
                            EasyLoading.showSuccess("Sukses!");
                            Navigator.pop(context);
                          })
                        : uploadFirebase().then((value) {
                            EasyLoading.showSuccess("Sukses!");
                            Navigator.pop(context);
                          });
                  }
                })
          ],
        ),
        body: Container(
            child: StreamBuilder<DocumentSnapshot>(
                stream: feed.doc(widget.docFeedId).snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    EasyLoading.dismiss();
                    return listView(
                        defaultFontFamily,
                        defaultFontSize,
                        snapshot.data.data()['imageUrl'],
                        snapshot.data.data()['title'],
                        snapshot.data.data()['desc'],
                        context);
                  } else {
                    EasyLoading.show(status: 'loading...');
                    return Container();
                  }
                })),
      ),
    );
  }

  Widget listView(String defaultFontFamily, double defaultFontSize,
      String imageUrl, String title, String desc, BuildContext context) {
    _textEditingTitle.text = title;
    _textEditingDesc.text = desc;
    return ListView(
      children: [
        Center(
          heightFactor: 1.5,
          child: Column(
            children: [
              Container(
                child: _image != null
                    ? Image.file(
                        _image,
                        fit: BoxFit.fill,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.fill,
                      ),
                height: 200,
                width: 300,
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () => _showDialogAvatar(context),
                child: Text(
                  "Change Profile Photo",
                  style: TextStyle(color: Colors.blue[700], fontSize: 21),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Maaf data tidak boleh kosong';
                  }
                  return null;
                },
                controller: _textEditingTitle,
                showCursor: true,
                decoration: InputDecoration(
                  /* border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                            width: 2,
                            style: BorderStyle.solid,
                            color: Colors.pink),
                      ), */
                  hintStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize),
                  hintText: "Title",
                  labelText: "Title",
                  labelStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Maaf data tidak boleh kosong';
                  }
                  return null;
                },
                controller: _textEditingDesc,
                showCursor: true,
                maxLines: 5,
                decoration: InputDecoration(
                  /* border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                            width: 2,
                            style: BorderStyle.solid,
                            color: Colors.pink),
                      ), */
                  hintStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize),
                  hintText: "Description",
                  labelText: "Description",
                  labelStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
