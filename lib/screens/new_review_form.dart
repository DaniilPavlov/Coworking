import 'package:flutter/material.dart';
import 'package:coworking/resources/account.dart';
import 'package:coworking/resources/review.dart';

class NewReviewForm extends StatefulWidget {
  NewReviewForm({Key key}) : super(key: key);

  State<NewReviewForm> createState() => NewReviewFormState();
}

class NewReviewFormState extends State<NewReviewForm>
    with AutomaticKeepAliveClientMixin<NewReviewForm> {
  GlobalKey<FormState> formKey;

  TextEditingController reviewController;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    reviewController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child:
          TextFormField(
            controller: reviewController,
            validator: (text) => text.isEmpty ? "Отзыв обязателен" : null,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Отзыв",
              contentPadding: EdgeInsets.all(8.0),
            ),
          ),
      ),
    );
  }

  bool get isValid => formKey.currentState.validate();

  Review getReview() {
    formKey.currentState.save();
    return Review(
      null,
      Account.currentAccount,
      this.reviewController.text,
      DateTime.now(),
      //счетчик флагов по отзыву
      0,
    );
  }
}
