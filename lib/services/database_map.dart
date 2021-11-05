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

import 'package:coworking/models/account.dart';
import 'package:coworking/models/category.dart';

class PinChange {
  DocumentChangeType type;
  Pin pin;

  PinChange(this.type, this.pin);
}

class DatabaseMap {
  var firebaseInstance = FirebaseFirestore.instance;

  static Stream<List<PinChange>> getPins(BuildContext context) {
    return FirebaseFirestore.instance
        .collection("pins")
        .snapshots()
        .asyncMap((snapshot) async {
      Completer<List<PinChange>> pinsListCompleter =
          Completer<List<PinChange>>();
      List<PinChange> pinChanges = [];
      for (DocumentChange documentChange in snapshot.docChanges) {
        DocumentSnapshot document = documentChange.doc;
        print("AAAAAAAAAAAAAAAAAAAAAAAA   " + document["name"]);
        Pin pin = Pin(
          document.id,
          LatLng(
            document["location"].latitude,
            document["location"].longitude,
          ),
          Account(document["author"]),
          document["name"],
          document["imageUrl"],
          Category.find(document["category"]),
          document["rating"] ,
          context,
          review: (documentChange.type == DocumentChangeType.added)
              ? await getFirstReview(document.id)
              : null,
        );
        pinChanges.add(PinChange(documentChange.type, pin));
      }
      pinsListCompleter.complete(pinChanges);
      return pinsListCompleter.future;
    });
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

  static Future updateRateOfPin(String? pinID) async {
    double rating = 0;
    return await FirebaseFirestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pinID)
        .get()
        .then((query) {
      for (DocumentSnapshot documentSnapshot in query.docs) {
        Map<String, dynamic> reviewMap =
            documentSnapshot.data() as Map<String, dynamic>;
        Review review = Review.fromMap(documentSnapshot.id, reviewMap);
        rating = rating + review.totalRate;
      }
      rating = rating / query.docs.length;
      DocumentReference docRef =
          FirebaseFirestore.instance.collection("pins").doc(pinID);
      docRef.update(<String, dynamic>{"rating": rating});
      print("RATING");
      rating = double.parse(rating.toStringAsFixed(2));
      print(rating);
      return rating;
    });
  }

  static Future threeMonthRate(String pinID) async {
    var threeMonth = <double>[];
    double rating = 0.0;
    double isFood = 0.0;
    double isFree = 0.0;
    double isRazors = 0.0;
    double isWiFi = 0.0;
    return await FirebaseFirestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pinID)
        .where('dateAdded',
            isGreaterThanOrEqualTo:
                DateTime.now().subtract(const Duration(days: 90)))
        .get()
        .then((query) {
      for (DocumentSnapshot documentSnapshot in query.docs) {
        Map<String, dynamic> reviewMap =
            documentSnapshot.data() as Map<String, dynamic>;
        Review review = Review.fromMap(documentSnapshot.id, reviewMap);
        rating = rating + review.totalRate;
        if (review.isFood) isFood++;
        if (review.isFree) isFree++;
        if (review.isRazors) isRazors++;
        if (review.isWiFi) isWiFi++;
      }
      rating = rating / query.docs.length;
      isFood = 100 * isFood / query.docs.length;
      isFree = 100 * isFree / query.docs.length;
      isRazors = 100 * isRazors / query.docs.length;
      isWiFi = 100 * isWiFi / query.docs.length;
      rating = double.parse(rating.toStringAsFixed(2));
      isFood = double.parse(isFood.toStringAsFixed(2));
      isFree = double.parse(isFree.toStringAsFixed(2));
      isRazors = double.parse(isRazors.toStringAsFixed(2));
      isWiFi = double.parse(isWiFi.toStringAsFixed(2));
      threeMonth.add(rating);
      threeMonth.add(isFood);
      threeMonth.add(isFree);
      threeMonth.add(isRazors);
      threeMonth.add(isWiFi);
      print(threeMonth.length);
      return threeMonth;
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

  static Future<Review?> getReviewByID(
      String reviewID, BuildContext context) async {
    return await FirebaseFirestore.instance
        .collection("reviews")
        .where(FieldPath.documentId, isEqualTo: reviewID)
        .limit(1)
        .snapshots()
        .first
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot firstReviewDocument = snapshot.docChanges.first.doc;
        Review review = Review.fromMap(firstReviewDocument.id,
            firstReviewDocument.data() as Map<String, dynamic>);
        return getPinByID(firstReviewDocument["pinID"], context)
            .then((pin) {
          review.pin = pin;
          return review;
        });
      } else {
        return null;
      }
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
    var timeKey = DateTime.now();
    final Reference postImageRef =
        FirebaseStorage.instance.ref().child("Pin Images");
    final UploadTask uploadTask =
        postImageRef.child(timeKey.toString() + ".jpg").putFile(image);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    //добавляем пин в базу
    DocumentReference newPin = await FirebaseFirestore.instance
        .collection("pins")
        .add(Pin.newPinMap(
            name, location, author, imageUrl, category, review.totalRate));

    //создаем map для отзыва
    Map<String, dynamic> initialReviewMap =
        Review.newReviewMap(review, newPin.id);

    //добавляем отзыв
    DocumentReference initialReview = await FirebaseFirestore.instance
        .collection("reviews")
        .add(initialReviewMap);

    review.id = initialReview.id;

    return Pin(
      newPin.id,
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
        review.pin = await getPinByID(reviewMap["pinID"] , context);
        reviews.add(review);
      }
      reviewsCompleter.complete(reviews);
      return reviewsCompleter.future;
    });
  }

  static Stream<List<String>> visitedByUser(
      Account account, BuildContext context) {
    return FirebaseFirestore.instance
        .collection("visited")
        .where("userID", isEqualTo: account.id)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<String> pins = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> visitedMap =
            documentSnapshot.data() as Map<String, dynamic>;
        pins.add(visitedMap["pin"] );
      }
      return pins;
    });
  }

  static void addVisited(String user, String pin) {
    Visited v = Visited(user, pin);
    FirebaseFirestore.instance.collection("visited").add(v.asMap());
  }

  static void deleteVisited(String user, String pin) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("visited")
        .where("pin", isEqualTo: pin)
        .where("userID", isEqualTo: user)
        .snapshots()
        .first;
    String id = snapshot.docs.first.id;
    FirebaseFirestore.instance.collection("visited").doc(id).delete();
  }

  static Future<Pin> getPinByID(String pinID, BuildContext context) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("pins")
        .where(FieldPath.documentId, isEqualTo: pinID)
        .snapshots()
        .first;
    return Pin.fromMap(
        pinID,
        snapshot.docs.first.data() as Map<String, dynamic>,
        await getFirstReview(pinID),
        context);
  }

  static void addReview(Review review) {
    FirebaseFirestore.instance.collection("reviews").add(review.asMap());
  }

  ///добавляем митинг в базу
  static void addMeeting(Meeting meeting) {
    FirebaseFirestore.instance.collection("meetings").add(meeting.asMap());
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

  static Future<String> getUserNameByID(String id) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: id)
        .get()
        .then((snapshot) {
      return snapshot.docs.first["name"];
    });
  }

  /// удаляем флаг с отзыва
  static void unFlag(String id) {
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
  static void flag(String id) {
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

  static Future<bool> isAdmin() {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((snapshot) => snapshot.docs.first["isAdmin"]);
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

  static Future<bool> isPinOwner(Pin pin) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: Account.currentAccount!.id)
        .get()
        .then((datasnap) {
      if (datasnap.docs.first["isAdmin"] == true) {
        return true;
      }
      DocumentReference docRef =
          FirebaseFirestore.instance.collection("pins").doc(pin.id);
      return docRef.get().then((datasnapshot) {
        if (datasnapshot['author'].toString() == Account.currentAccount!.id) {
          return true;
        } else {
          return false;
        }
      });
    });
  }

  /// возвращаем все плохие отзывы для админа
  static Stream<List<Review?>> flaggedReviews(BuildContext context) {
    return FirebaseFirestore.instance
        .collection("flags")
        .snapshots()
        .asyncMap((querySnapshot) async {
      Completer<List<Review?>> reviewsCompleter = Completer<List<Review>>();
      List<Review?> reviews = [];
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Review? review = await getReviewByID(
            documentSnapshot["reviewID"] , context);
        reviews.add(review);
      }
      reviewsCompleter.complete(reviews);
      return reviewsCompleter.future;
    });
  }

  /// если админ считает отзыв нормальным - убираем с него флаг
  /// (для конкретного пользователя)
  static void ignoreFlags(String id) {
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
  Future editReview(Review review) async {
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

  /// редактируем пин
  Future editPin(Pin pin) async {
    firebaseInstance.collection("pins").doc(pin.id).set(<String, dynamic>{
      "category": pin.category.text,
      "name": pin.name,
      "imageUrl": pin.imageUrl
    }, SetOptions(merge: true));
    // return true;
  }

  // если админ считает отзыв плохим - удаляем его
  static void deleteReview(Review review) {
    ignoreFlags(review.id!);
    FirebaseFirestore.instance.collection("reviews").doc(review.id).delete();
    addStrike(review.author.id);
  }

  static void deletePin(Pin pin) {
    ignoreFlags(pin.id);
    FirebaseFirestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pin.id)
        .get()
        .then((query) {
      for (var document in query.docs) {
        print("DOCUMENT DELETE");
        document.reference.delete();
      }
    });
    FirebaseFirestore.instance.collection("pins").doc(pin.id).delete();
  }

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
        review.pin = await getPinByID(document["pinID"], context);
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

  ///по id можно определить любимый отзыв это или нет
  static Future<bool> isFavourite(String reviewID) async {
    return getFavouriteReviewsIDs(Account.currentAccount!).then((snapshots) {
      return snapshots.first.then((reviewIDs) {
        return reviewIDs.contains(reviewID);
      });
    });
  }
}
