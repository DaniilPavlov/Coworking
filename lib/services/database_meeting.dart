import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/meeting.dart';
import 'package:flutter/services.dart';

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
    try {
      DocumentReference _docRef = await _firestore.collection("meetings").add({
        'place': meeting.place.trim(),
        'description': meeting.description,
        'author': meeting.author.id,
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
    Firestore.instance.collection("reviews").document(meeting.id).delete();
  }

  Future<String> joinGroup(String groupId, Account account) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();
    try {
      members.add(account.id);
      tokens.add(account.notifyToken);
      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayUnion(members),
        'tokens': FieldValue.arrayUnion(tokens),
      });

      await _firestore.collection("users").document(account.id).updateData({
        'groupId': groupId.trim(),
      });

      retVal = "success";
    } on PlatformException catch (e) {
      retVal = "Make sure you have the right group ID!";
      print(e);
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> leaveGroup(String groupId, Account account) async {
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

  Future<String> addCurrentMeeting(String groupId, Meeting meeting) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("meetings")
          .add({
        'name': meeting.place.trim(),
        'author': meeting.author,
        'dateCompleted': meeting.dateCompleted,
        // 'pinId': meeting.pin
      });

      //add current book to group schedule
      await _firestore.collection("groups").document(groupId).updateData({
        "currentMeetingId": _docRef.documentID,
        "currentMeetingDue": meeting.dateCompleted,
      });

      //adding a notification document
      DocumentSnapshot doc =
          await _firestore.collection("groups").document(groupId).get();
      createNotifications(List<String>.from(doc.data["tokens"]) ?? [],
          meeting.place, meeting.author.id);

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<Meeting> getCurrentMeeting(String groupId, String bookId) async {
    Meeting retVal;

    try {
      DocumentSnapshot _docSnapshot = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("meetings")
          .document(bookId)
          .get();
      // retVal = Meeting.fromDocumentSnapshot(doc: _docSnapshot);
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  /// ТУТ НУЖНО РАЗОБРАТЬСЯ С НОТИФАЙТОКЕНОМ И ОСТАЛЬНЫМ
  Future<String> createUser(Account account) async {
    String retVal = "error";

    try {
      await _firestore.collection("users").document(account.id).setData({
        /// оставляем только нотифай токен, потому что регистрация через гугл
        'notifToken': account.notifyToken,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  ///ТОЖЕ ПОКА НЕ ИСПОЛЬЗУЕТСЯ
  Future<Account> getUser(String uid) async {
    Account retVal;

    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("users").document(uid).get();
      retVal = Account.fromDocumentSnapshot(doc: _docSnapshot);
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
