import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
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

  createNewTrip(String name, String d1, String d2, String d3, int totalPeople,
      String userEmail, String userName, String photoURL) async {
    // Create new collection called trips
    await FirebaseFirestore.instance.collection('trips').add({
      'address': name,
      'd1': d1,
      'd2': d2,
      'd3': d3,
      'totalPeople': totalPeople,
      'creatorEmail': userEmail,
      'creatorName': userName,
      'photoURL': photoURL,
      'members': [userEmail],
      'decidedDate': '',
    }).then((value) {
      print('Trip added');
      return 'trip added';
    }).catchError((error) {
      print(error);
    });
  }

  getTrips(String userEmail) async {
    return FirebaseFirestore.instance
        .collection('trips')
        .where('members', arrayContains: userEmail)
        .snapshots();
  }

}


