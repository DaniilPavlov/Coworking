import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/domain/services/database_pin.dart';
import 'package:coworking/domain/services/database_review.dart';
import 'package:coworking/screens/map/pin/review/review_widget_model.dart';
import 'package:coworking/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewWidget extends StatelessWidget {
  const ReviewWidget({required this.review, super.key});
  final Review review;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => ReviewWidgetModel(review: review),
        lazy: true,
        child: const _ReviewWidgetView(),
      );
}

class _ReviewWidgetView extends StatelessWidget {
  const _ReviewWidgetView();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return ChangeNotifierProvider.value(
              value: model,
              child: FutureBuilder(
                future: DatabaseReview.isReviewOwner(model.review),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return (snapshot.data ?? false)
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
  const _AuthorsReviewInfoWidget();
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Изменение отзыва', textAlign: TextAlign.center),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final errorSave = await model.saveReview();
              if (errorSave && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Вы заполнили не всю информацию'),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Информация отзыва изменена'),
                  ),
                );
                Navigator.of(context).pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: model.reviewTextController,
              validator: (text) => text!.isEmpty ? 'Отзыв обязателен' : null,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Отзыв',
                contentPadding: EdgeInsets.all(8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const <Widget>[
                  _ReviewCheckBoxes(),
                  _ReviewersRate(),
                ],
              ),
            ),
            const _DeleteReviewButton(),
          ],
        ),
      ),
    );
  }
}

class _ReviewCheckBoxes extends StatefulWidget {
  const _ReviewCheckBoxes();

  @override
  __ReviewCheckBoxesState createState() => __ReviewCheckBoxesState();
}

class __ReviewCheckBoxesState extends State<_ReviewCheckBoxes> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Column(
      children: [
        Text(
          'Раздел оценки места',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.left,
        ),
        Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Можно приобрести еду'),
            ),
            const Spacer(),
            Container(
              alignment: Alignment.centerRight,
              child: Checkbox(
                value: model.review.isFood,
                onChanged: (value) {
                  model.review.isFood = value!;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Можно находиться бесплатно'),
            ),
            const Spacer(),
            Container(
              alignment: Alignment.centerRight,
              child: Checkbox(
                value: model.review.isFree,
                onChanged: (value) {
                  model.review.isFree = value!;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Есть WiFi'),
            ),
            const Spacer(),
            Container(
              alignment: Alignment.centerRight,
              child: Checkbox(
                value: model.review.isWiFi,
                onChanged: (value) {
                  model.review.isWiFi = value!;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Есть розетки'),
            ),
            const Spacer(),
            Container(
              alignment: Alignment.centerRight,
              child: Checkbox(
                value: model.review.isRazors,
                onChanged: (value) {
                  model.review.isRazors = value!;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewersRate extends StatelessWidget {
  const _ReviewersRate();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: const Text('Ваша личная оценка места (введите число от 0 до 10)'),
        ),
        Container(
          alignment: Alignment.center,
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: model.rateController,
            validator: (input) => input!.isEmpty ? 'Оценка обязательна' : null,
          ),
        ),
      ],
    );
  }
}

class _DeleteReviewButton extends StatelessWidget {
  const _DeleteReviewButton();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return ButtonTheme(
      minWidth: 120,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          DatabaseReview.deleteReview(model.review);
          Navigator.of(context).pop(context);
          model.review.pin?.rating = await DatabasePin.updateRateOfPin(model.review.pin?.id);
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
        ),
        child: const Text(
          'Удалить',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
          ),
        ),
      ),
    );
  }
}

class _OthersReviewInfoWidget extends StatelessWidget {
  const _OthersReviewInfoWidget();
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ReviewWidgetModel>();
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: model.review.author.userName,
          builder: (context, snapshot) {
            return (snapshot.hasData) ? Text(snapshot.data.toString(), textAlign: TextAlign.center) : Container();
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: const <Widget>[
                        Expanded(
                          child: Text(
                            'Информация об отзыве:',
                            style: TextStyle(fontSize: 30, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(model.review.body),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            FormatDate.formatDate(model.review.timestamp),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Личная оценка пользователя: ${model.review.userRate}',
                        style: Theme.of(context).textTheme.bodyMedium,
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
            _FlagIconButton(),
          ],
        ),
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
      textScaler: const TextScaler.linear(1.1),
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
        (snapshot.hasData) ? snapshot.data.toString() : 'Аноним',
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
        semanticLabel: 'Flagged',
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
