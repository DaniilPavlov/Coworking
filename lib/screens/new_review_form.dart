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
  TextEditingController rateController;
  bool isFood = false;
  bool isFree = false;
  bool isRazors = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    reviewController = TextEditingController();
    rateController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            TextFormField(
              controller: reviewController,
              validator: (text) => text.isEmpty ? "Отзыв обязателен" : null,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Отзыв",
                contentPadding: EdgeInsets.all(8.0),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: <Widget>[
                  Text(
                    "Раздел оценки места",
                    style: Theme.of(context).textTheme.subhead,
                    textAlign: TextAlign.left,
                  ),
                  GridView.count(
                    childAspectRatio: 4,
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Можно приобрести еду"),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Checkbox(
                          value: isFood,
                          onChanged: (value) {
                            setState(() {
                              isFood = value;
                            });
                          },
                          tristate: false,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Можно находиться бесплатно"),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Checkbox(
                          value: isFree,
                          onChanged: (value) {
                            setState(() {
                              isFree = value;
                            });
                          },
                          tristate: false,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Есть розетки"),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Checkbox(
                          value: isRazors,
                          onChanged: (value) {
                            setState(() {
                              isRazors = value;
                            });
                          },
                          tristate: false,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Ваша личная оценка места"),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: rateController,
                          validator: (input) {
                            final RegExp shutterSpeedRegEx =
                                RegExp("[0-9]([0-9]*)((\\.[0-9][0-9]*)|\$)");
                            if (input.length == 0)
                              return null;
                            else if (!shutterSpeedRegEx.hasMatch(input)) {
                              return "Оценка должна быть числовым форматом.";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ])),
          ]),
        ));
  }

  bool get isValid => formKey.currentState.validate();

  Review getReview() {
    formKey.currentState.save();
    return Review(
        null,
        Account.currentAccount,
        this.reviewController.text,
        DateTime.now(),
        isFood,
        isFree,
        isRazors,
        int.parse(rateController.text));
  }
}
