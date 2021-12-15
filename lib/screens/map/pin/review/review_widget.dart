import 'package:coworking/domain/services/database_pin.dart';
import 'package:coworking/domain/services/database_review.dart';
import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/screens/map/pin/review/review_widget_model.dart';
import 'package:coworking/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewWidget extends StatelessWidget {
  final Review review;

  const ReviewWidget({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => ReviewWidgetModel(review: review),
        lazy: true,
        child: const _ReviewWidgetView(),
      );
}

class _ReviewWidgetView extends StatelessWidget {
  const _ReviewWidgetView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (_) {
            return ChangeNotifierProvider.value(
              value: model,
              child: FutureBuilder(
                future: DatabaseReview.isReviewOwner(model.review),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return (snapshot.data == true)
                        ? const _AuthorsReviewInfoWidget()
                        : const _OthersReviewInfoWidget();
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            );
          },
        ),
        child: _ReviewTileWidget(),
      ),
    );
  }
}

class _AuthorsReviewInfoWidget extends StatelessWidget {
  const _AuthorsReviewInfoWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text("Изменение отзыва", textAlign: TextAlign.center),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                var errorSave = await model.saveReview();
                if (errorSave) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Вы заполнили не всю информацию"),
                  ));
                } else {
                  Navigator.of(context).pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Информация отзыва изменена"),
                  ));
                }
              },
            ),
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: model.reviewTextController,
              validator: (text) => text!.isEmpty ? "Отзыв обязателен" : null,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Отзыв",
                contentPadding: EdgeInsets.all(8.0),
              ),
            ),

            ///TODO сложности с выносом грид вью из-за чек боксов
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Раздел оценки места",
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.left,
                  ),

                  /// добавляю стейтфул, чтобы чек боксы изменялись. иначе они не обновляются
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
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
                              value: model.review.isFood,
                              onChanged: (value) {
                                model.review.isFood = value!;
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: const Text("Можно находиться бесплатно"),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Checkbox(
                              value: model.review.isFree,
                              onChanged: (value) {
                                model.review.isFree = value!;
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
                              value: model.review.isRazors,
                              onChanged: (value) {
                                model.review.isRazors = value!;
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
                              value: model.review.isWiFi,
                              onChanged: (value) {
                                model.review.isWiFi = value!;
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
                              controller: model.rateController,
                              validator: (input) =>
                                  input!.isEmpty ? "Оценка обязательна" : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            ButtonTheme(
              minWidth: 120.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () async {
                  DatabaseReview.deleteReview(model.review);
                  Navigator.pop(context);
                  model.review.pin?.rating =
                      await DatabasePin.updateRateOfPin(model.review.pin?.id);
                },
                child: const Text(
                  'Удалить',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).errorColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OthersReviewInfoWidget extends StatelessWidget {
  const _OthersReviewInfoWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: model.review.author.userName,
          builder: (context, snapshot) {
            return (snapshot.hasData)
                ? Text(snapshot.data.toString(), textAlign: TextAlign.center)
                : Container();
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const <Widget>[
                        Expanded(
                          child: Text(
                            "Информация об отзыве:",
                            style: TextStyle(fontSize: 30, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(model.review.body),
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
                            FormatDate.formatDate(model.review.timestamp),
                            style: Theme.of(context).textTheme.caption,
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
                            model.review.userRate.toString(),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(
          color: Colors.orange,
          thickness: 2,
        ),
        _ReviewBodyWidget(),
        Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_ReviewAuthorWidget(), _ReviewDateWidget()],
            ),
            const Spacer(),
            _FlagIconButton()
          ],
        )
      ],
    );
  }
}

class _ReviewBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Text(
      model.review.body,
      textScaleFactor: 1.1,
    );
  }
}

class _ReviewAuthorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return FutureBuilder(
      future: model.review.author.userName,
      builder: (_, snapshot) => Text(
        (snapshot.hasData) ? snapshot.data.toString() : "Anonymous",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ReviewDateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Text(
      FormatDate.formatDate(model.review.timestamp),
      style: TextStyle(color: Theme.of(context).primaryColor),
    );
  }
}

class _FlagIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        model.isFlagged ? Icons.flag : Icons.outlined_flag,
        semanticLabel: "Flagged",
      ),
      onPressed: () {
        if (model.isFlagged) {
          model.setUnflagged();
        } else {
          model.setFlagged();
        }
      },
    );
  }
}
