import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditScreen extends StatefulWidget {
  final String uAvatarUrl;
  final String username;
  final String bio;
  final String website;
  final String uid;
  EditScreen(
      {this.bio, this.uAvatarUrl, this.username, this.website, this.uid});
  @override
  _EditScreenState createState() => _EditScreenState();
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _EditScreenState extends State<EditScreen> {
  CollectionReference users = firestore.collection("users");
  TextEditingController _textEditingUsername = TextEditingController();
  TextEditingController _textEditingWebsite = TextEditingController();
  TextEditingController _textEditingBio = TextEditingController();
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
      users.doc(widget.uid).get().then((DocumentSnapshot result) {
        print("Done: $value");
        users.doc(widget.uid).update({
          'username': _textEditingUsername.text,
          'website': _textEditingWebsite.text,
          'bio': _textEditingBio.text,
          'uavatarUrl': value
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
    });
  }

  Future<void> uploadFirebase() async {
    users.doc(widget.uid).get().then((DocumentSnapshot result) {
      users.doc(widget.uid).update({
        'username': _textEditingUsername.text,
        'website': _textEditingWebsite.text,
        'bio': _textEditingBio.text,
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

  @override
  Widget build(BuildContext context) {
    String defaultFontFamily = 'Roboto-Light.ttf';
    double defaultFontSize = 14;
    double defaultIconSize = 17;

    _textEditingUsername.text = widget.username;
    _textEditingWebsite.text = widget.website;
    _textEditingBio.text = widget.bio;

    _showDialogAvatar(String avatarUrl) async {
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
        body: ListView(
          children: [
            Center(
              heightFactor: 1.5,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 65.0,
                    backgroundImage: _image != null
                        ? FileImage(_image)
                        : widget.uAvatarUrl == null
                            ? AssetImage('assets/images/avatar.png')
                            : NetworkImage(widget.uAvatarUrl),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => _showDialogAvatar(widget.uAvatarUrl),
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
                    controller: _textEditingUsername,
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
                      hintText: "Username",
                      labelText: "Username",
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
                    controller: _textEditingWebsite,
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
                      hintText: "Website",
                      labelText: "Website",
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
                    controller: _textEditingBio,
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
                      hintText: "Bio",
                      labelText: "Bio",
                      labelStyle: TextStyle(
                          color: Color(0xFF666666),
                          fontFamily: defaultFontFamily,
                          fontSize: defaultFontSize),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Switch to Professional Account",
                    style: TextStyle(color: Colors.blue[700], fontSize: 21),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Personal Information Settings",
                    style: TextStyle(color: Colors.blue[700], fontSize: 21),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
