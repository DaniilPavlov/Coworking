import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/domain/services/database_pin.dart';
import 'package:coworking/domain/services/database_review.dart';
import 'package:coworking/screens/map/pin/review/review_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewWidgetModel extends ChangeNotifier {
  Review review;
  ReviewWidgetModel({required this.review}) {
    _asyncInit();
  }

  bool isFlagged = false;
  var rateController = TextEditingController();
  var reviewTextController = TextEditingController();

  Future _asyncInit() async {
    await DatabaseReview.isFlagged(review.id).then((value) {
      isFlagged = value;
    });
    rateController.text = review.userRate.toString();
    reviewTextController.text = review.body;
  }

  Future<bool> saveReview() async {
    final RegExp shutterSpeedRegEx =
        RegExp("[0-9]([0-9]*)((\\.[0-9][0-9]*)|\$)");

    if (review.body != "" &&
        review.userRate.toString() != "" &&
        shutterSpeedRegEx.hasMatch(review.userRate.toString()) &&
        (double.parse(rateController.text) <= 10 ||
            double.parse(rateController.text) > 0)) {
      review.body = reviewTextController.text;
      review.userRate = double.parse(rateController.text);
      review.totalRate = ReviewFormState().countRate(review.isFood,
          review.isFree, review.isRazors, review.isWiFi, review.userRate / 2);
      print("NEW TOTAL ${review.totalRate}");
      await DatabaseReview.editReview(review);
      //TODO заменил ! на ?
      review.pin?.rating = await DatabasePin.updateRateOfPin(review.pin?.id);
      notifyListeners();
      return false;
    } else {
      notifyListeners();
      return true;
    }
  }

  void setFlagged() {
    DatabaseReview.addFlag(review.id!);
    notifyListeners();
  }

  void setUnflagged() {
    DatabaseReview.removeFlag(review.id!);
    notifyListeners();
  }
}
