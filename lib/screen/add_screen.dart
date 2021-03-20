import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddScreen extends StatefulWidget {
  final String uid;
  final String uavatarUrl;
  AddScreen({this.uid, this.uavatarUrl});
  @override
  _AddScreenState createState() => _AddScreenState();
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _AddScreenState extends State<AddScreen> {
  CollectionReference feed = firestore.collection("feed");
  CollectionReference users = firestore.collection("users");
  File _image; //variabel untuk menyimpan image sementara
  final picker = ImagePicker(); //objeck picker untuk mengambil image
  String filename;
  String date = DateFormat("yyyy-MM-dd").format(DateTime.now());

  //method menyambil image di camera
  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        filename = basename(_image.path);
      } else {
        print('No image selected.');
      }
    });
  }

  //method menyambil image di galery
  Future getImageGalery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        filename = basename(_image.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadFirebase(String desc, String title) async {
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(filename);
    firebase_storage.UploadTask uploadTask = ref.putFile(_image);

    /* var urlImage = await uploadTask.whenComplete(() => ref.getDownloadURL());
    //String url = ;
    print('image url -> ${urlImage.storage.bucket.}'); */
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then((value) {
      print("Done: $value");
      users.doc(widget.uid).get().then((DocumentSnapshot result) {
        feed.add({
          'uid': widget.uid,
          'username': result['username'],
          'desc': desc,
          'title': title,
          'imageUrl': value,
          'uavatarUrl': result['uavatarUrl'],
          'date': date,
          'favorite': null
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
            EasyLoading.showError("Email sudah digunakan!");
            //alert(errorMessage);
          } else {
            print(error);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>(); //key
    TextEditingController _descControler = TextEditingController();
    TextEditingController _titleControler = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.pink,
        title: Text(
          "New Post",
          style: GoogleFonts.lato(fontSize: 29),
        ),
        actions: [
          Icon(
            Icons.save_alt,
            size: 35,
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                image(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () => getImageGalery(),
                        child: Text(
                          "Galery",
                          style: TextStyle(fontSize: 25),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () => getImageCamera(),
                        child: Text(
                          "Camera",
                          style: TextStyle(fontSize: 25),
                        )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Maaf data tidak boleh kosong';
                    } else if (_image == null) {
                      return 'Maaf gambar belum dipilih';
                    }
                    return null;
                  },
                  controller: _titleControler,
                  maxLines: 1,
                  decoration: InputDecoration(
                      labelText: 'Title',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Maaf data tidak boleh kosong';
                    } else if (_image == null) {
                      return 'Maaf gambar belum dipilih';
                    }
                    return null;
                  },
                  controller: _descControler,
                  maxLines: 5,
                  decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                SizedBox(
                  height: 5,
                ),
                RaisedButton(
                    color: Colors.blueGrey,
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        print(_descControler.text);
                        EasyLoading.show(status: 'loading...');
                        uploadFirebase(
                                _descControler.text, _titleControler.text)
                            .then((value) {
                          _descControler.text = "";
                          _image = null;
                          EasyLoading.showSuccess("Sukses!");
                          setState(() {});
                        });
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container image() {
    return (_image == null)
        ? Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1)),
            child: Image.asset(
              "assets/images/no-image.png",
              fit: BoxFit.fill,
            ),
          )
        : Container(
            height: 300,
            width: double.infinity,
            child: Image.file(
              _image,
              fit: BoxFit.fill,
            ),
          );
  }
}
