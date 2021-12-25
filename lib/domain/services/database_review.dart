import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/domain/entities/account.dart';
import 'package:coworking/domain/entities/pin.dart';
import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/domain/services/database_pin.dart';
import 'package:flutter/material.dart';

class DatabaseReview {
  var firebaseInstance = FirebaseFirestore.instance;

  static void addReview(Review review) {
    FirebaseFirestore.instance.collection("reviews").add(review.asMap());
  }

  static Stream<List<Review>> fetchReviewsForPin(Pin pin) {
    return FirebaseFirestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pin.id)
        .orderBy("dateAdded", descending: false)
        .snapshots()
        .map((snapshot) {
      List<Review> reviews = [];
      for (DocumentSnapshot document in snapshot.docs) {
        Review review = Review.fromMap(
            document.id, document.data() as Map<String, dynamic>);
        review.pin = pin;
        reviews.insert(0, review);
      }
      return reviews;
    });
  }

  static Stream<List<Review>> fetchReviewsOfUser(
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
        review.pin =
            await DatabasePin.fetchPinByID(reviewMap["pinID"], context);
        reviews.add(review);
      }
      reviewsCompleter.complete(reviews);
      return reviewsCompleter.future;
    });
  }

  static Future<int> fetchReviewsOfUserAmount(Account account) async {
    var numberOfReviews;

    await FirebaseFirestore.instance
        .collection("reviews")
        .where("author", isEqualTo: account.id)
        .get()
        .then((list) {
      numberOfReviews = list.docs.length;
    });
    return numberOfReviews ?? 0;
  }

  static Future<Review?> fetchFirstReview(String pinID) async {
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

  static Future<Review> fetchReviewByID(
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
      return DatabasePin.fetchPinByID(firstReviewDocument["pinID"], context)
          .then((pin) {
        review.pin = pin;
        return review;
      });
    });
  }

  static Future<bool> isReviewOwner(Review review) {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("reviews").doc(review.id);
    return docRef.get().then((datasnapshot) {
      if (datasnapshot['author'].toString() == Account.currentAccount!.id) {
        return true;
      } else {
        return false;
      }
    });
  }

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

  static void addFlag(String id) {
    Map<String, dynamic> flag = <String, dynamic>{};
    flag["reviewID"] = id;
    flag["userID"] = Account.currentAccount!.id;
    FirebaseFirestore.instance.collection("flags").add(flag);
  }

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

  static Stream<List<Review?>> fetchFlaggedReviews(BuildContext context) {
    return FirebaseFirestore.instance
        .collection("flags")
        .snapshots()
        .asyncMap((querySnapshot) async {
      Completer<List<Review?>> reviewsCompleter = Completer<List<Review?>>();
      List<Review?> reviews = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Review review =
            await fetchReviewByID(documentSnapshot["reviewID"], context);
        reviews.add(review);
      }
      reviewsCompleter.complete(reviews);
      return reviewsCompleter.future;
    });
  }

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
      "totalRate": review.totalRate,
      "dateAdded": review.timestamp
    }, SetOptions(merge: true));
  }

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
