import 'package:carpool/AppColors.dart';
import 'package:carpool/google_sign_in.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CarpoolHome extends StatefulWidget {
  CarpoolHome({Key? key}) : super(key: key);

  @override
  State<CarpoolHome> createState() => _CarpoolHomeState();
}

class _CarpoolHomeState extends State<CarpoolHome> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Create Trip'),
        icon: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Leading (Profile Picture from Google Auth)
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.containerShadowColor,
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.network(
              firebaseAuth.currentUser!.photoURL!,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.logout();
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.containerShadowColor,
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                FeatherIcons.logOut,
                color: AppColors.darkTextColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Text Field in Capsule Rounded Shape
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            // List of Trips
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(16),
                borderRadius: BorderRadius.circular(30),
                // Shadow
                boxShadow: [
                  BoxShadow(
                    color: AppColors.containerShadowColor,
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  // Trip Title
                  Row(
                    children: [
                      Text(
                        'Tambark Creek Trip',
                        style: TextStyle(
                          color: AppColors.darkTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      // Disclose Icon
                      const Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.deepPurpleColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      // Font Awesome Icon
                      FaIcon(
                        FontAwesomeIcons.locationDot,
                        color: AppColors.lightBlueColor,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      // Trip Location
                      Text(
                        'Tambark Creek Park',
                        style: TextStyle(
                          color: AppColors.lightBlueColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Font Awesome Icon
                      FaIcon(
                        FontAwesomeIcons.calendarAlt,
                        color: AppColors.lightBlueColor,
                        size: 16,
                      ),

                      SizedBox(width: 8),

                      // Trip Date
                      Text(
                        'June 12, 2021',
                        style: TextStyle(
                          color: AppColors.lightBlueColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // Trip Total People Count
                  Row(
                    children: [
                      // Font Awesome Icon
                      FaIcon(
                        FontAwesomeIcons.userGroup,
                        color: AppColors.lightBlueColor,
                        size: 16,
                      ),

                      SizedBox(width: 8),

                      // Trip Date
                      Text(
                        '5',
                        style: TextStyle(
                          color: AppColors.lightBlueColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slightlyDarkerBGColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: 105,
                    child: Row(
                      children: [
                        // Font Awesome Icon
                        FaIcon(
                          FontAwesomeIcons.share,
                          color: AppColors.darkTextColor,
                          size: 16,
                        ),

                        SizedBox(width: 8),

                        // Trip Date
                        Text(
                          'Share',
                          style: TextStyle(
                            color: AppColors.darkTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
