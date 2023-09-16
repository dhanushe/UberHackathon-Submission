import 'dart:math';

import 'package:carpool/database.dart';
import 'package:carpool/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'carpool_home.dart';

// client ID
// 60859437998-ejs99akhftosi7oakfkivrp62630c11q.apps.googleusercontent.com

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseMethods databaseMethods = new DatabaseMethods();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            print('uploading user info to database...');
            Map<String, dynamic> userInfoMap = {
              'name': firebaseAuth.currentUser!.displayName!,
              'email': firebaseAuth.currentUser!.email!,
              'id': Random().nextInt(1000) + 1000,
            };
            databaseMethods.uploadUserInfo(userInfoMap);
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something Went Wrong!'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapshot.hasData ? CarpoolHome() : const AuthScreen();
        }),
      ),
    );
  }
}
