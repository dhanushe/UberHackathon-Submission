import 'package:carpool/AppColors.dart';
import 'package:carpool/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:provider/provider.dart';
import 'package:carpool/gmaps.dart';

import 'google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        title: 'Carpoolz',
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          useMaterial3: true,
        ),
        home: Gmaps(),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBGColor,
            Color.fromARGB(255, 202, 205, 208),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Title
              Text(
                'Carpoolz',
                style: TextStyle(
                  color: AppColors.darkTextColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                child: Center(
                  child: UnDraw(
                    width: 250,
                    height: 250,
                    color: AppColors.lightBlueColor,
                    illustration: UnDrawIllustration.people,
                    placeholder: const Text(
                      "Illustration is loading...",
                    ),
                    errorWidget: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ), //optional, default is the Text('Could not load illustration!').
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Text(
              //   'Login',
              //   style: TextStyle(
              //     color: AppColors.darkTextColor,
              //     fontSize: 30,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Button for Sign In
              Container(
                margin: const EdgeInsets.only(top: 20),
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    final provider = Provider.of<GoogleSignInProvider>(context,
                        listen: false);
                    provider.googleLogin();
                  },
                  child: Row(
                    children: [
                      // Google Font Awesome Icon
                      FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                      ),
                      Spacer(),
                      Text(
                        'Sign In',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                  // Set Border Radius
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
