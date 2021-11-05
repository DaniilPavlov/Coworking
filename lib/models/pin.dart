import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/models/review.dart';

import 'package:coworking/screens/map/pin_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/category.dart';
import 'package:coworking/services/database_map.dart';

class Pin {
  String id;
  LatLng location;
  final Account author;
  String name;
  String imageUrl;
  Marker? marker;
  final Category _category;
  final Set<Review> _reviews = <Review>{};
  int _visitorCount = 0;
  double rating;

  Pin(
    this.id,
    this.location,
    this.author,
    this.name,
    this.imageUrl,
    this._category,
    this.rating,
    BuildContext context, {
    tags,
    Review? review,
  }) {
    marker = _createMarker(context);
    if (review != null) {
      _reviews.add(review);
      review.pin = this;
    }
  }

  Category get category => _category;

  Set<Review> get reviews => _reviews;

  ///добавляем ревью в базу
  void addReview(Review review) {
    _reviews.add(review);
    review.pin = this;
    DatabaseMap.addReview(review);
  }

  int get visitorCount => _visitorCount;

  void incVisitorCount() {
    _visitorCount++;
    // TODO: update DB
  }

  void showPinInfo(context) {
    Navigator.push(
      context  ,
      MaterialPageRoute(
        builder: (_) => PinInfo(this, imageUrl),
        fullscreenDialog: true,
      ),
    );
  }

  Marker _createMarker(BuildContext context) {
    return Marker(
      markerId: MarkerId(id),
      position: location,
      onTap: () => showPinInfo(context),
    );
  }

  static Map<String, dynamic> newPinMap(
    String name,
    LatLng location,
    Account author,
    String imageUrl,
    Category category,
    double rating,
  ) {
    Map<String, dynamic> pin = {};
    pin["name"] = name;
    pin["location"] = GeoPoint(location.latitude, location.longitude);
    pin["visitorCount"] = 0;
    pin["author"] = author.id;
    pin["imageUrl"] = imageUrl;
    pin["category"] = category.text;
    pin["rating"] = rating;
    return pin;
  }

  static Pin fromMap(String id, Map<String, dynamic> pinMap, Review? review,
      BuildContext context) {
    return Pin(
      id,
      LatLng(pinMap["location"].latitude ,
          pinMap["location"].longitude  ),
      Account(pinMap["author"]  ),
      pinMap["name"]  ,
      pinMap["imageUrl"]  ,
      Category.find(pinMap["category"]  ),
      pinMap["rating"]  ,
      context,
      review: review,
    );
  }
}
