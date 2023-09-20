import 'dart:math';

import 'package:carpool/requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DatabaseMethods {
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // let's try to display profile image in google maps
  // list of photourls
  Image getProfileImage(String photoURL) {
    return Image.network(photoURL, height: 100, width: 100);
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

  Future<int> generateUniqueIdentifier() async {
    // first retrieve all the docIds that exist
    List<String> ids = [];
    QuerySnapshot snap =
        await FirebaseFirestore.instance.collection('trips').get();
    snap.docs.forEach((element) {
      // the idea is to get all ids
      Map<String, dynamic> castedElem = element.data() as Map<String, dynamic>;
      if (castedElem.containsKey('docId')) {
        ids.add(castedElem['docId']);
      }
    });

    // generate a random 4 digit number
    while (true) {
      var rng = new Random();
      var code = rng.nextInt(9000) + 1000;

      if (ids.contains(code.toString())) {
        // continue running
      } else {
        return code;
      }
    }
  }

  // get the id of the trip (this is how we add members!)
  // just need email and dates!
  Future<void> addMembersToTrip(int docId, String location, String email,
      String username, String photoUrl, String d1, String d2, String d3) async {
    // just assuming name is the identifier of the trip
    // yay awesome!
    try {
      // yay so that means we have to set a doc-id!
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('trips')
          // docId is whatever the user inputs
          .where('docId', isEqualTo: docId.toString())
          .get();

      // also want to get a collection of members
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document that matches the query
        String docId = querySnapshot.docs[0].id;
        // will add a member to the trip
        // how to get dates
        final snapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(docId)
            .get();

        // idea is update all emails
        // when
        Map<String, dynamic> info = snapshot.data()!;
        info['emails'].add(email);
        info['names'].add(username);
        info['photoURL'].add(photoUrl);
        info['locations'].add(location);

        for (String date in [d1, d2, d3]) {
          info['dates'].add(date);
        }

        // this way we are not accidently adding address to the locations field
        List<dynamic> locs = [];
        for (dynamic loc in info['locations']) {
          locs.add(loc);
        }
        locs.add(info['address']);
        print('what to order: ' + locs.toString());

        // add ordered locations here again
        // ooh we have to do info['locations'] + address
        orderAddresses(locs, docId);

        await FirebaseFirestore.instance.collection('trips').doc(docId).update({
          'emails': info['emails'],
          'names': info['names'],
          'photoURL': info['photoURL'],
          'dates': info['dates'],
          'locations': info['locations']
        }).then((value) => print("Updated trip info"));

        // also we might regenerate the ordered locations here!
      } else {
        // Handle the case where no document matches the query
        print("No matching trip found.");
      }
    } catch (error) {
      print("Error: $error");
      // Handle any errors that may occur during the Firestore operation
    }
  }

  createNewTrip(
      String destination,
      String location,
      String d1,
      String d2,
      String d3,
      int totalPeople,
      String userEmail,
      String userName,
      String photoURL) async {
    // Create new collection called trips
    // trips (identifiers)
    int docId = await generateUniqueIdentifier();

    // also have a collection here
    // never knowledge never have a field inside a field -> is what collections are for
    await FirebaseFirestore.instance.collection('trips').add({
      // we can do arrays!
      'docId': docId.toString(),
      'address': destination,
      'locations': [location],
      'totalPeople': totalPeople,
      'emails': [userEmail],
      'names': [userName],
      'photoURL': [photoURL],
      'dates': [d1, d2, d3],
      'creatorEmail': userEmail,
      'creatorName': userName,
      'decidedDate': '',
    }).then((value) {
      print('trip added');
      return 'trip added';
    }).catchError((error) {
      print(error);
    });
  }

  // get all the trips
  getTrips(String userEmail) async {
    // for easily querying, we should create new list
    // listens to all documents inside the collection
    return FirebaseFirestore.instance
        .collection('trips')
        // will loop through every document
        .where('emails', arrayContains: userEmail)
        .snapshots();
  }

  addOrderedLocations(List<dynamic> orderedLocations, String id) async {
    // assuming document id so we can add
    await FirebaseFirestore.instance.collection('trips').doc(id).update({
      'orderedLocations': orderedLocations,
    }).then((value) {
      print("yay ordered locations is added!");
    });
  }

  // quick await and notice how we can retrieve any field from here
  Future<List<dynamic>> fetchStringArray(String id, String field) async {
    // example fetchStringArray(id, 'dates')
    List<dynamic> dates = [];

    await FirebaseFirestore.instance.collection('trips').doc(id).get().then(
        (value) => {
              print('{$field}loaded!'),
              print(value[field].toString()),
              dates = value[field]
            });

    return dates;
  }

  // should work perfectly!
  Future<List<dynamic>> fetchLocations(String id) async {
    List<dynamic> geocoded = [];
    List<dynamic> locs = await fetchStringArray(id, 'locations');
    // take locs and run it through geocoding procedure
    for (dynamic loc in locs) {
      List<double> coords = await geocodeAddress(loc);
      geocoded.add(LatLng(coords[0], coords[1]));
    }

    print(geocoded.toString());
    return geocoded;
  }

  Future<void> changeDate(String id, String date) async {
    await FirebaseFirestore.instance.collection('trips').doc(id).update({
      'decidedDate': date,
    }).then(
      (value) {
        print('awesome, updated decided date!');
      },
    );
  }
}
