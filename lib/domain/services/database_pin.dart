import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/domain/entities/account.dart';
import 'package:coworking/domain/entities/category.dart';
import 'package:coworking/domain/entities/pin.dart';
import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/domain/services/database_review.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinChange {
  DocumentChangeType type;
  Pin pin;

  PinChange(this.type, this.pin);
}

class DatabasePin {
  var firebaseInstance = FirebaseFirestore.instance;

  static Stream<List<PinChange>> fetchPins(BuildContext context) {
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
              ? await DatabaseReview.fetchFirstReview(document.id)
              : null,
        );
        pinChanges.add(PinChange(documentChange.type, pin));
      }
      pinsListCompleter.complete(pinChanges);
      return pinsListCompleter.future;
    });
  }

  static Stream<double> fetchPin(String pinID) {
    return FirebaseFirestore.instance
        .collection("pins")
        .doc(pinID)
        .snapshots()
        .asyncMap((query) async {
      Completer<double> ratingCompleter = Completer<double>();
      Map<String, dynamic> pinMap = query.data() as Map<String, dynamic>;
      ratingCompleter.complete(pinMap["rating"]);
      return ratingCompleter.future;
    });
  }

  static Stream<List<double>> calculateThreeMonthRate(String pinID) {
    return FirebaseFirestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pinID)
        .where('dateAdded',
            isGreaterThanOrEqualTo:
                DateTime.now().subtract(const Duration(days: 90)))
        .snapshots()
        .asyncMap((query) async {
      List<double> threeMonth = [];
      double rating = 0.0;
      double isFood = 0.0;
      double isFree = 0.0;
      double isRazors = 0.0;
      double isWiFi = 0.0;
      Completer<List<double>> rateCompleter = Completer<List<double>>();
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
      rateCompleter.complete(threeMonth);
      return rateCompleter.future;
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
      rating = double.parse(rating.toStringAsFixed(2));
      docRef.update(<String, dynamic>{"rating": rating});
      print("RATING " + rating.toString());
      return rating;
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
    var timeKey = DateTime.now();
    final Reference postImageRef =
        FirebaseStorage.instance.ref().child("Pin Images");
    final UploadTask uploadTask =
        postImageRef.child(timeKey.toString() + ".jpg").putFile(image);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    DocumentReference newPin = await FirebaseFirestore.instance
        .collection("pins")
        .add(Pin.newPinMap(
            name, location, author, imageUrl, category, review.totalRate));

    //создаем map для отзыва
    Map<String, dynamic> initialReviewMap =
        Review.newReviewMap(review, newPin.id);

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

  Future editPin(Pin pin) async {
    firebaseInstance.collection("pins").doc(pin.id).set(<String, dynamic>{
      "category": pin.category.text,
      "name": pin.name,
      "imageUrl": pin.imageUrl
    }, SetOptions(merge: true));
  }

  static void deletePin(Pin pin) {
    DatabaseReview.justifyFlag(pin.id);
    FirebaseStorage.instance.refFromURL(pin.imageUrl).delete();
    FirebaseFirestore.instance.collection("users").get().then((query) {
      for (var document in query.docs) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(document.id)
            .collection("favourites")
            .doc(pin.id)
            .delete();
      }
    });
    FirebaseFirestore.instance
        .collection("reviews")
        .where("pinID", isEqualTo: pin.id)
        .get()
        .then((query) {
      for (var document in query.docs) {
        document.reference.delete();
      }
    });
    FirebaseFirestore.instance.collection("pins").doc(pin.id).delete();
  }

  static Future<Stream<List<Pin>>> fetchFavouritePinsForUser(
      Account account, BuildContext context) {
    return fethcFavouritePinsIDs(account).then((idStream) {
      return idStream.asyncMap((snapshot) => fetchPinsByIDs(snapshot, context));
    });
  }

  static Future<Pin> fetchPinByID(String pinID, BuildContext context) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("pins")
        .where(FieldPath.documentId, isEqualTo: pinID)
        .snapshots()
        .first;
    return Pin.fromMap(
        pinID,
        snapshot.docs.first.data() as Map<String, dynamic>,
        await DatabaseReview.fetchFirstReview(pinID),
        context);
  }

  static Future<List<Pin>> fetchPinsByIDs(
      List<String> pinIDs, BuildContext context) {
    return FirebaseFirestore.instance
        .collection("pins")
        .where(FieldPath.documentId, whereIn: pinIDs)
        .get()
        .then((snapshot) async {
      List<Pin> pins = [];
      for (DocumentSnapshot document in snapshot.docs) {
        Pin pin = await DatabasePin.fetchPinByID(document.id, context);
        pins.add(pin);
      }
      return pins;
    });
  }

  static Future<Stream<List<String>>> fethcFavouritePinsIDs(Account account) {
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

  static Future<int> fetchFavouritePinsAmount() async {
    return fethcFavouritePinsIDs(Account.currentAccount!).then((snapshots) {
      return snapshots.first.then((pinIds) {
        return pinIds.length;
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
    await favouritesRef.doc(pinID).set(<String, dynamic>{});
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
    return fethcFavouritePinsIDs(Account.currentAccount!).then((snapshots) {
      return snapshots.first.then((pinIds) {
        return pinIds.contains(pinId);
      });
    });
  }
}
