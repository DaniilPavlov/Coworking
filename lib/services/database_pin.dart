import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/services/database_review.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:coworking/models/account.dart';
import 'package:coworking/models/category.dart';

class PinChange {
  DocumentChangeType type;
  Pin pin;

  PinChange(this.type, this.pin);
}

class DatabasePin {
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
        print("Pin name   " + document["name"]);
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
          document["rating"],
          context,
          review: (documentChange.type == DocumentChangeType.added)
              ? await DatabaseReview.getFirstReview(document.id)
              : null,
        );
        pinChanges.add(PinChange(documentChange.type, pin));
      }
      pinsListCompleter.complete(pinChanges);
      return pinsListCompleter.future;
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
        pins.add(visitedMap["pin"]);
      }
      return pins;
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

  /// редактируем пин
  Future editPin(Pin pin) async {
    firebaseInstance.collection("pins").doc(pin.id).set(<String, dynamic>{
      "category": pin.category.text,
      "name": pin.name,
      "imageUrl": pin.imageUrl
    }, SetOptions(merge: true));
    // return true;
  }

  static void deletePin(Pin pin) {
    DatabaseReview.justifyFlag(pin.id);
    FirebaseStorage.instance.refFromURL(pin.imageUrl).delete();
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

  static Future<Stream<List<Pin>>> favouritePinsForUser(
      Account account, BuildContext context) {
    return getFavouritePinsIDs(account).then((idStream) {
      return idStream
          .asyncMap((snapshot) => getPinsByPinIDs(snapshot, context));
    });
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
        await DatabaseReview.getFirstReview(pinID),
        context);
  }

  static Future<List<Pin>> getPinsByPinIDs(
      List<String> pinIDs, BuildContext context) {
    return FirebaseFirestore.instance
        .collection("pins")
        .where(FieldPath.documentId, whereIn: pinIDs)
        .get()
        .then((snapshot) async {
      List<Pin> pins = [];
      for (DocumentSnapshot document in snapshot.docs) {
        Pin pin = await DatabasePin.getPinByID(document.id, context);
        pins.add(pin);
      }
      return pins;
    });
  }

  static Future<Stream<List<String>>> getFavouritePinsIDs(Account account) {
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
        List<String> pinIDs = [];
        for (DocumentSnapshot document in snapshot.docs) {
          pinIDs.add(document.id);
        }
        return pinIDs;
      });
    });
  }

  static void addFavourite(String pinID) async {
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

    await favouritesRef.doc(pinID).set(newFavouriteMap());
  }

  static Map<String, dynamic> newFavouriteMap() {
    Map<String, dynamic> favourite = <String, dynamic>{};
    return favourite;
  }

  static void removeFavourite(String pinId) {
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
          .doc(pinId)
          .delete();
    });
  }

  static Future<bool> isFavourite(String pinId) async {
    return getFavouritePinsIDs(Account.currentAccount!).then((snapshots) {
      return snapshots.first.then((pinIds) {
        return pinIds.contains(pinId);
      });
    });
  }
}
