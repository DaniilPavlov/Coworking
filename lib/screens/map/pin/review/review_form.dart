import 'package:coworking/domain/entities/account.dart';
import 'package:coworking/domain/entities/review.dart';
import 'package:flutter/material.dart';

late TextEditingController rateController;
bool isFood = false;
bool isFree = false;
bool isRazors = false;
bool isWiFi = false;

class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key});

  @override
  State<ReviewForm> createState() => ReviewFormState();
}

class ReviewFormState extends State<ReviewForm> with AutomaticKeepAliveClientMixin<ReviewForm> {
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
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                controller: reviewController,
                validator: (text) => text!.isEmpty ? 'Отзыв обязателен' : null,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Отзыв',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
              child: Column(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      'Раздел оценки места',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _PlaceRateSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isValid => formKey.currentState!.validate();

  double countRate(bool isFood, bool isFree, bool isRazors, bool isWiFi, double userRate) {
    double totalRate = 1;
    if (isFood) totalRate++;
    if (isFree) totalRate++;
    if (isRazors) totalRate++;
    if (isWiFi) totalRate++;
    totalRate = totalRate + userRate;
    totalRate = double.parse(totalRate.toStringAsFixed(2));
    debugPrint(totalRate.toString());
    return totalRate;
  }

  Review getReview() {
    formKey.currentState!.save();
    return Review(
      'null',
      Account.currentAccount!,
      reviewController.text,
      DateTime.now(),
      isFood,
      isFree,
      isRazors,
      isWiFi,
      double.parse(rateController.text),
      countRate(
        isFood,
        isFree,
        isRazors,
        isWiFi,
        double.parse(rateController.text) / 2,
      ),
    );
  }
}

class _PlaceRateSection extends StatefulWidget {
  const _PlaceRateSection();

  @override
  _PlaceRateSectionState createState() => _PlaceRateSectionState();
}

class _PlaceRateSectionState extends State<_PlaceRateSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          childAspectRatio: 4,
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Можно приобрести еду'),
            ),
            Container(
              alignment: Alignment.center,
              child: Checkbox(
                value: isFood,
                activeColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    isFood = value!;
                  });
                },
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Можно находиться бесплатно'),
            ),
            Container(
              alignment: Alignment.center,
              child: Checkbox(
                value: isFree,
                activeColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    isFree = value!;
                  });
                },
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Есть розетки'),
            ),
            Container(
              alignment: Alignment.center,
              child: Checkbox(
                activeColor: Colors.orange,
                value: isRazors,
                onChanged: (value) {
                  setState(() {
                    isRazors = value!;
                  });
                },
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Есть WiFi'),
            ),
            Container(
              alignment: Alignment.center,
              child: Checkbox(
                activeColor: Colors.orange,
                value: isWiFi,
                onChanged: (value) {
                  setState(() {
                    isWiFi = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(top: 10),
          alignment: Alignment.centerLeft,
          child: const Text('Ваша личная оценка места (введите число от 0 до 10)'),
        ),
        Container(
          alignment: Alignment.center,
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: rateController,
            maxLength: 4,
            validator: (input) {
              final RegExp shutterSpeedRegEx = RegExp(r'[0-9]([0-9]*)((\.[0-9][0-9]*)|$)');
              if (input!.isEmpty) {
                return 'Вы не ввели оценку';
              } else if (!shutterSpeedRegEx.hasMatch(input)) {
                return 'Введите число';
              } else if (double.parse(rateController.text) > 10 || double.parse(rateController.text) < 0) {
                return 'От 0 до 10';
              } else {
                return null;
              }
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
