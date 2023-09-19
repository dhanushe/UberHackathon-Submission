import 'package:carpool/AppColors.dart';
import 'package:carpool/carpoolcard.dart';
import 'package:carpool/database.dart';
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
  Stream? tripStream;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    super.initState();
    getTripsInfo();
  }

  getTripsInfo() async {
    databaseMethods.getTrips(firebaseAuth.currentUser!.email!).then((val) {
      setState(() {
        tripStream = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Scaffold.of(context).showBottomSheet<void>(
            (BuildContext context) {
              return NewTripModal();
            },
          );
        },
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
        child: SingleChildScrollView(
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
              _buildTripList(),
              // CarpoolCard(),
              // CarpoolCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripList() {
    return StreamBuilder(
      stream: tripStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: CarpoolCard(
                      address: snapshot.data.docs[index]['address'],
                      totalPeopleCount: snapshot.data.docs[index]
                          ['totalPeople'],
                      date1: snapshot.data.docs[index]['d1'],
                      date2: snapshot.data.docs[index]['d2'],
                      date3: snapshot.data.docs[index]['d3'],
                      undecidedDate: snapshot.data.docs[index]['decidedDate'],
                      // tripName: snapshot.data.docs[index]['tripName'],
                      // tripDate1: snapshot.data.docs[index]['tripDate1'],
                      // tripDate2: snapshot.data.docs[index]['tripDate2'],
                      // tripDate3: snapshot.data.docs[index]['tripDate3'],
                      // tripLocation: snapshot.data.docs[index]['tripLocation'],
                      // tripMembers: snapshot.data.docs[index]['tripMembers'],
                      // tripCreator: snapshot.data.docs[index]['tripCreator'],
                      // tripCreatorName:
                      //     snapshot.data.docs[index]['tripCreatorName'],
                      // tripCreatorPhoto:
                      //     snapshot.data.docs[index]['tripCreatorPhoto'],
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }
}

class NewTripModal extends StatefulWidget {
  const NewTripModal({
    super.key,
  });

  @override
  State<NewTripModal> createState() => _NewTripModalState();
}

class _NewTripModalState extends State<NewTripModal> {
  int totalPeople = 5;
  DateTime? selectedDate1;
  DateTime? selectedDate2;
  DateTime? selectedDate3;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController tripNameController = new TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.865,
      decoration: BoxDecoration(
        color: AppColors.darkTextColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // text
            Text(
              'Create Trip',
              style: TextStyle(
                color: AppColors.lightTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),

            // Label that says select possible dates for trip
            // Text(
            //   'Select Possible Dates',
            //   style: TextStyle(
            //     color: AppColors.lightTextColor.withOpacity(0.6),
            //     fontSize: 16,
            //   ),
            // ),

            // Date Selection
            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2024),
                );
                if (pickedDate != null && pickedDate != selectedDate1)
                  setState(() {
                    selectedDate1 = pickedDate;
                  });
              },
              child: FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.lightTextColor,
                      width: 1,
                    ),
                  ),
                  child: Container(
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendar,
                          color: AppColors.lightTextColor,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          (selectedDate1 == null)
                              ? 'Select Best Date'
                              // Format the Selected String to MONTH DAY YEAR
                              : '${selectedDate1!.month}/${selectedDate1!.day} ${selectedDate1!.year}',
                          style: TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2024),
                );
                if (pickedDate != null && pickedDate != selectedDate2)
                  setState(() {
                    selectedDate2 = pickedDate;
                  });
              },
              child: FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.lightTextColor,
                      width: 1,
                    ),
                  ),
                  child: Container(
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendar,
                          color: AppColors.lightTextColor,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          (selectedDate2 == null)
                              ? 'Select 2nd Best Date'
                              // Format the Selected String to MONTH DAY YEAR
                              : '${selectedDate2!.month}/${selectedDate2!.day} ${selectedDate2!.year}',
                          style: TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2024),
                );
                if (pickedDate != null && pickedDate != selectedDate3)
                  setState(() {
                    selectedDate3 = pickedDate;
                  });
              },
              child: FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.lightTextColor,
                      width: 1,
                    ),
                  ),
                  child: Container(
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendar,
                          color: AppColors.lightTextColor,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          (selectedDate3 == null)
                              ? 'Select 3rd Best Date'
                              // Format the Selected String to MONTH DAY YEAR
                              : '${selectedDate3!.month}/${selectedDate3!.day} ${selectedDate3!.year}',
                          style: TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Location Selection
            FractionallySizedBox(
              widthFactor: 0.75,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.lightTextColor,
                    width: 1,
                  ),
                ),
                child: Container(
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.mapMarkerAlt,
                        color: AppColors.lightTextColor,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      // TextField to Enter Location
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 16,
                          ),
                          controller: tripNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter Location',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // Text(
                      //   'Tambark Creek Park',
                      //   style: TextStyle(
                      //     color: AppColors.lightTextColor,
                      //     fontSize: 16,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // Carpool Limit (Slider)
            FractionallySizedBox(
              widthFactor: 0.75,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.lightTextColor,
                    width: 1,
                  ),
                ),
                child: Container(
                  child: Row(
                    children: [
                      Text(
                        'Total Members',
                        style: TextStyle(
                          color: AppColors.lightTextColor,
                          fontSize: 16,
                        ),
                      ),
                      // Slider
                      Expanded(
                        child: Slider(
                          value: totalPeople.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 10,
                          label: totalPeople.toString(),
                          onChanged: (double value) {
                            setState(() {
                              totalPeople = value.toInt();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Create Trip Button
            GestureDetector(
              onTap: () {
                databaseMethods.createNewTrip(
                  tripNameController.text,
                  // in the format MONTH/DAY/YEAR
                  selectedDate1!.month.toString() +
                      '/' +
                      selectedDate1!.day.toString() +
                      '/' +
                      selectedDate1!.year.toString(),
                  selectedDate2!.month.toString() +
                      // in the format MONTH/DAY/YEAR
                      '/' +
                      selectedDate2!.day.toString() +
                      '/' +
                      selectedDate2!.year.toString(),
                  selectedDate3!.month.toString() +
                      // in the format MONTH/DAY/YEAR
                      '/' +
                      selectedDate3!.day.toString() +
                      '/' +
                      selectedDate3!.year.toString(),
                  totalPeople,
                  firebaseAuth.currentUser!.email!,
                  firebaseAuth.currentUser!.displayName!,
                  firebaseAuth.currentUser!.photoURL!,
                );
                Navigator.pop(context);
              },
              child: FractionallySizedBox(
                widthFactor: 0.65,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightTextColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    child: Center(
                      child: Text(
                        'Create Trip',
                        style: TextStyle(
                          color: AppColors.darkTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
