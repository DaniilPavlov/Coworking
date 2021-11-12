import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/review.dart';

late TextEditingController rateController;
bool isFood = false;
bool isFree = false;
bool isRazors = false;
bool isWiFi = false;

class ReviewForm extends StatefulWidget {
  const ReviewForm({Key? key}) : super(key: key);

  @override
  State<ReviewForm> createState() => ReviewFormState();
}

class ReviewFormState extends State<ReviewForm>
    with AutomaticKeepAliveClientMixin<ReviewForm> {
  late GlobalKey<FormState> formKey;

  late TextEditingController reviewController;

  @override
  void dispose() {
    isFood = false;
    isFree = false;
    isRazors = false;
    isWiFi = false;
    rateController.dispose();
    super.dispose();
  }

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
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextFormField(
                controller: reviewController,
                validator: (text) => text!.isEmpty ? "Отзыв обязателен" : null,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Отзыв",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
              child: Column(
                children: <Widget>[
                  Text(
                    "Раздел оценки места",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const PlaceRateSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isValid => formKey.currentState!.validate();

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
    formKey.currentState!.save();
    return Review(
        //tODO проверить
        "null",
        Account.currentAccount!,
        reviewController.text,
        DateTime.now(),
        isFood,
        isFree,
        isRazors,
        isWiFi,
        double.parse(rateController.text),
        countRate(isFood, isFree, isRazors, isWiFi,
            (double.parse(rateController.text) / 2)));
  }
}

class PlaceRateSection extends StatefulWidget {
  const PlaceRateSection({
    Key? key,
  }) : super(key: key);

  @override
  _PlaceRateSectionState createState() => _PlaceRateSectionState();
}

class _PlaceRateSectionState extends State<PlaceRateSection> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 5,
      crossAxisCount: 2,
      shrinkWrap: true,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: const Text("Можно приобрести еду"),
        ),
        Container(
          alignment: Alignment.center,
          child: Checkbox(
            value: isFood,
            onChanged: (value) {
              setState(() {
                isFood = value!;
              });
            },
            tristate: false,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: const Text("Можно находиться бесплатно"),
        ),
        Container(
          alignment: Alignment.center,
          child: Checkbox(
            value: isFree,
            onChanged: (value) {
              setState(() {
                isFree = value!;
              });
            },
            tristate: false,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: const Text("Есть розетки"),
        ),
        Container(
          alignment: Alignment.center,
          child: Checkbox(
            value: isRazors,
            onChanged: (value) {
              setState(() {
                isRazors = value!;
              });
            },
            tristate: false,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: const Text("Есть WiFi"),
        ),
        Container(
          alignment: Alignment.center,
          child: Checkbox(
            value: isWiFi,
            onChanged: (value) {
              setState(() {
                isWiFi = value!;
              });
            },
            tristate: false,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child:
              const Text("Ваша личная оценка места (введите число от 0 до 10)"),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: rateController,
            maxLength: 4,
            validator: (input) {
              final RegExp shutterSpeedRegEx =
                  RegExp("[0-9]([0-9]*)((\\.[0-9][0-9]*)|\$)");
              if (input!.isEmpty) {
                return "Вы не ввели оценку";
              } else if (!shutterSpeedRegEx.hasMatch(input)) {
                return "Введите число";
              } else if (double.parse(rateController.text) > 10 ||
                  double.parse(rateController.text) < 0) {
                return "От 0 до 10";
              } else {
                return null;
              }
            },
          ),
        ),
      ],
    );
  }
}
