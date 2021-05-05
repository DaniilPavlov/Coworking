import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/review.dart';

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
  bool isWiFi = false;

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
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Отзыв",
                contentPadding: EdgeInsets.all(10.0),
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
                    childAspectRatio: 5,
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
                        child: Text("Есть WiFi"),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Checkbox(
                          value: isWiFi,
                          onChanged: (value) {
                            setState(() {
                              isWiFi = value;
                            });
                          },
                          tristate: false,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "Ваша личная оценка места (введите число от 0 до 10)"),
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
                              return "Вы не ввели оценку";
                            else if (!shutterSpeedRegEx.hasMatch(input))
                              return "Введите число";
                            else if (double.parse(rateController.text) > 10 ||
                                double.parse(rateController.text) < 0)
                              return "От 0 до 10";
                            else
                              return null;
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

  double countRate(
      bool isFood, bool isFree, bool isRazors, bool isWiFi, double userRate) {
    double totalRate = 1;
    if (isFood) totalRate++;
    if (isFree) totalRate++;
    if (isRazors) totalRate++;
    if (isWiFi) totalRate++;
    totalRate = totalRate + userRate;
    totalRate = double.parse(totalRate.toStringAsFixed(2));
    print(totalRate);
    return totalRate;
  }

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
        isWiFi,
        double.parse(this.rateController.text),
        countRate(isFood, isFree, isRazors, isWiFi,
            (double.parse(this.rateController.text) / 2)));
  }
}
