import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/models/visited.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:coworking/models/meeting.dart';

import '../models/account.dart';
import '../models/category.dart';

class PinChange {
  DocumentChangeType type;
  Pin pin;

  PinChange(this.type, this.pin);
}

class DatabaseMap {
  static Stream<List<PinChange>> getPins(BuildContext context) {
    return Firestore.instance
        .collection("pins")
        .snapshots()
        .asyncMap((snapshot) async {
      Completer<List<PinChange>> pinsListCompleter =
          Completer<List<PinChange>>();
      List<PinChange> pinChanges = [];
      for (DocumentChange documentChange in snapshot.documentChanges) {
        DocumentSnapshot document = documentChange.document;
        Pin pin = Pin(
          document.documentID,
          LatLng(
            document["location"].latitude,
            document["location"].longitude,
          ),
          Account(document["author"]),
          document["name"],
          document["imageUrl"],
          Category.find(document["category"]),
          document["rating"],
          context,
          review: (documentChange.type == DocumentChangeType.added)
              ? await getFirstReview(document.documentID)
              : null,
        );
        pinChanges.add(PinChange(documentChange.type, pin));
      }
      pinsListCompleter.complete(pinChanges);
      return pinsListCompleter.future;
    });
  }

  static Stream<List<Review>> getReviewsForPin(String pinID) {
    return Firestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pinID)
        .snapshots()
        .map((snapshot) {
      List<Review> reviews = [];
      for (DocumentSnapshot document in snapshot.documents) {
        Review review = Review.fromMap(document.documentID, document.data);
        reviews.add(review);
      }
      reviews.sort((firstReview, secondReview) =>
          firstReview.timestamp.compareTo((secondReview.timestamp)));
      return reviews;
    });
  }

  static Future updateRateOfPin(String pinID) async {
    double rating = 0;
    return await Firestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pinID)
        .getDocuments()
        .then((query) {
      for (DocumentSnapshot documentSnapshot in query.documents) {
        Map<String, dynamic> reviewMap = documentSnapshot.data;
        Review review = Review.fromMap(documentSnapshot.documentID, reviewMap);
        rating = rating + review.totalRate;
      }
      rating = rating / query.documents.length;
      DocumentReference docRef =
          Firestore.instance.collection("pins").document(pinID);
      docRef.updateData(<String, dynamic>{"rating": rating});
      print("RATING");
      rating = double.parse(rating.toStringAsFixed(2));
      print(rating);
      return rating;
    });
  }

  static Future<Review> getFirstReview(String pinID) async {
    return await Firestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pinID)
        //.orderBy("dateAdded", descending: true)
        .limit(1)
        .snapshots()
        .first
        .then((snapshot) {
      if (snapshot.documents.length > 0) {
        DocumentSnapshot firstReviewDocument =
            snapshot.documentChanges.first.document;
        return Review.fromMap(
            firstReviewDocument.documentID, firstReviewDocument.data);
      } else
        return null;
    });
  }

  static Future<Review> getReviewByID(
      String reviewID, BuildContext context) async {
    return await Firestore.instance
        .collection("reviews")
        .where(FieldPath.documentId, isEqualTo: reviewID)
        .limit(1)
        .snapshots()
        .first
        .then((snapshot) {
      if (snapshot.documents.length > 0) {
        DocumentSnapshot firstReviewDocument =
            snapshot.documentChanges.first.document;
        Review review = Review.fromMap(
            firstReviewDocument.documentID, firstReviewDocument.data);
        return getPinByID(firstReviewDocument.data["pinID"], context)
            .then((pin) {
          review.pin = pin;
          return review;
        });
      } else
        return null;
    });
  }

  static Future<Pin> newPin(
    LatLng location,
    String name,
    Review review,
    Account author,
    File image,
    Category category,
    BuildContext context,
  ) async {
    //ждем загрузки фото
    var timeKey = new DateTime.now();
    final StorageReference postImageRef =
        FirebaseStorage.instance.ref().child("Pin Images");
    final StorageUploadTask uploadTask =
        postImageRef.child(timeKey.toString() + ".jpg").putFile(image);
    var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    //добавляем пин в базу
    DocumentReference newPin = await Firestore.instance.collection("pins").add(
        Pin.newPinMap(
            name, location, author, imageUrl, category, review.totalRate));

    //создаем map для отзыва
    Map<String, dynamic> initialReviewMap =
        Review.newReviewMap(review, newPin.documentID);

    //добавляем отзыв
    DocumentReference initialReview =
        await Firestore.instance.collection("reviews").add(initialReviewMap);

    review.id = initialReview.documentID;

    return Pin(
      newPin.documentID,
      location,
      author,
      name,
      imageUrl,
      category,
      review.totalRate,
      context,
      review: review,
    );
  }

  static Stream<List<Review>> reviewsByUser(
      Account account, BuildContext context) {
    return Firestore.instance
        .collection("reviews")
        .where("author", isEqualTo: account.id)
        .snapshots()
        .asyncMap((querySnapshot) async {
      Completer<List<Review>> reviewsCompleter = new Completer<List<Review>>();
      List<Review> reviews = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
        Map<String, dynamic> reviewMap = documentSnapshot.data;
        Review review = Review.fromMap(documentSnapshot.documentID, reviewMap);
        review.pin = await getPinByID(reviewMap["pinID"], context);
        reviews.add(review);
      }
      reviewsCompleter.complete(reviews);
      return reviewsCompleter.future;
    });
  }

  static Stream<List<Meeting>> meetingsByUser(
      Account account, BuildContext context) {
    return Firestore.instance
        .collection("meetings")
        .where("author", isEqualTo: account.id)
        .snapshots()
        .asyncMap((querySnapshot) async {
      Completer<List<Meeting>> meetingsCompleter = new Completer<List<Meeting>>();
      List<Meeting> meetings = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
        Map<String, dynamic> meetingMap = documentSnapshot.data;
        Meeting meeting = Meeting.fromMap(documentSnapshot.documentID,meetingMap);
        // meeting.pin = await getPinByID(meetingMap["pinID"], context);
        meetings.add(meeting);
      }
      meetingsCompleter.complete(meetings);
      return meetingsCompleter.future;
    });
  }

  static Stream<List<String>> visitedByUser(
      Account account, BuildContext context) {
    return Firestore.instance
        .collection("visited")
        .where("userID", isEqualTo: account.id)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<String> pins = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
        Map<String, dynamic> visitedMap = documentSnapshot.data;
        pins.add(visitedMap["pin"]);
      }
      return pins;
    });
  }

  static void addVisited(String user, String pin) {
    Visited v = new Visited(user, pin);
    Firestore.instance.collection("visited").add(v.asMap());
  }

  static void deleteVisited(String user, String pin) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection("visited")
        .where("pin", isEqualTo: pin)
        .where("userID", isEqualTo: user)
        .snapshots()
        .first;

    String id = snapshot.documents.first.documentID;

    Firestore.instance.collection("visited").document(id).delete();
  }

  static Future<Pin> getPinByID(String pinID, BuildContext context) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection("pins")
        .where(FieldPath.documentId, isEqualTo: pinID)
        .snapshots()
        .first;
    return Pin.fromMap(pinID, snapshot.documents.first.data,
        await getFirstReview(pinID), context);
  }

  static void addReview(Review review) {
    Firestore.instance.collection("reviews").add(review.asMap());
  }

  ///добавляем митинг в базу
  static void addMeeting(Meeting meeting) {
    Firestore.instance.collection("meetings").add(meeting.asMap());
  }

  static void addUserToDatabase(Account user) {
    Firestore.instance.collection("users").add(user.asMap());
  }

  static Future<String> getUserNameByID(String id) {
    return Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: id)
        .getDocuments()
        .then((snapshot) {
      return snapshot.documents.first.data["name"];
    });
  }

  /// удаляем флаг с отзыва
  static void unFlag(String id) {
    Firestore.instance
        .collection("flags")
        .where("reviewID", isEqualTo: id)
        .where("userID", isEqualTo: Account.currentAccount.id)
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.length > 0)
        snapshot.documents.first.reference.delete();
    });
  }

  /// добавляем флаг на отзыв
  static void flag(String id) {
    Map<String, dynamic> flag = Map();
    flag["reviewID"] = id;
    flag["userID"] = Account.currentAccount.id;
    Firestore.instance.collection("flags").add(flag);
  }

  /// проверяем поставил ли флажок пользователь данному комментарию
  static Future<bool> isFlagged(id) {
    return Firestore.instance
        .collection("flags")
        .where("reviewID", isEqualTo: id)
        .where("userID", isEqualTo: Account.currentAccount.id)
        .getDocuments()
        .then((snapshot) {
      return (snapshot.documents.length > 0);
    });
  }

  static Future<bool> isAdmin() {
    return Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount.id)
        .getDocuments()
        .then((snapshot) => snapshot.documents.first.data["isAdmin"]);
  }

  static Future<bool> isReviewOwner(Review review) {
    DocumentReference docRef =
        Firestore.instance.collection("reviews").document(review.id);
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

  static Future<bool> isPinOwner(Pin pin) {
    return Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount.id)
        .getDocuments()
        .then((datasnap) {
      if (datasnap.documents.first.data["isAdmin"] == true) {
        return true;
      }
      DocumentReference docRef =
          Firestore.instance.collection("pins").document(pin.id);
      return docRef.get().then((datasnapshot) {
        if (datasnapshot.data['author'].toString() ==
            Account.currentAccount.id) {
          return true;
        } else {
          return false;
        }
      });
    });
  }

  /// возвращаем все плохие отзывы для админа
  static Stream<List<Review>> flaggedReviews(BuildContext context) {
    return Firestore.instance
        .collection("flags")
        .snapshots()
        .asyncMap((querySnapshot) async {
      Completer<List<Review>> reviewsCompleter = new Completer<List<Review>>();
      List<Review> reviews = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
        Review review =
            await getReviewByID(documentSnapshot.data["reviewID"], context);
        reviews.add(review);
      }
      reviewsCompleter.complete(reviews);
      return reviewsCompleter.future;
    });
  }

  /// Ignores any flags for this review.
  ///
  /// Deletes all flags that users have made for the review specified by [id].
  /// если админ считает отзыв нормальным - убираем с него флаг
  /// (для конкретного пользователя)
  static void ignoreFlags(String id) {
    Firestore.instance
        .collection("flags")
        .where("reviewID", isEqualTo: id)
        .getDocuments()
        .then((query) {
      query.documents.forEach((document) {
        document.reference.delete();
      });
    });
  }

  /// редактируем отзыв
  Future editReview(Review review) async {
    Firestore.instance
        .collection("reviews")
        .document(review.id)
        .setData({"content": review.body, "isFood": review.isFood,
      "isFree": review.isFree,"isRazors": review.isRazors,
      "isWiFi": review.isWiFi,"userRate": review.userRate, "totalRate": review.totalRate}, merge: true);
    // return true;
  }

  /// редактируем пин
  Future editPin(Pin pin) async {
    Firestore.instance.collection("pins").document(pin.id).setData({
      "category": pin.category.text,
      "name": pin.name,
      "imageUrl": pin.imageUrl
    }, merge: true);
    // return true;
  }

  /// если админ считает отзыв плохим - удаляем его
  static void deleteReview(Review review) {
    ignoreFlags(review.id);
    Firestore.instance.collection("reviews").document(review.id).delete();
    addStrike(review.author.id);
  }

  static void deletePin(Pin pin) {
    ignoreFlags(pin.id);
    Firestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pin.id)
        .getDocuments()
        .then((query) {
      query.documents.forEach((document) {
        document.reference.delete();
      });
    });
    Firestore.instance.collection("pins").document(pin.id).delete();
  }

  // TODO: решить что делать со страйками на пользователя
  static void addStrike(String id) {
    Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: id)
        .getDocuments()
        .then((query) {
      query.documents.first.reference
          .updateData({"strikes": FieldValue.increment(1)});
    });
  }

  static void updateUsername(String name) {
    Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount.id)
        .getDocuments()
        .then((query) {
      query.documents.first.reference.updateData({
        "name": name,
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
    return Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: account.id)
        .getDocuments()
        .then((userSnapshot) {
      String userID = userSnapshot.documents.first.documentID;
      return Firestore.instance
          .collection("users")
          .document(userID)
          .collection("favourites")
          .snapshots()
          .map((snapshot) {
        List<String> reviewIDs = [];
        for (DocumentSnapshot document in snapshot.documents) {
          reviewIDs.add(document.documentID);
        }
        return reviewIDs;
      });
    });
  }

  static Future<List<Review>> getReviewsByReviewIDs(
      List<String> reviewIDs, BuildContext context) {
    return Firestore.instance
        .collection("reviews")
        .where(FieldPath.documentId, whereIn: reviewIDs)
        .getDocuments()
        .then((snapshot) async {
      List<Review> reviews = [];
      for (DocumentSnapshot document in snapshot.documents) {
        Review review = Review.fromMap(document.documentID, document.data);
        review.pin = await getPinByID(document.data["pinID"], context);
        reviews.add(review);
      }
      return reviews;
    });
  }

  static addFavourite(String reviewID) async {
    List users = await Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount.id)
        .getDocuments()
        .then((value) => value.documents);
    String user = users[0].documentID.toString();

    final CollectionReference favouritesRef = Firestore.instance
        .collection("users")
        .document(user)
        .collection("favourites");

    await favouritesRef.document(reviewID).setData(newFavouriteMap());
  }

  static Map<String, dynamic> newFavouriteMap() {
    Map<String, dynamic> favourite = Map();
    return favourite;
  }

  static removeFavourite(String reviewID) {
    Firestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount.id)
        .getDocuments()
        .then((userSnapshot) {
      String user = userSnapshot.documents.first.documentID;
      Firestore.instance
          .collection("users")
          .document(user)
          .collection("favourites")
          .document(reviewID)
          .delete();
    });
  }

  ///по id можно определить любимый отзыв это или нет
  static Future<bool> isFavourite(String reviewID) async {
    return getFavouriteReviewsIDs(Account.currentAccount).then((snapshots) {
      return snapshots.first.then((reviewIDs) {
        return reviewIDs.contains(reviewID);
      });
    });
  }
}
