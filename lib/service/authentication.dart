import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthenticationService {
  static final AuthenticationService authUtil = AuthenticationService._createInstance();
  AuthenticationService._createInstance();

  final _fbDBUtil = FirebaseDatabase.instance.reference();

  Future createIdGenerator() async {
    var idGenTbl = _fbDBUtil.child("id_generator");
    await idGenTbl.child("key_val").set({
          'sequence': 1,
          'version' : 0,
        }
    );
    idGenTbl.push();
  }

  Future updateIdGenerator(int nextVal, int version) async {
    var idGenTbl = _fbDBUtil.child("id_generator");
    await idGenTbl.child("key_val").update({
          'sequence': nextVal,
          'version' : version,
        }
    );
    idGenTbl.push();
  }

  Future createRatingIdGenerator() async {
    var idGenTbl = _fbDBUtil.child("rating_id_gen");
    await idGenTbl.child("key_val").set({
      'sequence': 1,
      'version' : 0,
    }
    );
    idGenTbl.push();
  }

  Future updateRatingIdGenerator(int nextVal, int version) async {
    var idGenTbl = _fbDBUtil.child("rating_id_gen");
    await idGenTbl.child("key_val").update({
      'sequence': nextVal,
      'version' : version,
    }
    );
    idGenTbl.push();
  }



  Future<DataSnapshot> getIdGen() async {
    /*await _fbDBUtil.once().then((snapshot) {
      print("Data: $snapshot.value!");
      return snapshot!;
    });*/

    Query needsSnapshot = await _fbDBUtil.child("key_val");
        //.orderByKey();

    print(needsSnapshot); // to debug and see if data is returned

    /*List<Need> needs;

    Map<dynamic, dynamic> values = needsSnapshot.value;
    values.forEach((key, values) {
      needs.add(values);
    });*/

    return needsSnapshot.get();
  }

  Future<void> createUserRegistration(String name, String email, String mobileNo, String username, String password) async {
    try {
      int? val = 0;
      final dbRef = _fbDBUtil.child('id_generator').child("key_val").child("sequence");
      //await dbRef.once().then((value) => val = value.snapshot.value as int?);

      /*if (val!>0) {
        int sequenceVal = val!+1;
        updateIdGenerator(sequenceVal, val!);
      } else {
        createIdGenerator();
        val = 1;
      }*/

      /*var userTbl = _fbDBUtil.child("user");
      await userTbl.child(val!.toString()).set(
          {
            'name': name,
            'email': email,
            'mobileNo': mobileNo,
            'username': username,
            'password': password
          }
      );
      userTbl.push();*/

      final db = _fbDBUtil.child('user').child("email");
      //await db.once().then((value) => val = value.snapshot.value as int?
        ///*print(value.snapshot.value.toString())*/);

      /*late bool? exists = false;
      await _fbDBUtil.child('user')
          .orderByChild('email')
          .equalTo("abc@gmail.com")
          .onChildAdded.listen((DatabaseEvent event) {
        exists = event.snapshot.key?.isNotEmpty;
        print('abc@gmail.com:${event.snapshot.key}');
      }).toString();*/

    } catch (error, stacktrace) {
      print("Unhandled exception occurred during firebase invoke : error => $error stackTrace => $stacktrace");
    }

  }

  /*Future<void> addRatingAndReview(String name, String email, String mobileNo, String username, String password) async {
    await Firebase.initializeApp();
    try {
      int? val = 0;
      final dbRef = _fbDBUtil.child('id_generator').child("key_val").child("sequence");
      //await dbRef.once().then((value) => val = value.snapshot.value as int?);

      *//*if (val!>0) {
        int sequenceVal = val!+1;
        updateIdGenerator(sequenceVal, val!);
      } else {
        createIdGenerator();
        val = 1;
      }*//*

      var userTbl = _fbDBUtil.child("user");
      await userTbl.child(val!.toString()).set(
          {
            'name': name,
            'email': email,
            'mobileNo': mobileNo,
            'username': username,
            'password': password
          }
      );
      userTbl.push();
    } catch (error, stacktrace) {
      print("Unhandled exception occurred during firebase invoke : error => $error stackTrace => $stacktrace");
    }
  }*/
}