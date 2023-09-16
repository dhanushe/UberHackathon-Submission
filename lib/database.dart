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
}