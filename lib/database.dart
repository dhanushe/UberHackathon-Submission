import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// now that this works let's just create a database methods object
class DatabaseMethods {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // let's try to display profile image in google maps
  Image getProfileImage() {
    return Image.network(_firebaseAuth.currentUser!.photoURL!,
        height: 100, width: 100);
  }

  uploadUserInfo(userMap) async {
    print('calling uploadUserInfo');

    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userMap['email'])
        .get()
        .catchError((error) {
      print('the error is: $error');
    }).then((data) async {
      if (data.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userMap['email'])
            .set(userMap)
            .then((value) {
          print('User added');
          return 'user added';
        }).catchError((error) {
          print(error);
        });
      } else {
        print('User already exists');
        return 'user already exists';
      }
    }).catchError((error) {
      print('the error after: $error');
    });
  }

  // fetch profile pics from GoogleAuth
}
