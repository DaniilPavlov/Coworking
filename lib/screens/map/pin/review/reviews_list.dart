import 'package:coworking/services/database_pin.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/services/database_review.dart';
import 'package:coworking/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:coworking/screens/map/pin/review/review_form.dart';

//информация по комментарию пина: флажок\сердечко
//автор, время, сам коммент
class PinListItem extends StatefulWidget {
  final Review review;

  const PinListItem(this.review, {Key? key}) : super(key: key);

  @override
  _PinListItemState createState() => _PinListItemState();
}

class _PinListItemState extends State<PinListItem> {
  bool isFlagged = false;

  String oldComment = "";
  var oldRazors = false;
  var oldFood = false;
  var oldFree = false;
  var oldWiFi = false;
  var oldRate = 0.0;
  var rateController = TextEditingController();
  var reviewController = TextEditingController();

  @override
  void initState() {
    DatabaseReview.isFlagged(widget.review.id).then((value) {
      setState(() {
        isFlagged = value;
      });
    });
    oldComment = widget.review.body;
    oldRazors = widget.review.isRazors;
    oldFood = widget.review.isFood;
    oldFree = widget.review.isFree;
    oldWiFi = widget.review.isWiFi;
    oldRate = widget.review.userRate;
    rateController.text = widget.review.userRate.toString();
    reviewController.text = widget.review.body;
    super.initState();
  }

  ///нужно поднять ошибки при неудачном сохранении
  void _saveReview() async {
    final RegExp shutterSpeedRegEx =
        RegExp("[0-9]([0-9]*)((\\.[0-9][0-9]*)|\$)");

    //можно оставить оценку без отзыва, возможно есть смысл оставить, иначе меняем бади на контроллер
    if (widget.review.body != "" &&
        widget.review.userRate.toString() != "" &&
        shutterSpeedRegEx.hasMatch(widget.review.userRate.toString()) &&
        (double.parse(rateController.text) <= 10 ||
            double.parse(rateController.text) > 0)) {
      widget.review.body = reviewController.text;
      widget.review.userRate = double.parse(rateController.text);
      widget.review.totalRate = ReviewFormState().countRate(
          widget.review.isFood,
          widget.review.isFree,
          widget.review.isRazors,
          widget.review.isWiFi,
          widget.review.userRate / 2);
      print("NEW TOTAL");
      print(widget.review.totalRate);
      await DatabaseReview.editReview(widget.review);
      oldComment = widget.review.body;
      oldRazors = widget.review.isRazors;
      oldFood = widget.review.isFood;
      oldFree = widget.review.isFree;
      oldWiFi = widget.review.isWiFi;
      oldRate = widget.review.userRate;
      Navigator.of(context).pop(context);
      widget.review.pin!.rating =
          await DatabasePin.updateRateOfPin(widget.review.pin!.id);
      Clipboard.setData(ClipboardData(text: widget.review.body));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.review.body),
      ));
    } else {
      widget.review.body = oldComment;
      widget.review.isRazors = oldRazors;
      widget.review.isFood = oldFood;
      widget.review.isFree = oldFree;
      widget.review.isWiFi = oldWiFi;
      widget.review.userRate = oldRate;
      rateController.text = oldRate.toString();
      reviewController.text = oldComment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: InkWell(
        onTap: () => showModalBottomSheet(
            context: context,
            builder: (_) => FutureBuilder(
                future: DatabaseReview.isReviewOwner(widget.review),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return (snapshot.data == true)
                        ? WillPopScope(
                            onWillPop: () async {
                              setState(() {
                                widget.review.body = oldComment;
                                widget.review.isRazors = oldRazors;
                                widget.review.isFood = oldFood;
                                widget.review.isFree = oldFree;
                                widget.review.isWiFi = oldWiFi;
                                widget.review.userRate = oldRate;
                                rateController.text = oldRate.toString();
                                reviewController.text = oldComment;
                              });
                              return true;
                            },
                            child: Scaffold(
                              appBar: AppBar(
                                  title: const Text("Изменение отзыва",
                                      textAlign: TextAlign.center),
                                  actions: <Widget>[
                                    IconButton(
                                      icon: const Icon(Icons.save),
                                      onPressed: () {
                                        _saveReview();
                                      },
                                    ),
                                  ]),
                              body: SingleChildScrollView(
                                  child: Column(children: <Widget>[
                                TextFormField(
                                  controller: reviewController,
                                  validator: (text) =>
                                      text!.isEmpty ? "Отзыв обязателен" : null,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: "Отзыв",
                                    contentPadding: EdgeInsets.all(8.0),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(children: <Widget>[
                                      Text(
                                        "Раздел оценки места",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                        textAlign: TextAlign.left,
                                      ),

                                      /// добавляю стейтфул, чтобы чек боксы изменялись. иначе они не обновляются
                                      StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return GridView.count(
                                          childAspectRatio: 5,
                                          crossAxisCount: 2,
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: const Text(
                                                  "Можно приобрести еду"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Checkbox(
                                                value: widget.review.isFood,
                                                onChanged: (value) {
                                                  setState(() {
                                                    widget.review.isFood =
                                                        value!;
                                                  });
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: const Text(
                                                  "Можно находиться бесплатно"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Checkbox(
                                                value: widget.review.isFree,
                                                onChanged: (value) {
                                                  setState(() {
                                                    widget.review.isFree =
                                                        value!;
                                                  });
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: const Text("Есть розетки"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Checkbox(
                                                value: widget.review.isRazors,
                                                onChanged: (value) {
                                                  setState(() {
                                                    widget.review.isRazors =
                                                        value!;
                                                  });
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: const Text("Есть WiFi"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Checkbox(
                                                value: widget.review.isWiFi,
                                                onChanged: (value) {
                                                  setState(() {
                                                    widget.review.isWiFi =
                                                        value!;
                                                  });
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: const Text(
                                                  "Ваша личная оценка места (введите число от 0 до 10)"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: TextFormField(
                                                textAlign: TextAlign.center,
                                                controller: rateController,
                                                validator: (input) =>
                                                    input!.isEmpty
                                                        ? "Оценка обязательна"
                                                        : null,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ])),
                                ButtonTheme(
                                  minWidth: 120.0,
                                  height: 50.0,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      DatabaseReview.deleteReview(
                                          widget.review);
                                      Navigator.pop(context);
                                      widget.review.pin?.rating =
                                          await DatabasePin.updateRateOfPin(
                                              widget.review.pin?.id);
                                    },
                                    child: const Text(
                                      'Удалить',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.0,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Theme.of(context).errorColor),
                                    ),
                                  ),
                                ),
                              ])),
                            ),
                          )

                        //TODO ЗДЕСЬ УВЕЛИЧИТЬ КОЛВО ДАННЫХ НА НАЖАТИИ ОТЗЫВА
                        : Scaffold(
                            body: SingleChildScrollView(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: const <Widget>[
                                            Expanded(
                                              child: Text(
                                                "Информация об отзыве:",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    color: Colors.black),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, left: 8.0, right: 8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(widget.review.body),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                FormatDate.formatDate(
                                                    widget.review.timestamp),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Личная оценка пользователя: " +
                                                widget.review.userRate
                                                    .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Divider(
              color: Colors.orange,
              thickness: 2,
            ),
            Text(
              widget.review.body,
              textScaleFactor: 1.1,
            ),
            Row(children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FutureBuilder(
                    future: widget.review.author.userName,
                    builder: (_, snapshot) => Text(
                      (snapshot.hasData)
                          ? snapshot.data.toString()
                          : "Anonymous",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    FormatDate.formatDate(widget.review.timestamp),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFlagged ? Icons.flag : Icons.outlined_flag,
                  semanticLabel: "Flagged",
                ),
                onPressed: () {
                  if (isFlagged) {
                    DatabaseReview.removeFlag(widget.review.id!);
                  } else {
                    DatabaseReview.addFlag(widget.review.id!);
                  }
                  setState(() {
                    isFlagged = !isFlagged;
                  });
                },
              ),
            ])
          ],
        ),
      ),
    );
  }
}
