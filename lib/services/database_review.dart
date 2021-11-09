import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/services/database_pin.dart';
import 'package:flutter/material.dart';

class DatabaseReview {
  var firebaseInstance = FirebaseFirestore.instance;

  static void addReview(Review review) {
    FirebaseFirestore.instance.collection("reviews").add(review.asMap());
  }

  static Stream<List<Review>> getReviewsForPin(String pinID) {
    return FirebaseFirestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pinID)
        //сначала выведем последние комментарии
        //TODO разобраться как сменить на true, для этого посмотреть review_tile
        .orderBy("dateAdded", descending: false)
        .snapshots()
        .map((snapshot) {
      List<Review> reviews = [];
      for (DocumentSnapshot document in snapshot.docs) {
        Review review = Review.fromMap(
            document.id, document.data() as Map<String, dynamic>);
        reviews.add(review);
      }
      return reviews;
    });
  }


  static Stream<List<Review>> reviewsOfUser(
      Account account, BuildContext context) {
    return FirebaseFirestore.instance
        .collection("reviews")
        .where("author", isEqualTo: account.id)
        .snapshots()
        .asyncMap((querySnapshot) async {
      Completer<List<Review>> reviewsCompleter = Completer<List<Review>>();
      List<Review> reviews = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> reviewMap =
            documentSnapshot.data() as Map<String, dynamic>;
        Review review = Review.fromMap(documentSnapshot.id, reviewMap);
        review.pin = await DatabasePin.getPinByID(reviewMap["pinID"], context);
        reviews.add(review);
      }
      reviewsCompleter.complete(reviews);
      return reviewsCompleter.future;
    });
  }

    static Future<Review?> getFirstReview(String pinID) async {
    return await FirebaseFirestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pinID)
        .limit(1)
        .snapshots()
        .first
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot firstReviewDocument = snapshot.docChanges.first.doc;
        return Review.fromMap(firstReviewDocument.id,
            firstReviewDocument.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    });
  }

  static Future<Review> getReviewByID(
      String reviewID, BuildContext context) async {
    return await FirebaseFirestore.instance
        .collection("reviews")
        .where(FieldPath.documentId, isEqualTo: reviewID)
        .limit(1)
        .snapshots()
        .first
        .then((snapshot) {
      DocumentSnapshot firstReviewDocument = snapshot.docChanges.first.doc;
      Review review = Review.fromMap(firstReviewDocument.id,
          firstReviewDocument.data() as Map<String, dynamic>);
      return DatabasePin.getPinByID(firstReviewDocument["pinID"], context).then((pin) {
        review.pin = pin;
        return review;
      });
    });
  }

  static Future<Stream<List<Review>>> favouriteReviewsForUser(
      Account account, BuildContext context) {
    return getFavouriteReviewsIDs(account).then((idStream) {
      return idStream
          .asyncMap((snapshot) => getReviewsByReviewIDs(snapshot, context));
    });
  }

  static Future<Stream<List<String>>> getFavouriteReviewsIDs(Account account) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: account.id)
        .get()
        .then((userSnapshot) {
      String userID = userSnapshot.docs.first.id;
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userID)
          .collection("favourites")
          .snapshots()
          .map((snapshot) {
        List<String> reviewIDs = [];
        for (DocumentSnapshot document in snapshot.docs) {
          reviewIDs.add(document.id);
        }
        return reviewIDs;
      });
    });
  }

  static Future<List<Review>> getReviewsByReviewIDs(
      List<String> reviewIDs, BuildContext context) {
    return FirebaseFirestore.instance
        .collection("reviews")
        .where(FieldPath.documentId, whereIn: reviewIDs)
        .get()
        .then((snapshot) async {
      List<Review> reviews = [];
      for (DocumentSnapshot document in snapshot.docs) {
        Review review = Review.fromMap(
            document.id, document.data() as Map<String, dynamic>);
        review.pin = await DatabasePin.getPinByID(document["pinID"], context);
        reviews.add(review);
      }
      return reviews;
    });
  }

  static void addFavourite(String reviewID) async {
    var users = await FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((value) => value.docs);
    String user = users[0].id.toString();

    final CollectionReference favouritesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user)
        .collection("favourites");

    await favouritesRef.doc(reviewID).set(newFavouriteMap());
  }

  static Map<String, dynamic> newFavouriteMap() {
    Map<String, dynamic> favourite = <String, dynamic>{};
    return favourite;
  }

  static void removeFavourite(String reviewID) {
    FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((userSnapshot) {
      String user = userSnapshot.docs.first.id;
      FirebaseFirestore.instance
          .collection("users")
          .doc(user)
          .collection("favourites")
          .doc(reviewID)
          .delete();
    });
  }

  static Future<bool> isFavourite(String reviewID) async {
    return getFavouriteReviewsIDs(Account.currentAccount!).then((snapshots) {
      return snapshots.first.then((reviewIDs) {
        return reviewIDs.contains(reviewID);
      });
    });
  }

  static Future<bool> isReviewOwner(Review review) {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("reviews").doc(review.id);
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

  /// удаляем флаг с отзыва
  static void removeFlag(String id) {
    FirebaseFirestore.instance
        .collection("flags")
        .where("reviewID", isEqualTo: id)
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) snapshot.docs.first.reference.delete();
    });
  }

  /// добавляем флаг на отзыв
  static void addFlag(String id) {
    Map<String, dynamic> flag = <String, dynamic>{};
    flag["reviewID"] = id;
    flag["userID"] = Account.currentAccount!.id;
    FirebaseFirestore.instance.collection("flags").add(flag);
  }

  /// проверяем поставил ли флажок пользователь данному комментарию
  static Future<bool> isFlagged(dynamic id) {
    return FirebaseFirestore.instance
        .collection("flags")
        .where("reviewID", isEqualTo: id)
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((snapshot) {
      return (snapshot.docs.isNotEmpty);
    });
  }

  /// возвращаем все плохие отзывы для админа
  static Stream<List<Review?>> flaggedReviews(BuildContext context) {
    return FirebaseFirestore.instance
        .collection("flags")
        .snapshots()
        .asyncMap((querySnapshot) async {
      Completer<List<Review?>> reviewsCompleter = Completer<List<Review?>>();
      List<Review?> reviews = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Review review =
            await getReviewByID(documentSnapshot["reviewID"], context);
        reviews.add(review);
      }
      reviewsCompleter.complete(reviews);
      return reviewsCompleter.future;
    });
  }

  /// если админ считает отзыв нормальным - убираем с него флаг
  /// (для конкретного пользователя)
  static void justifyFlag(String id) {
    FirebaseFirestore.instance
        .collection("flags")
        .where("reviewID", isEqualTo: id)
        .get()
        .then((query) {
      for (var document in query.docs) {
        document.reference.delete();
      }
    });
  }

  /// редактируем отзыв
  static Future<void> editReview(Review review) async {
    FirebaseFirestore.instance
        .collection("reviews")
        .doc(review.id)
        .set(<String, dynamic>{
      "content": review.body,
      "isFood": review.isFood,
      "isFree": review.isFree,
      "isRazors": review.isRazors,
      "isWiFi": review.isWiFi,
      "userRate": review.userRate,
      "totalRate": review.totalRate
    }, SetOptions(merge: true));
    // return true;
  }

  // если админ считает отзыв плохим - удаляем его
  static void deleteReview(Review review) {
    justifyFlag(review.id!);
    FirebaseFirestore.instance.collection("reviews").doc(review.id).delete();
    addStrike(review.author.id);
  }

  // TODO: решить что делать со страйками на пользователя
  static void addStrike(String? id) {
    FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: id)
        .get()
        .then((query) {
      query.docs.first.reference.update({"strikes": FieldValue.increment(1)});
    });
  }
}
