import 'package:coworking/domain/entities/pin.dart';
import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/screens/map/pin/pin_form.dart';
import 'package:coworking/screens/map/pin/review/review_form.dart';
import 'package:flutter/material.dart';

class CreatePin extends StatefulWidget {
  const CreatePin(this.drawerHeight, {super.key});
  final double drawerHeight;

  @override
  State<CreatePin> createState() => CreatePinState();
}

class CreatePinState extends State<CreatePin> with SingleTickerProviderStateMixin {
  late TabController tabController;

  late GlobalKey<PinFormState> pinFormKey;
  late GlobalKey<ReviewFormState> reviewFormKey;
  late PinForm pinForm;
  late ReviewForm reviewForm;

  bool validate() {
    if (!pinFormKey.currentState!.isValid) {
      tabController.animateTo(0);
      return false;
    }
    if (reviewFormKey.currentState == null || !reviewFormKey.currentState!.isValid) {
      tabController
        ..animateTo(1)
        ..addListener(() => reviewFormKey.currentState!.isValid);
      return false;
    }

    return true;
  }

  Future<Pin> createPin() async {
    final Review review = reviewFormKey.currentState!.getReview();
    return pinFormKey.currentState!.createPin(review);
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    pinFormKey = GlobalKey<PinFormState>();
    reviewFormKey = GlobalKey<ReviewFormState>();
    pinForm = PinForm(key: pinFormKey);
    reviewForm = ReviewForm(key: reviewFormKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.drawerHeight,
      child: TabBarView(
        controller: tabController,
        children: [
          pinForm,
          reviewForm,
        ],
      ),
    );
  }
}
