import 'package:coworking/services/database_map.dart';
import 'package:coworking/models/review.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:coworking/screens/map/new_review_form.dart';

import '../map/map.dart';

//этот класс отвечает за отображение *моих* отзывов
class YourReviewsListItem extends ListTile {
  const YourReviewsListItem({
    this.name,
    this.date,
    this.comment,
    this.location,
    this.photoUrl,
  });

  final String name;
  final DateTime date;
  final String comment;
  final LatLng location;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.network(
            photoUrl,
            height: 100,
            width: 100,
          ),
          Expanded(
            flex: 3,
            child: CustomListItem(
              name: name,
              date: date,
              comment: comment,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.pin_drop_outlined,
              color: Colors.black,
              semanticLabel: "Go to pin",
            ),
            iconSize: 40.0,
            color: Color.fromRGBO(0, 0, 0, 0.3),
            onPressed: () {
              //заменяем страницу в стеке страниц
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            currentMapPosition: location,
                          )));
            },
          ),
        ],
      ),
    );
  }
}

//информация по комментарию пина: флажок\сердечко
//автор, время, сам коммент
class PinListItem extends StatefulWidget {
  const PinListItem(this.review);

  final Review review;

  @override
  _PinListItemState createState() => _PinListItemState();
}

class _PinListItemState extends State<PinListItem> {
  bool isFlagged = false;
  bool isFavourite = false;
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
    DatabaseMap.isFlagged(widget.review.id).then((value) {
      setState(() {
        isFlagged = value;
      });
    });
    DatabaseMap.isFavourite(widget.review.id).then((value) {
      setState(() {
        isFavourite = value;
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
      widget.review.totalRate = NewReviewFormState().countRate(
          widget.review.isFood,
          widget.review.isFree,
          widget.review.isRazors,
          widget.review.isWiFi,
          widget.review.userRate / 2);
      print("NEW TOTAL");
      print(widget.review.totalRate);
      await DatabaseMap().editReview(widget.review);
      oldComment = widget.review.body;
      oldRazors = widget.review.isRazors;
      oldFood = widget.review.isFood;
      oldFree = widget.review.isFree;
      oldWiFi = widget.review.isWiFi;
      oldRate = widget.review.userRate;
      Navigator.of(context).pop(context);
      widget.review.pin.rating =
          await DatabaseMap.updateRateOfPin(widget.review.pin.id);
      Clipboard.setData(ClipboardData(text: widget.review.body));
      Scaffold.of(context).showSnackBar(SnackBar(
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
                future: DatabaseMap.isReviewOwner(widget.review),
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
                                  title: new Text("Изменение отзыва",
                                      textAlign: TextAlign.center),
                                  actions: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.save),
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
                                      text.isEmpty ? "Отзыв обязателен" : null,
                                  maxLines: 3,
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
                                        style:
                                            Theme.of(context).textTheme.subhead,
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
                                              child:
                                                  Text("Можно приобрести еду"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Checkbox(
                                                value: widget.review.isFood,
                                                onChanged: (value) {
                                                  setState(() {
                                                    widget.review.isFood =
                                                        value;
                                                  });
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  "Можно находиться бесплатно"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Checkbox(
                                                value: widget.review.isFree,
                                                onChanged: (value) {
                                                  setState(() {
                                                    widget.review.isFree =
                                                        value;
                                                  });
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text("Есть розетки"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Checkbox(
                                                value: widget.review.isRazors,
                                                onChanged: (value) {
                                                  setState(() {
                                                    widget.review.isRazors =
                                                        value;
                                                  });
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text("Есть WiFi"),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Checkbox(
                                                value: widget.review.isWiFi,
                                                onChanged: (value) {
                                                  setState(() {
                                                    widget.review.isWiFi =
                                                        value;
                                                  });
                                                },
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
                                                validator: (input) =>
                                                    input.isEmpty
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
                                  child: RaisedButton(
                                    onPressed: () async {
                                      DatabaseMap.deleteReview(widget.review);
                                      Navigator.pop(context);
                                      widget.review.pin.rating =
                                          await DatabaseMap.updateRateOfPin(
                                              widget.review.pin.id);
                                    },
                                    child: Text(
                                      'Удалить',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.0,
                                      ),
                                    ),
                                    color: Colors.red,
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
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
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
                                                formatDate(
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
                                                .subhead,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(
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
                      (snapshot.hasData) ? snapshot.data : "Anonymous",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    formatDate(widget.review.timestamp),
                    style: TextStyle(color: Colors.black.withOpacity(0.4)),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFlagged ? Icons.flag : Icons.outlined_flag,
                  semanticLabel: "Flagged",
                ),
                onPressed: () {
                  if (isFlagged) {
                    DatabaseMap.unFlag(widget.review.id);
                  } else {
                    DatabaseMap.flag(widget.review.id);
                  }
                  setState(() {
                    isFlagged = !isFlagged;
                  });
                },
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFavourite ? Icons.star : Icons.star_border,
                  semanticLabel: "Favourite",
                ),
                onPressed: () {
                  if (isFavourite) {
                    DatabaseMap.removeFavourite(widget.review.id);
                  } else {
                    DatabaseMap.addFavourite(widget.review.id);
                  }
                  setState(() {
                    isFavourite = !isFavourite;
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

String formatDate(DateTime timestamp) =>
    timestamp.day.toString().padLeft(2, '0') +
    "/" +
    timestamp.month.toString().padLeft(2, '0') +
    "/" +
    timestamp.year.toString() +
    " " +
    timestamp.hour.toString().padLeft(2, '0') +
    ":" +
    timestamp.minute.toString().padLeft(2, '0');

class CustomListItem extends ListTile {
  const CustomListItem({
    this.name,
    this.date,
    this.comment,
  });

  final bool enabled = true;
  final String name;
  final DateTime date;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Место: " + name,
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
            ),
            SizedBox(
              height: 10,
            ),
            Container(width: 200, child: Text("Отзыв: " + comment)),
            Text(
              formatDate(date),
              style: TextStyle(color: Colors.black.withOpacity(0.4)),
            ),
          ]),
    );
  }
}

// Любимые отзывы
class StarredReviewsListItem extends ListTile {
  const StarredReviewsListItem(this.review, this.location);

  final LatLng location;
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: CustomListItem(
              name: review.pin.name,
              date: review.timestamp,
              comment: review.body,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.pin_drop_outlined,
              color: Colors.black,
              semanticLabel: "Go to pin",
            ),
            iconSize: 40.0,
            color: Color.fromRGBO(0, 0, 0, 0.3),
            onPressed: () {
              //заменяем страницу в стеке страниц
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            currentMapPosition: location,
                          )));
            },
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.star,
              semanticLabel: "Remove",
            ),
            iconSize: 30.0,
            onPressed: () {
              DatabaseMap.removeFavourite(review.id);
            },
          ),
        ],
      ),
    );
  }
}

//жалобы на отзывы. Показываются только админу
//Админ устанавливается напрямую через firebase. Вкладка появляется
//в левом меню.
class FlaggedReviewsListItem extends ListTile {
  const FlaggedReviewsListItem(this.review);

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: CustomListItem(
              name: review.pin.name,
              date: review.timestamp,
              comment: review.body,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.check_circle,
              color: Colors.green,
              semanticLabel: "Allow",
            ),
            iconSize: 40.0,
            color: Colors.grey[600],
            onPressed: () {
              DatabaseMap.ignoreFlags(review.id);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              semanticLabel: "Delete",
            ),
            iconSize: 40.0,
            color: Colors.red,
            onPressed: () {
              DatabaseMap.deleteReview(review);
            },
          ),
        ],
      ),
    );
  }
}
