import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/domain/entities/account.dart';
import 'package:coworking/domain/entities/meeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatabaseMeeting {
  final _firestore = FirebaseFirestore.instance;

  Future addMeeting(Meeting meeting) async {
    String retVal = 'error';
    final List<String?> members = [];
    final List<String?> tokens = [];
    try {
      members.add(Account.currentAccount?.id);
      tokens.add(Account.currentAccount?.notifyToken);
      await _firestore.collection('meetings').add({
        'place': meeting.place.trim(),
        'description': meeting.description,
        'author': meeting.author.id,
        'members': members,
        'tokens': tokens,
        'dateCompleted': meeting.dateCompleted,
        'notify': false,
        // 'pinId': meeting.pin
      });
      retVal = 'success';
    } catch (e) {
      debugPrint(e.toString());
    }
    return retVal;
  }

  Future editMeeting(Meeting meeting) async {
    String retVal = 'error';
    try {
      await FirebaseFirestore.instance.collection('meetings').doc(meeting.id).update(
        {'place': meeting.place, 'description': meeting.description, 'dateCompleted': meeting.dateCompleted},
      );
      retVal = 'success';
    } catch (e) {
      debugPrint(e.toString());
    }

    return retVal;
  }

  Future changeInfoNotify(Meeting meeting) async {
    String retVal = 'error';
    try {
      await FirebaseFirestore.instance.collection('meetings').doc(meeting.id).update(
        {
          'dateCompleted': meeting.dateCompleted,
        },
      );
      retVal = 'success';
    } catch (e) {
      debugPrint(e.toString());
    }

    return retVal;
  }

  Future timeNotify(Meeting meeting) async {
    String retVal = 'error';
    if (meeting.notify) {
      meeting.notify = false;
    } else {
      meeting.notify = true;
    }
    try {
      await FirebaseFirestore.instance.collection('meetings').doc(meeting.id).update(
        {'notify': meeting.notify},
      );
      retVal = 'success';
    } catch (e) {
      debugPrint(e.toString());
    }
    return retVal;
  }

  Future<bool> isMeetingOwner(Meeting meeting) {
    final DocumentReference docRef = FirebaseFirestore.instance.collection('meetings').doc(meeting.id);
    return docRef.get().then((datasnapshot) {
      if (datasnapshot['author'].toString() == Account.currentAccount!.id) {
        return true;
      } else {
        return false;
      }
    });
  }

  static void deleteMeeting(Meeting meeting) {
    FirebaseFirestore.instance.collection('meetings').doc(meeting.id).delete();
  }

  static Stream<List<Meeting>> meetingsOfUser(Account account, BuildContext context) {
    return FirebaseFirestore.instance
        .collection('meetings')
        .where('members', arrayContains: account.id)
        //сначала выводим ближайшие встречи
        .orderBy('dateCompleted', descending: false)
        .snapshots()
        .map((querySnapshot) {
      final List<Meeting> meetings = [];
      for (final DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        final Map<String, dynamic>? meetingMap = documentSnapshot.data() as Map<String, dynamic>?;
        final Meeting meeting = Meeting.fromMap(documentSnapshot.id, meetingMap!);
        // meeting.pin = await getPinByID(meetingMap["pinID"], context);
        meetings.add(meeting);
      }
      return meetings;
    });
  }

  Future<String> joinMeeting(String meetingId) async {
    String retVal = 'error';
    final List<String?> members = [];
    final List<String?> tokens = [];
    try {
      members.add(Account.currentAccount?.id);
      tokens.add(Account.currentAccount?.notifyToken);
      await _firestore.collection('meetings').doc(meetingId).update({
        'members': FieldValue.arrayUnion(members),
        'tokens': FieldValue.arrayUnion(tokens),
      });
      retVal = 'success';
    } on PlatformException {
      retVal = 'Убедитесь, что вы получили верный id встречи!';
    } catch (e) {
      debugPrint(e.toString());
    }
    return retVal;
  }

  static Future<void> leaveMeeting(String meetingId) async {
    final List<String?> members = [];
    final List<String?> tokens = [];
    try {
      members.add(Account.currentAccount?.id);
      tokens.add(Account.currentAccount?.notifyToken);
      await FirebaseFirestore.instance.collection('meetings').doc(meetingId).update({
        'members': FieldValue.arrayRemove(members),
        'tokens': FieldValue.arrayRemove(tokens),
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
