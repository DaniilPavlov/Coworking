import 'package:coworking/resources/database.dart';
import 'package:coworking/resources/review.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'map.dart';

///этот класс отвечает за отображение *моих* обзоров (не пинов, именно обзоры)
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
              Icons.gps_fixed_outlined,
              color: Colors.black,
              semanticLabel: "Go to pin",
            ),
            iconSize: 40.0,
            color: Color.fromRGBO(0, 0, 0, 0.3),
            onPressed: () {
              ///заменяем страницу в стеке страниц
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

///информация по комментарию пина: флажок\сердечко
///автор, время, сам коммент
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

  @override
  void initState() {
    Database.isFlagged(widget.review.id).then((value) {
      setState(() {
        isFlagged = value;
      });
    });
    Database.isFavourite(widget.review.id).then((value) {
      setState(() {
        isFavourite = value;
      });
    });
    oldComment = widget.review.body;

    super.initState();
  }

  final _formKey = GlobalKey<FormBuilderState>();

  void _saveReview() async {
    if (_formKey.currentState.saveAndValidate()) {
      print(_formKey.currentState.value);
      if (widget.review.body != "") {
        await Database().editReview(widget.review);
        oldComment = widget.review.body;
        Navigator.of(context).pop(context);
        Clipboard.setData(ClipboardData(text: widget.review.body));
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(widget.review.body),
        ));
      } else {
        widget.review.body = oldComment;
        // widget.review.body = oldComment;
      }
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
                future: Database.isReviewOwner(widget.review),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // print("SNAPSHOT DATA");
                    print(snapshot.data);
                    return (snapshot.data == true)
                        ? WillPopScope(
                            onWillPop: () async {
                              setState(() {
                                widget.review.body = oldComment;
                              });
                              return true;
                            },
                            child: Scaffold(
                              appBar: AppBar(actions: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.save),
                                  onPressed: () {
                                    _saveReview();
                                  },
                                )
                              ]),
                              body: SingleChildScrollView(
                                child: Column(children: <Widget>[Container(
                                  padding: EdgeInsets.all(10),
                                  child: FormBuilder(
                                    // context,
                                    key: _formKey,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    initialValue: {},
                                    readOnly: false,
                                    child: FormBuilderTextField(
                                      initialValue: widget.review.body,
                                      attribute: "body",
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        labelText: "Отзыв",
                                        hintText: "Ваш текст",
                                        contentPadding: EdgeInsets.all(8.0),
                                      ),
                                      onChanged: (dynamic val) {
                                        setState(() {
                                          widget.review.body = val;
                                        });
                                      },
                                      validators: [
                                        FormBuilderValidators.required(),
                                        FormBuilderValidators.maxLength(100),
                                      ],
                                    ),
                                  ),
                                ),
                                  ButtonTheme(
                                    minWidth: 120.0,
                                    height: 60.0,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Database.deleteReview(widget.review);
                                        Navigator.pop(context);
                                        // Clipboard.setData(ClipboardData(text: "Ваш комментарий был удален"));
                                        // Scaffold.of(context).showSnackBar(SnackBar(
                                        //   content: Text("Ваш комментарий был удален"),
                                        // ));
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
                              ])
                              ),
                            ),
                          )
                        : Scaffold(
                      body: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(widget.review.body)
                        ),
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                      (snapshot.hasData) ? snapshot.data : "Unknown",
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
                    Database.unFlag(widget.review.id);
                  } else {
                    Database.flag(widget.review.id);
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
                    Database.removeFavourite(widget.review.id);
                  } else {
                    Database.addFavourite(widget.review.id);
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
}

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
              name,
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.3),
            ),
            Text(comment),
            Text(
              date.day.toString().padLeft(2, '0') +
                  "/" +
                  date.month.toString().padLeft(2, '0') +
                  "/" +
                  date.year.toString() +
                  " " +
                  date.hour.toString().padLeft(2, '0') +
                  ":" +
                  date.minute.toString().padLeft(2, '0'),
              style: TextStyle(color: Colors.black.withOpacity(0.4)),
            ),
          ]),
    );
  }
}


/// Любимые отзывы
class StarredReviewsListItem extends ListTile {
  const StarredReviewsListItem(this.review);

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
              Icons.star,
              semanticLabel: "Remove",
            ),
            iconSize: 28.0,
            onPressed: () {
              Database.removeFavourite(review.id);
            },
          ),
        ],
      ),
    );
  }
}

///жалобы на отзывы. Показываются только админу
///Админ устанавливается напрямую через firebase. Вкладка появляется
///в левом меню.
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
              Database.ignoreFlags(review.id);
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
              Database.deleteReview(review);
            },
          ),
        ],
      ),
    );
  }
}

///Когда мы нажимаем на чей-то отзыв в разделе пина, мы можем
///прочитать дополнительную информацию
class ReviewInfoDialog extends StatelessWidget {
  ReviewInfoDialog(this._review);

  final Review _review;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
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
                        child: Text(_review.body),
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
                          _review.timestamp.day.toString().padLeft(2, '0') +
                              "/" +
                              _review.timestamp.month
                                  .toString()
                                  .padLeft(2, '0') +
                              "/" +
                              _review.timestamp.year.toString() +
                              " " +
                              _review.timestamp.hour
                                  .toString()
                                  .padLeft(2, '0') +
                              ":" +
                              _review.timestamp.minute
                                  .toString()
                                  .padLeft(2, '0'),
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
                      "Рейтинг:",
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
                color: Colors.orange,
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                "Закрыть",
                style: Theme.of(context).primaryTextTheme.button,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
