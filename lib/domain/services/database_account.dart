import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/domain/entities/account.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseAccount {
  var firebaseInstance = FirebaseFirestore.instance;

  static void deleteUser(Account account) {
    FirebaseFirestore.instance
        .collection("meetings")
        .where("author", isEqualTo: account.id)
        .get()
        .then((query) {
      for (var document in query.docs) {
        document.reference.delete();
      }
    });
    List<String?> members = [];
    List<String?> tokens = [];
    members.add(Account.currentAccount!.id);
    tokens.add(Account.currentAccount!.notifyToken);
    FirebaseFirestore.instance
        .collection("meetings")
        .where("tokens", arrayContains: account.notifyToken)
        .get()
        .then((query) {
      for (var document in query.docs) {
        print(document.id);
        FirebaseFirestore.instance
            .collection("meetings")
            .doc(document.id)
            .update({
          'members': FieldValue.arrayRemove(members),
          'tokens': FieldValue.arrayRemove(tokens)
        });
      }
    });
    print(account.id);
    FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: account.id)
        .get()
        .then((query) {
      for (var document in query.docs) {
        document.reference.delete();
      }
    });
  }

  static void updateUsername(String name) {
    FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((query) {
      query.docs.first.reference.update({
        "name": name,
      });
    });
    FirebaseAuth.instance.currentUser!.updateDisplayName(name);
  }

  static Future<bool> isAdmin() {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((snapshot) => snapshot.docs.first["isAdmin"]);
  }

  static Future<String?> fetchUserNameByID(String id) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .where("userID", isEqualTo: id)
          .get()
          .then((snapshot) {
        return snapshot.docs.first["name"];
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

  static void addUserToDatabase(Account? user) {
    FirebaseFirestore.instance.collection("users").add(user!.asMap());
  }

  static void updateUserToken(String? notifyToken) {
    FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((query) {
      query.docs.first.reference.update({
        "notifyToken": notifyToken,
      });
    });
  }
}
