import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/domain/entities/account.dart';
import 'package:coworking/domain/entities/meeting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class DatabaseMeeting {
  final _firestore = FirebaseFirestore.instance;

  Future addMeeting(Meeting meeting) async {
    String retVal = "error";
    List<String?> members = [];
    List<String?> tokens = [];
    try {
      members.add(Account.currentAccount?.id);
      tokens.add(Account.currentAccount?.notifyToken);
      await _firestore.collection("meetings").add({
        'place': meeting.place.trim(),
        'description': meeting.description,
        'author': meeting.author.id,
        'members': members,
        'tokens': tokens,
        'dateCompleted': meeting.dateCompleted,
        'notify': false,
        // 'pinId': meeting.pin
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future editMeeting(Meeting meeting) async {
    String retVal = "error";
    try {
      FirebaseFirestore.instance.collection("meetings").doc(meeting.id).update(
        {
          "place": meeting.place,
          "description": meeting.description,
          "dateCompleted": meeting.dateCompleted
        },
      );
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future changeInfoNotify(Meeting meeting) async {
    String retVal = "error";
    try {
      FirebaseFirestore.instance.collection("meetings").doc(meeting.id).update(
        {
          "dateCompleted": meeting.dateCompleted,
        },
      );
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future timeNotify(Meeting meeting) async {
    String retVal = "error";
    if (meeting.notify) {
      meeting.notify = false;
    } else {
      meeting.notify = true;
    }
    print(meeting.notify);
    try {
      FirebaseFirestore.instance.collection("meetings").doc(meeting.id).update(
        {"notify": meeting.notify},
      );
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<bool> isMeetingOwner(Meeting meeting) {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("meetings").doc(meeting.id);
    return docRef.get().then((datasnapshot) {
      print(datasnapshot['author'].toString());
      print(datasnapshot['author'].toString() == Account.currentAccount!.id);
      if (datasnapshot['author'].toString() == Account.currentAccount!.id) {
        return true;
      } else {
        return false;
      }
    });
  }

  static void deleteMeeting(Meeting meeting) {
    FirebaseFirestore.instance.collection("meetings").doc(meeting.id).delete();
  }

  static Stream<List<Meeting>> meetingsOfUser(
      Account account, BuildContext context) {
    return FirebaseFirestore.instance
        .collection("meetings")
        .where("members", arrayContains: account.id)
        //сначала выводим ближайшие встречи
        .orderBy("dateCompleted", descending: false)
        .snapshots()
        .map((querySnapshot) {
      List<Meeting> meetings = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic>? meetingMap =
            documentSnapshot.data() as Map<String, dynamic>?;
        Meeting meeting = Meeting.fromMap(documentSnapshot.id, meetingMap!);
        // meeting.pin = await getPinByID(meetingMap["pinID"], context);
        meetings.add(meeting);
      }
      return meetings;
    });
  }

  Future<String> joinMeeting(String meetingId) async {
    String retVal = "error";
    List<String?> members = [];
    List<String?> tokens = [];
    try {
      members.add(Account.currentAccount?.id);
      tokens.add(Account.currentAccount?.notifyToken);
      await _firestore.collection("meetings").doc(meetingId).update({
        'members': FieldValue.arrayUnion(members),
        'tokens': FieldValue.arrayUnion(tokens),
      });
      retVal = "success";
    } on PlatformException catch (e) {
      retVal = "Убедитесь, что вы получили верный id встречи!";
      print(e);
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  static void leaveMeeting(String meetingId) async {
    List<String?> members = [];
    List<String?> tokens = [];
    try {
      members.add(Account.currentAccount?.id);
      tokens.add(Account.currentAccount?.notifyToken);
      await FirebaseFirestore.instance
          .collection("meetings")
          .doc(meetingId)
          .update({
        'members': FieldValue.arrayRemove(members),
        'tokens': FieldValue.arrayRemove(tokens),
      });
    } catch (e) {
      print(e);
    }
  }
}
