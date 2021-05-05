import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/meeting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class DatabaseMeeting {
  Firestore _firestore = Firestore.instance;

  // Future<String> createGroup(
  //     String groupName, Account user, Meeting initialMeeting) async {
  //   String retVal = "error";
  //   List<String> members = List();
  //   List<String> tokens = List();
  //
  //   try {
  //     members.add(user.id);
  //     tokens.add(user.notifyToken);
  //     DocumentReference _docRef;
  //     if (user.notifyToken != null) {
  //       _docRef = await _firestore.collection("groups").add({
  //         'name': groupName.trim(),
  //         'leader': user.id,
  //         'members': members,
  //         'tokens': tokens,
  //         'groupCreated': Timestamp.now(),
  //       });
  //     } else {
  //       _docRef = await _firestore.collection("groups").add({
  //         'name': groupName.trim(),
  //         'leader': user.id,
  //         'members': members,
  //         'groupCreated': Timestamp.now(),
  //       });
  //     }
  //     // Account.currentAccount.groupId = _docRef.documentID;
  //     await Firestore.instance
  //         .collection("users")
  //         .where("userID", isEqualTo: Account.currentAccount.id)
  //         .getDocuments()
  //         .then((query) {
  //       query.documents.first.reference.updateData({
  //         "groupId": _docRef.documentID,
  //       });
  //     });
  //
  //     addMeeting(_docRef.documentID, initialMeeting);
  //
  //     retVal = "success";
  //   } catch (e) {
  //     print("EEEEEEEEEEEEEROR");
  //     print(e);
  //   }
  //
  //   return retVal;
  // }

  Future<String> addMeeting(Meeting meeting) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();
    try {
      members.add(Account.currentAccount.id);
      tokens.add(Account.currentAccount.notifyToken);
      DocumentReference _docRef = await _firestore.collection("meetings").add({
        'place': meeting.place.trim(),
        'description': meeting.description,
        'author': meeting.author.id,
        'members': members,
        'tokens': tokens,
        'dateCompleted': meeting.dateCompleted,
        // 'pinId': meeting.pin
      });

      // //adding a notification document
      // DocumentSnapshot doc =
      // await _firestore.collection("meetings").document(meeting.id).get();
      // createNotifications(List<String>.from(doc.data["tokens"]) ?? [],
      //     meeting.place, meeting.author.id);

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  /// редактируем отзыв
  Future editMeeting(Meeting meeting) async {
    String retVal = "error";
    try {
      Firestore.instance.collection("meetings").document(meeting.id).updateData(
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

  static Future<bool> isMeetingOwner(Meeting meeting) {
    DocumentReference docRef =
        Firestore.instance.collection("meetings").document(meeting.id);
    return docRef.get().then((datasnapshot) {
      print(datasnapshot.data['author'].toString());
      print(
          datasnapshot.data['author'].toString() == Account.currentAccount.id);
      if (datasnapshot.data['author'].toString() == Account.currentAccount.id) {
        return true;
      } else {
        return false;
      }
    });
  }

  static void deleteMeeting(Meeting meeting) {
    Firestore.instance.collection("meetings").document(meeting.id).delete();
  }

  static Stream<List<Meeting>> meetingsOfUser(
      Account account, BuildContext context) {
    return Firestore.instance
        .collection("meetings")

        ///РАБОТАЕТ!!!
        .where("members", arrayContains: account.id)
        .snapshots()
        .asyncMap((querySnapshot) async {
      Completer<List<Meeting>> meetingsCompleter =
          new Completer<List<Meeting>>();
      List<Meeting> meetings = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
        Map<String, dynamic> meetingMap = documentSnapshot.data;
        Meeting meeting =
            Meeting.fromMap(documentSnapshot.documentID, meetingMap);
        // meeting.pin = await getPinByID(meetingMap["pinID"], context);
        meetings.add(meeting);
      }
      meetingsCompleter.complete(meetings);
      return meetingsCompleter.future;
    });
  }

  /// Сделать проверку состаю ли я в митинге, вроде все ок
  /// но если поменять аккаунт на устройстве - токен останется такой же
  Future<String> joinMeeting(String meetingId) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();
    try {
      members.add(Account.currentAccount.id);
      tokens.add(Account.currentAccount.notifyToken);
      await _firestore.collection("meetings").document(meetingId).updateData({
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

  /// Добавить выход из группы
  Future<String> leaveMeeting(String groupId, Account account) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();
    try {
      members.add(account.id);
      tokens.add(account.notifyToken);
      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayRemove(members),
        'tokens': FieldValue.arrayRemove(tokens),
      });

      await _firestore.collection("users").document(account.id).updateData({
        'groupId': null,
      });
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> createNotifications(
      List<String> tokens, String meetingName, String author) async {
    String retVal = "error";

    try {
      await _firestore.collection("notifications").add({
        'MeetingName': meetingName.trim(),
        'author': author.trim(),
        'tokens': tokens,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }
}
