import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_udacoding_week3/screen/recipe_page.dart';
import 'package:flutter_udacoding_week3/services/sign_in_google.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String uid;
  String username;
  @override
  Widget build(BuildContext context) {
    print(AuthProviderService.instance.user);
    if (AuthProviderService.instance.user != null) {
      var user = AuthProviderService.instance.user;
      uid = user.uid;
      username = user.displayName;
    }
    //firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');
    return Scaffold(
      body: Center(
          child: AuthProviderService.instance.user == null
              ? SignInButton(
                  buttonType: ButtonType.google,
                  onPressed: () async {
                    EasyLoading.show(status: 'loading...');
                    await AuthProviderService.instance.signIn();
                    var user = AuthProviderService.instance.user;
                    uid = user.uid;
                    username = user.displayName;
                    users.doc(uid).set({
                      'id': uid,
                      'username': user.displayName,
                      'email': user.email,
                      'uavatarUrl': user.photoURL,
                      'bio': null,
                      'website': null,
                      'nomor-hp': user.phoneNumber,
                    }).then((result) {
                      print("sukses!!!");
                      EasyLoading.dismiss();
                      setState(() {
                        print(uid);
                      });
                    });
                  },
                )
              : RecipePage(
                  uid: uid,
                  username: username,
                )),
    );
  }
}
